import 'dart:ui';

class LanguageService {
  // Eğer cihaz dili Türkçe ise true döndür
  static bool isTurkish() {
    return window.locale.languageCode == 'tr';
  }
}
