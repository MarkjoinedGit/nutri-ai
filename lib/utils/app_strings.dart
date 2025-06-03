import 'strings_en_util.dart';
import 'strings_vi_util.dart';

class AppStrings {
  static dynamic getStrings(String languageCode) {
    switch (languageCode) {
      case 'en':
        return StringsEn();
      case 'vi':
      default:
        return StringsVi();
    }
  }
}