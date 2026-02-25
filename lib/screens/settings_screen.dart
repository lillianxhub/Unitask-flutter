import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/theme_manager.dart';
import '../widgets/change_password_bottom_sheet.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'ตั้งค่าบัญชี',
          style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: cs.onSurface),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'ความปลอดภัยบัญชี',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: cs.primary,
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingsTile(
            context,
            icon: Icons.lock_outline,
            title: 'เปลี่ยนรหัสผ่าน',
            onTap: () {
              ChangePasswordBottomSheet.show(context);
            },
          ),
          Divider(height: 32, color: cs.outline),
          Text(
            'การตั้งค่าอื่นๆ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: cs.primary,
            ),
          ),
          const SizedBox(height: 16),
          Consumer<ThemeManager>(
            builder: (context, themeManager, _) {
              return _buildThemeToggleTile(context, themeManager);
            },
          ),
          const SizedBox(height: 8),
          _buildSettingsTile(
            context,
            icon: Icons.language,
            title: 'ภาษา (เร็วๆ นี้)',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggleTile(
    BuildContext context,
    ThemeManager themeManager,
  ) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          themeManager.isDarkMode
              ? Icons.dark_mode_rounded
              : Icons.light_mode_rounded,
          color: cs.primary,
        ),
      ),
      title: Text(
        'ธีมมืด',
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: cs.onSurface,
        ),
      ),
      trailing: Switch(
        value: themeManager.isDarkMode,
        onChanged: (_) => themeManager.toggleTheme(),
        activeColor: cs.primary,
      ),
      onTap: () => themeManager.toggleTheme(),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: cs.primary),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: cs.onSurface,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: cs.onSurface.withValues(alpha: 0.4),
      ),
      onTap: onTap,
    );
  }
}
