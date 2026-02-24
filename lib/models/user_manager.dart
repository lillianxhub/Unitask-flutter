import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserManager extends ChangeNotifier {
  UserManager._() {
    // Listen to Firebase auth state changes automatically
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        _isLoggedIn = false;
        if (!_isGuestMode) {
          _name = 'Guest';
          _email = 'guest@unitask.com';
        }
      } else {
        _isLoggedIn = true;
        _isGuestMode = false;
        _name = user.displayName ?? user.email?.split('@')[0] ?? 'User';
        _email = user.email ?? 'No Email';
      }
      notifyListeners();
    });
  }

  static final UserManager _instance = UserManager._();
  static UserManager get instance => _instance;

  String _name = 'Guest';
  String _email = 'guest@unitask.com';
  String _role = 'User';
  bool _isLoggedIn = false;
  bool _isGuestMode = false;

  String get name => _name;
  String get email => _email;
  String get role => _role;
  bool get isLoggedIn => _isLoggedIn || _isGuestMode;

  User? get currentUser => FirebaseAuth.instance.currentUser;

  Future<void> _saveUserToFirestore(User user) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email ?? '',
        'name': user.displayName ?? user.email?.split('@')[0] ?? 'User',
      }, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) print('Error saving user to Firestore: $e');
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _role = 'Member';
      if (FirebaseAuth.instance.currentUser != null) {
        await _saveUserToFirestore(FirebaseAuth.instance.currentUser!);
      }
      return null; // null means success
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Login failed';
    } catch (e) {
      return e.toString();
    }
  }

  void loginAsGuest() {
    _isGuestMode = true;
    _email = 'guest@unitask.com';
    _name = 'Guest User';
    _role = 'Guest';
    notifyListeners();
  }

  Future<String?> register(String name, String email, String password) async {
    try {
      UserCredential credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );
      await credential.user?.updateDisplayName(name.trim());
      _role = 'Member';
      if (credential.user != null) {
        // Refetch user to get updated displayName
        await credential.user?.reload();
        await _saveUserToFirestore(FirebaseAuth.instance.currentUser!);
      }
      return null; // success
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Registration failed';
    } catch (e) {
      return e.toString();
    }
  }

  bool _isGoogleSignInInitialized = false;

  Future<String?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        GoogleAuthProvider authProvider = GoogleAuthProvider();
        authProvider.setCustomParameters({'prompt': 'select_account'});
        await FirebaseAuth.instance.signInWithPopup(authProvider);
        _role = 'Member';
        if (FirebaseAuth.instance.currentUser != null) {
          await _saveUserToFirestore(FirebaseAuth.instance.currentUser!);
        }
        return null;
      } else {
        if (!_isGoogleSignInInitialized) {
          await GoogleSignIn.instance.initialize(
            serverClientId:
                '1079443073222-sv5lqb2brbs5g08p7tdl0o9kdm9kccc6.apps.googleusercontent.com',
          );
          _isGoogleSignInInitialized = true;
        }

        final GoogleSignInAccount googleUser = await GoogleSignIn.instance
            .authenticate();

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        await FirebaseAuth.instance.signInWithCredential(credential);
        _role = 'Member';
        if (FirebaseAuth.instance.currentUser != null) {
          await _saveUserToFirestore(FirebaseAuth.instance.currentUser!);
        }
        return null;
      }
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Google Sign-In failed';
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> logout() async {
    _isGuestMode = false;
    _role = 'User';
    try {
      if (!kIsWeb) {
        await GoogleSignIn.instance.signOut();
      }
    } catch (e) {
      if (kDebugMode) print('Google SignOut error: $e');
    }

    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      if (kDebugMode) print('Firebase SignOut error: $e');
    }
  }

  void updateProfile({String? name, String? role}) {
    if (name != null) {
      _name = name;
      FirebaseAuth.instance.currentUser?.updateDisplayName(name);
    }
    if (role != null) _role = role;
    notifyListeners();
  }
}
