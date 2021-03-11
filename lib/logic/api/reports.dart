import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rescape/data/user_data.dart';

abstract class ReportsAPI {
  static Future<http.Response> newDamageReport(
          String message, String image) async =>
      await http.post(
          Uri.parse(
              'https://rescape-72b1b-default-rtdb.europe-west1.firebasedatabase.app/reports/damage.json'),
          body: jsonEncode({
            'time': DateTime.now().toIso8601String(),
            'message': message,
            'image': image,
            'from': UserData.instance.name,
          }));

  static Future<
      http
          .Response> deleteReport(int key) async => await http.delete(Uri.parse(
      'https://rescape-72b1b-default-rtdb.europe-west1.firebasedatabase.app/reports/damage/$key.json'));

  static Future getDamageReports() async => jsonDecode((await http.get(Uri.parse(
          'https://rescape-72b1b-default-rtdb.europe-west1.firebasedatabase.app/reports/damage.json')))
      .body);
}
