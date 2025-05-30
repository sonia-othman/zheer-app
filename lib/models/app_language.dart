class AppLanguage {
  final String code;
  final String name;
  final String nativeName;
  final bool isRtl;

  AppLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.isRtl,
  });

  static List<AppLanguage> get supportedLanguages => [
    AppLanguage(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      isRtl: false,
    ),
    AppLanguage(code: 'ar', name: 'Arabic', nativeName: 'العربية', isRtl: true),
    AppLanguage(code: 'ku', name: 'Kurdish', nativeName: 'کوردی', isRtl: true),
  ];

  static AppLanguage getByCode(String code) {
    return supportedLanguages.firstWhere(
      (lang) => lang.code == code,
      orElse: () => supportedLanguages.first,
    );
  }
}
