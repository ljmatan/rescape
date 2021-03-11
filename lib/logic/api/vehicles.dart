import 'dart:convert';

import 'package:http/http.dart' as http;

abstract class VehiclesAPI {
  static Future getVehicles() async => jsonDecode((await http.get(Uri.parse(
          'https://rescape-72b1b-default-rtdb.europe-west1.firebasedatabase.app/organisation/vehicles.json')))
      .body);

  static Future<http.Response> addVehicle(String model, String plates) async =>
      await http.patch(
          Uri.parse(
              'https://rescape-72b1b-default-rtdb.europe-west1.firebasedatabase.app/organisation/vehicles/$model.json'),
          body: jsonEncode({'plates': plates}));
}
