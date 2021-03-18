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

  static void removeWhere(String id) {
    _instance.removeWhere((e) => e.id == id);
    Set<String> toRemove = {};
    for (var companyName in _companies)
      if (_instance.firstWhere(
            (e) => e.companyName == companyName,
            orElse: () => null,
          ) ==
          null) toRemove.add(companyName);
    if (toRemove.isNotEmpty)
      for (var companyName in toRemove)
        _companies.removeWhere((e) => e == companyName);
  }
}
