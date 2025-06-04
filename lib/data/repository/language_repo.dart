import 'package:flutter_boilerplate/data/model/response/language_model.dart';
import 'package:flutter_boilerplate/util/app_constants.dart';

class LanguageRepo {
  List<LanguageModel> getAllLanguages() {
    return AppConstants.languages;
  }
}
