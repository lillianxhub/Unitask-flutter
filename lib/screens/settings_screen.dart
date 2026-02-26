import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/theme_manager.dart';
import '../models/locale_manager.dart';
import '../widgets/change_password_bottom_sheet.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Consumer<LocaleManager>(
      builder: (context, locale, _) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              locale.t('account_settings'),
              style: TextStyle(
                color: cs.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: theme.appBarTheme.backgroundColor,
            elevation: 0,
            iconTheme: IconThemeData(color: cs.onSurface),
          ),
          body: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Text(
                  locale.t('account_security'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
                ),
              ),
              _buildSettingsTile(
                context,
                icon: Icons.lock_outline,
                title: locale.t('change_password'),
                onTap: () {
                  ChangePasswordBottomSheet.show(context);
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Divider(height: 32, color: cs.outline),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Text(
                  locale.t('other_settings'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
                ),
              ),
              Consumer<ThemeManager>(
                builder: (context, themeManager, _) {
                  return _buildThemeToggleTile(context, themeManager, locale);
                },
              ),
              const SizedBox(height: 8),
              _buildSettingsTile(
                context,
                icon: Icons.language,
                title: locale.t('language'),
                subtitle: locale.isThai
                    ? locale.t('language_thai')
                    : locale.t('language_english'),
                onTap: () => _showLanguageDialog(context, locale),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context, LocaleManager locale) {
    final cs = Theme.of(context).colorScheme;
    String selected = locale.locale;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                locale.t('select_language'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLanguageOption(
                    context,
                    flag: '🇹🇭',
                    label: 'ภาษาไทย',
                    value: 'th',
                    selected: selected,
                    onTap: () {
                      setDialogState(() => selected = 'th');
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildLanguageOption(
                    context,
                    flag: '🇺🇸',
                    label: 'English',
                    value: 'en',
                    selected: selected,
                    onTap: () {
                      setDialogState(() => selected = 'en');
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    locale.t('cancel'),
                    style: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                FilledButton(
                  onPressed: () {
                    locale.setLocale(selected);
                    Navigator.pop(context);
                  },
                  child: Text(locale.t('confirm')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, {
    required String flag,
    required String label,
    required String value,
    required String selected,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    final isSelected = value == selected;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? cs.primary.withValues(alpha: 0.1)
              : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? cs.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurface,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: cs.primary, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeToggleTile(
    BuildContext context,
    ThemeManager themeManager,
    LocaleManager locale,
  ) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
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
        locale.t('dark_theme'),
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
    String? subtitle,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
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
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: cs.onSurface.withValues(alpha: 0.5),
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right,
        color: cs.onSurface.withValues(alpha: 0.4),
      ),
      onTap: onTap,
    );
  }
}
