import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zheer/providers/language_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final bool showLanguageSwitcher;
  final VoidCallback? onBackPressed;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.showLanguageSwitcher = true,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> appBarActions = [];

    if (showLanguageSwitcher) {
      appBarActions.add(_buildLanguageSwitcher(context));
    }

    if (actions != null) {
      appBarActions.addAll(actions!);
    }

    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      leading:
          showBackButton
              ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              )
              : null,
      actions: appBarActions.isEmpty ? null : appBarActions,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF23538F), Color(0xFF1A4B8F)],
          ),
        ),
      ),
      elevation: 4,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
      ),
    );
  }

  Widget _buildLanguageSwitcher(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return PopupMenuButton<String>(
          icon: const Icon(Icons.language, color: Colors.white, size: 24.0),
          tooltip: 'Change Language',
          onSelected: (String languageCode) async {
            if (languageCode != languageProvider.currentLanguageCode) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder:
                    (context) => const AlertDialog(
                      content: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 16),
                          Text('Changing language...'),
                        ],
                      ),
                    ),
              );

              final success = await languageProvider.changeLanguage(
                languageCode,
              );

              if (context.mounted) {
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Language changed to ${languageProvider.getLanguageName(languageCode)}'
                          : 'Failed to change language. Please try again.',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            }
          },
          itemBuilder: (BuildContext context) {
            return languageProvider.availableLanguages.map((
              String languageCode,
            ) {
              final isSelected =
                  languageCode == languageProvider.currentLanguageCode;

              return PopupMenuItem<String>(
                value: languageCode,
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    Text(
                      languageProvider.getLanguageName(languageCode),
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color:
                            isSelected ? Theme.of(context).primaryColor : null,
                      ),
                    ),
                    const Spacer(),
                    if (isSelected)
                      Icon(
                        Icons.check,
                        color: Theme.of(context).primaryColor,
                        size: 18,
                      ),
                  ],
                ),
              );
            }).toList();
          },
        );
      },
    );
  }
}
