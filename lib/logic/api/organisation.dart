import 'dart:convert';

import 'package:http/http.dart' as http;

class OrganisationAPI {
  static Future<
      http
          .Response> login(String username) async => await http.get(Uri.parse(
      'https://rescape-72b1b-default-rtdb.europe-west1.firebasedatabase.app/organisation/employees/$username.json'));

  static Future<http.Response> newEmployee(
    String firstName,
    String lastName,
    String username,
    int pin,
    String type,
  ) async =>
      await http.patch(
          Uri.parse(
              'https://rescape-72b1b-default-rtdb.europe-west1.firebasedatabase.app/organisation/employees/$username.json'),
          body: jsonEncode(
              {'name': '$firstName $lastName', 'pin': pin, 'type': type}));

  Future getEmployees() async => jsonDecode((await http.get(Uri.parse(
          'https://rescape-72b1b-default-rtdb.europe-west1.firebasedatabase.app/organisation/employees.json')))
      .body);

  static Future<http.Response> deleteEmployee(String key) async =>
      await http.delete(Uri.parse(
          'https://rescape-72b1b-default-rtdb.europe-west1.firebasedatabase.app/organisation/employees/$key.json'));
}
