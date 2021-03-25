import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rescape/data/company_list.dart';
import 'package:rescape/data/models/company_model.dart';
import 'package:rescape/data/models/company_sheet_model.dart';

abstract class Companies {
  static Future getList() async {
    final response = await http.get(Uri.parse(
        'https://spreadsheets.google.com/feeds/cells/11yJUGNDn7-Q_0-HO9fy5IiWfFC75shgVR-hA-O23xTQ/2/public/full?alt=json'));
    final decoded = jsonDecode(response.body);

    LocationList.setSheetInstance(CompaniesSheet.fromJson(decoded));

    List<LocationModel> locations = [];

    for (var i = 0; i < LocationList.sheetInstance.feed.entry.length; i += 5) {
      final location = LocationModel(
        id: LocationList.sheetInstance.feed.entry[i].content.t,
        companyName: LocationList.sheetInstance.feed.entry[i + 1].content.t,
        number: LocationList.sheetInstance.feed.entry[i + 2].content.t,
        address: LocationList.sheetInstance.feed.entry[i + 3].content.t,
        city: LocationList.sheetInstance.feed.entry[i + 4].content.t,
      );

      locations.add(location);
    }

    LocationList.setInstance(locations);
  }
}

abstract class CompaniesAPI {
  static Future getList() async {
    final response = await http.get(Uri.parse(
        'https://rescape-72b1b-default-rtdb.europe-west1.firebasedatabase.app/companies.json'));
    final decoded = jsonDecode(response.body);

    List<LocationModel> locations = [];

    for (int i = 0; i < decoded.entries.length; i++) {
      final location = LocationModel(
        id: decoded.entries.elementAt(i).key,
        companyName: decoded.entries.elementAt(i).value['name'],
        number: decoded.entries.elementAt(i).value['location'].toString(),
        address: decoded.entries.elementAt(i).value['address'],
        city: decoded.entries.elementAt(i).value['city'],
      );

      locations.add(location);
    }

    LocationList.setInstance(locations);
  }

  static Future<http.Response> addNew(Map body) async {
    http.Response response;

    try {
      response = await http.post(
          Uri.parse(
              'https://rescape-72b1b-default-rtdb.europe-west1.firebasedatabase.app/companies.json'),
          body: jsonEncode(body));
    } catch (e) {
      print('$e');
    }

    return response;
  }

  static Future remove(String toRemove) async {
    int statusCode = 400;

    try {
      final response = await http.delete(Uri.parse(
          'https://rescape-72b1b-default-rtdb.europe-west1.firebasedatabase.app/companies/$toRemove.json'));
      LocationList.remove(toRemove);

      statusCode = response.statusCode;
    } catch (e) {
      print('failed here');
      print('$e');
    }

    return statusCode;
  }
}
