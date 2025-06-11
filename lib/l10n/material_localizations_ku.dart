import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class KurdishMaterialLocalizations extends DefaultMaterialLocalizations {
  const KurdishMaterialLocalizations();

  static const LocalizationsDelegate<MaterialLocalizations> delegate =
      _KurdishMaterialLocalizationsDelegate();

  // Basic buttons
  @override
  String get okButtonLabel => 'باشە';

  @override
  String get cancelButtonLabel => 'هەڵوەشاندنەوە';

  @override
  String get closeButtonLabel => 'داخستن';

  @override
  String get continueButtonLabel => 'بەردەوامبوون';

  @override
  String get copyButtonLabel => 'کۆپی';

  @override
  String get cutButtonLabel => 'بڕین';

  @override
  String get deleteButtonLabel => 'سڕینەوە';

  @override
  String get pasteButtonLabel => 'لکاندن';

  @override
  String get selectAllButtonLabel => 'هەموو هەڵبژاردن';

  // Navigation
  @override
  String get backButtonTooltip => 'گەڕانەوە';

  @override
  String get nextMonthTooltip => 'مانگی داهاتوو';

  @override
  String get previousMonthTooltip => 'مانگی پێشوو';

  @override
  String get nextPageTooltip => 'پەڕەی داهاتوو';

  @override
  String get previousPageTooltip => 'پەڕەی پێشوو';

  @override
  String get firstPageTooltip => 'یەکەم پەڕە';

  @override
  String get lastPageTooltip => 'کۆتا پەڕە';

  // Menu and actions
  @override
  String get showMenuTooltip => 'نیشاندانی مینیو';

  @override
  String get moreButtonTooltip => 'زیاتر';

  @override
  String get searchFieldLabel => 'گەڕان';

  @override
  String get refreshIndicatorSemanticLabel => 'نوێکردنەوە';

  // Date picker
  @override
  String get datePickerHelpText => 'بەروار هەڵبژێرە';

  @override
  String get dateInputLabel => 'بەروار بنووسە';

  @override
  String get calendarModeButtonLabel => 'گۆڕین بۆ ڕۆژژمێر';

  @override
  String get inputDateModeButtonLabel => 'گۆڕین بۆ نووسین';

  @override
  String get invalidDateFormatLabel => 'شێوازی بەروار هەڵەیە';

  @override
  String get dateOutOfRangeLabel => 'بەروار لە دەرەوەی سنوورە';

  // Time picker
  @override
  String get timePickerHelpText => 'کات هەڵبژێرە';

  @override
  String get timePickerInputHelpText => 'کات بنووسە';

  @override
  String get timePickerHourLabel => 'کاتژمێر';

  @override
  String get timePickerMinuteLabel => 'خولەک';

  @override
  String get invalidTimeLabel => 'کاتی دروست بنووسە';

  // Dialog
  @override
  String get alertDialogLabel => 'ئاگاداری';

  @override
  String get dialogLabel => 'دیالۆگ';

  // Drawer
  @override
  String get drawerLabel => 'مینیوی ناوبری';

  @override
  String get openAppDrawerTooltip => 'کردنەوەی مینیوی ناوبری';

  // Page and row information
  @override
  String aboutListTileTitle(String applicationName) =>
      'دەربارەی $applicationName';

  @override
  String pageRowsInfoTitle(
    int firstRowIndex,
    int lastRowIndex,
    int rowCount,
    bool rowCountIsApproximate,
  ) {
    return '${firstRowIndex}–${lastRowIndex} لە ${rowCountIsApproximate ? 'نزیکەی' : ''} $rowCount';
  }

  @override
  String get rowsPerPageTitle => 'ڕیز بۆ هەر پەڕەیەک:';

  @override
  String tabLabel({required int tabIndex, required int tabCount}) {
    return 'تابی $tabIndex لە $tabCount';
  }

  // Expansion panel
  @override
  String get expandedIconTapHint => 'کۆکردنەوە';

  @override
  String get collapsedIconTapHint => 'فراوانکردن';

  // Popup menu
  @override
  String get popupMenuLabel => 'مینیوی پۆپئەپ';

  @override
  String get menuBarMenuLabel => 'مینیوی مینیو بار';

  // Reorderable list
  @override
  String get reorderItemToStart => 'بیبەرە بۆ سەرەتا';

  @override
  String get reorderItemToEnd => 'بیبەرە بۆ کۆتایی';

  @override
  String get reorderItemUp => 'بیبەرە بۆ سەرەوە';

  @override
  String get reorderItemDown => 'بیبەرە بۆ خوارەوە';

  @override
  String get reorderItemLeft => 'بیبەرە بۆ چەپ';

  @override
  String get reorderItemRight => 'بیبەرە بۆ ڕاست';

  // Slider
  @override
  String get modalBarrierDismissLabel => 'ڕەتکردنەوە';

  // Bottom sheet
  @override
  String get bottomSheetLabel => 'شیتی خوارەوە';

  // Snack bar
  @override
  String get hideAccountEmailLabel => 'شاردنەوەی ئیمەیڵ';

  @override
  String get showAccountEmailLabel => 'نیشاندانی ئیمەیڵ';

  // License
  @override
  String get licensesPageTitle => 'مۆڵەتنامەکان';

  @override
  String licensesPackageDetailText(int licenseCount) {
    if (licenseCount == 1) {
      return '١ مۆڵەتنامە';
    }
    return '$licenseCount مۆڵەتنامە';
  }

  // Overflow menu
  @override
  String get signedInLabel => 'چووەتە ژوورەوە';

  @override
  String get keyboardKeyShift => 'Shift';

  @override
  String get keyboardKeyAlt => 'Alt';

  @override
  String get keyboardKeyMeta => 'Meta';

  @override
  String get keyboardKeyControl => 'Ctrl';

  // Script category
  @override
  ScriptCategory get scriptCategory => ScriptCategory.englishLike;
}

class _KurdishMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _KurdishMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ku';

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    return SynchronousFuture<MaterialLocalizations>(
      const KurdishMaterialLocalizations(),
    );
  }

  @override
  bool shouldReload(LocalizationsDelegate<MaterialLocalizations> old) => false;
}
