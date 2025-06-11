import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zheer/providers/language_provider.dart';
import 'package:zheer/utils/localization_helper.dart';

class LanguageSwitcher extends StatelessWidget {
  final bool showAsDropdown;
  final bool showLanguageNames;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? iconColor;
  final TextStyle? textStyle;

  const LanguageSwitcher({
    Key? key,
    this.showAsDropdown = true,
    this.showLanguageNames = true,
    this.padding,
    this.backgroundColor,
    this.iconColor,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        if (showAsDropdown) {
          return _buildDropdownSwitcher(context, languageProvider);
        } else {
          return _buildDialogSwitcher(context, languageProvider);
        }
      },
    );
  }

  Widget _buildDropdownSwitcher(
    BuildContext context,
    LanguageProvider languageProvider,
  ) {
    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: DropdownButton<String>(
        value: languageProvider.currentLanguageCode,
        underline: const SizedBox(),
        icon: Icon(
          Icons.language,
          color: iconColor ?? Theme.of(context).iconTheme.color,
        ),
        items:
            languageProvider.availableLanguages.map((String languageCode) {
              return DropdownMenuItem<String>(
                value: languageCode,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _getLanguageFlag(languageCode),
                    const SizedBox(width: 8),
                    if (showLanguageNames)
                      Text(
                        languageProvider.getLanguageName(languageCode),
                        style:
                            textStyle ?? Theme.of(context).textTheme.bodyMedium,
                      )
                    else
                      Text(
                        languageCode.toUpperCase(),
                        style:
                            textStyle ?? Theme.of(context).textTheme.bodyMedium,
                      ),
                  ],
                ),
              );
            }).toList(),
        onChanged: (String? newLanguage) async {
          if (newLanguage != null &&
              newLanguage != languageProvider.currentLanguageCode) {
            _showLoadingDialog(context);

            final success = await languageProvider.changeLanguage(newLanguage);

            if (context.mounted) {
              Navigator.of(context).pop(); // Close loading dialog

              if (success) {
                _showSnackBar(
                  context,
                  'Language changed to ${languageProvider.getLanguageName(newLanguage)}',
                  isSuccess: true,
                );
              } else {
                _showSnackBar(
                  context,
                  'Failed to change language. Please try again.',
                  isSuccess: false,
                );
              }
            }
          }
        },
      ),
    );
  }

  Widget _buildDialogSwitcher(
    BuildContext context,
    LanguageProvider languageProvider,
  ) {
    return Container(
      padding: padding ?? const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () => _showLanguageDialog(context, languageProvider),
        borderRadius: BorderRadius.circular(8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.language,
              color: iconColor ?? Theme.of(context).iconTheme.color,
            ),
            const SizedBox(width: 8),
            _getLanguageFlag(languageProvider.currentLanguageCode),
            if (showLanguageNames) ...[
              const SizedBox(width: 8),
              Text(
                languageProvider.getLanguageName(
                  languageProvider.currentLanguageCode,
                ),
                style: textStyle ?? Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              color: iconColor ?? Theme.of(context).iconTheme.color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _getLanguageFlag(String languageCode) {
    switch (languageCode) {
      case 'en':
        return const Text('🇺🇸', style: TextStyle(fontSize: 20));
      case 'ar':
        return const Text('🇮🇶', style: TextStyle(fontSize: 20));
      case 'ku':
        return const Text(
          '🟨🔴🟢',
          style: TextStyle(fontSize: 16),
        ); // Kurdish flag colors
      default:
        return const Icon(Icons.translate);
    }
  }

  void _showLanguageDialog(
    BuildContext context,
    LanguageProvider languageProvider,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.language),
              const SizedBox(width: 8),
              const Text('Select Language'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children:
                languageProvider.availableLanguages.map((String languageCode) {
                  final isSelected =
                      languageCode == languageProvider.currentLanguageCode;

                  return ListTile(
                    leading: _getLanguageFlag(languageCode),
                    title: Text(
                      languageProvider.getLanguageName(languageCode),
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing:
                        isSelected
                            ? Icon(
                              Icons.check_circle,
                              color: Theme.of(context).primaryColor,
                            )
                            : null,
                    onTap: () async {
                      Navigator.of(context).pop(); // Close dialog first

                      if (!isSelected) {
                        _showLoadingDialog(context);

                        final success = await languageProvider.changeLanguage(
                          languageCode,
                        );

                        if (context.mounted) {
                          Navigator.of(context).pop(); // Close loading dialog

                          if (success) {
                            _showSnackBar(
                              context,
                              'Language changed to ${languageProvider.getLanguageName(languageCode)}',
                              isSuccess: true,
                            );
                          } else {
                            _showSnackBar(
                              context,
                              'Failed to change language. Please try again.',
                              isSuccess: false,
                            );
                          }
                        }
                      }
                    },
                  );
                }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Changing language...'),
            ],
          ),
        );
      },
    );
  }

  void _showSnackBar(
    BuildContext context,
    String message, {
    required bool isSuccess,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// Simple icon-only version for app bars
class LanguageSwitcherIcon extends StatelessWidget {
  final Color? iconColor;
  final double iconSize;

  const LanguageSwitcherIcon({Key? key, this.iconColor, this.iconSize = 24.0})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return PopupMenuButton<String>(
          icon: Icon(
            Icons.language,
            color: iconColor ?? Colors.white,
            size: iconSize,
          ),
          onSelected: (String languageCode) async {
            if (languageCode != languageProvider.currentLanguageCode) {
              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder:
                    (context) => const AlertDialog(
                      content: Row(
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
                Navigator.of(context).pop(); // Close loading dialog

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Language changed to ${languageProvider.getLanguageName(languageCode)}'
                          : 'Failed to change language',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
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
