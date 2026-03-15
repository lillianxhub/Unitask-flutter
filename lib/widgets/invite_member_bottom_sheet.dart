import 'package:flutter/material.dart';
import '../models/locale_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InviteMemberBottomSheet extends StatefulWidget {
  final void Function(String? email, String role)? onInvite;

  const InviteMemberBottomSheet({super.key, this.onInvite});

  static void show(
    BuildContext context, {
    void Function(String? email, String role)? onInvite,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => InviteMemberBottomSheet(onInvite: onInvite),
    );
  }

  @override
  State<InviteMemberBottomSheet> createState() =>
      _InviteMemberBottomSheetState();
}

class _InviteMemberBottomSheetState extends State<InviteMemberBottomSheet> {
  final _emailController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  String _selectedRole = 'Editor';
  bool _skipInvite = false;

  void _showErrorDialog(String title, String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFFFF8A80),
          ),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              LocaleManager.instance.t('ok'),
              style: TextStyle(
                color: Color(0xFF6750A4),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) async {
    final text = query.trim().toLowerCase();
    if (text.isEmpty) {
      if (mounted) setState(() => _searchResults = []);
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isGreaterThanOrEqualTo: text)
          .where('email', isLessThan: '$text\uf8ff')
          .limit(5)
          .get();

      if (mounted) {
        setState(() {
          _searchResults = snapshot.docs.map((doc) => doc.data()).toList();
        });
      }
    } catch (e) {
      if (mounted) setState(() => _searchResults = []);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Invite member',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, color: cs.onSurface),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Custom Search Field
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              onChanged: _onSearchChanged,
              enabled: !_skipInvite,
              style: TextStyle(color: cs.onSurface),
              decoration: InputDecoration(
                hintText: 'Enter email to invite',
                hintStyle: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.4),
                ),
                filled: true,
                fillColor: _skipInvite
                    ? cs.surfaceContainerHighest.withValues(alpha: 0.5)
                    : cs.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
            if (_searchResults.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: cs.onSurface.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _searchResults.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final option = _searchResults[index];
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFCFBDF6),
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        option['name'] ?? 'Unknown User',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        option['email'] ?? '',
                        style: const TextStyle(color: Color(0xFF888888)),
                      ),
                      onTap: () {
                        _emailController.text = option['email'] as String;
                        setState(() {
                          _searchResults = [];
                        });
                      },
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 16),
            // Role dropdown
            Opacity(
              opacity: _skipInvite ? 0.5 : 1.0,
              child: Container(
                width: double.infinity,
                height: 55,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedRole,
                    icon: Icon(Icons.arrow_drop_down, color: cs.onSurface),
                    style: TextStyle(color: cs.onSurface, fontSize: 16),
                    dropdownColor: cs.surface,
                    onChanged: _skipInvite
                        ? null
                        : (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedRole = newValue;
                              });
                            }
                          },
                    items: <String>['Editor', 'Viewer']
                        .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                color: value == _selectedRole
                                    ? cs.onSurface
                                    : cs.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                          );
                        })
                        .toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Skip Checkbox
            CheckboxListTile(
              title: Text(
                LocaleManager.instance.t('skip_invite'),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              value: _skipInvite,
              activeColor: const Color(0xFF6750A4),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (bool? value) {
                setState(() {
                  _skipInvite = value ?? false;
                  if (_skipInvite) {
                    _emailController.clear();
                    _searchResults.clear();
                  }
                });
              },
            ),
            const SizedBox(height: 32),
            // Invite button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [cs.secondary, cs.tertiary]),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    final email = _emailController.text.trim();

                    if (!_skipInvite && email.isEmpty) {
                      _showErrorDialog(
                        LocaleManager.instance.t('incomplete_data'),
                        LocaleManager.instance.t('fill_invite_email'),
                      );
                      return;
                    }

                    Navigator.pop(context);
                    widget.onInvite?.call(
                      _skipInvite ? null : email,
                      _selectedRole,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Invite',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
