import 'package:rescape/data/models/company_model.dart';
import 'package:rescape/data/models/company_sheet_model.dart';

abstract class LocationList {
  static CompaniesSheet _sheetInstance;
  static CompaniesSheet get sheetInstance => _sheetInstance;

  static void setSheetInstance(CompaniesSheet value) => _sheetInstance = value;

  static List<LocationModel> _instance;
  static List<LocationModel> get instance => _instance;

  static Set<String> _companies = {};
  static Set<String> get companies => _companies;

  static void setInstance(List<LocationModel> locations) {
    for (var location in locations) _companies.add(location.companyName);
    _instance = locations;
  }

  static void addToInstance(LocationModel model) {
    _instance.add(model);
    if (!_companies.contains(model.companyName))
      _companies.add(model.companyName);
  }

  static void remove(String id) {
    _instance.removeWhere((e) => e.id == id);
    for (var location in _instance) _companies.add(location.companyName);
  }
}
