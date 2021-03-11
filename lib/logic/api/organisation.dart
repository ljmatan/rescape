import 'dart:convert';

import 'package:http/http.dart' as http;

abstract class OrganisationAPI {
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
}
