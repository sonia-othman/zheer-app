import 'package:flutter/material.dart';
import 'package:zheer/l10n/generated/app_localizations.dart';

class LocalizationHelper {
  static AppLocalizations of(BuildContext context) {
    return AppLocalizations.of(context)!;
  }

  static bool isRTL(BuildContext context) {
    return Directionality.of(context) == TextDirection.rtl;
  }

  static bool isArabic(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'ar';
  }

  static bool isKurdish(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'ku';
  }

  static bool isEnglish(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'en';
  }

  static String formatTimeAgo(BuildContext context, DateTime dateTime) {
    final l10n = of(context);
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return l10n.justNow;
    } else if (difference.inMinutes < 60) {
      return l10n.minutesAgo(difference.inMinutes);
    } else if (difference.inHours < 24) {
      return l10n.hoursAgo(difference.inHours);
    } else {
      if (isArabic(context) || isKurdish(context)) {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
      } else {
        return '${dateTime.month}/${dateTime.day}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
      }
    }
  }

  static TextDirection getTextDirection(BuildContext context) {
    return isArabic(context) || isKurdish(context)
        ? TextDirection.rtl
        : TextDirection.ltr;
  }
}
