import 'dart:convert';

import 'package:http/http.dart' as http;

abstract class OrdersAPI {
  static Future<http.Response> create(Map body) async => await http.post(
      Uri.parse(
          'https://rescape-72b1b-default-rtdb.europe-west1.firebasedatabase.app/orders/current.json'),
      body: jsonEncode(body));

  static Future getCurrent() async => jsonDecode((await http.get(Uri.parse(
          'https://rescape-72b1b-default-rtdb.europe-west1.firebasedatabase.app/orders/current.json')))
      .body);

  static Future getProcessed() async => jsonDecode((await http.get(Uri.parse(
          'https://rescape-72b1b-default-rtdb.europe-west1.firebasedatabase.app/orders/processed.json')))
      .body);

  static Future orderPrepared(Map body, String key) async {
    await http.post(
        Uri.parse(
            'https://rescape-72b1b-default-rtdb.europe-west1.firebasedatabase.app/orders/processed.json'),
        body: jsonEncode(body));
    await http.delete(Uri.parse(
        'https://rescape-72b1b-default-rtdb.europe-west1.firebasedatabase.app/orders/current/$key.json'));
  }

  static Future<http.Response> createReturn(Map body) async => await http.post(
      Uri.parse(
          'https://rescape-72b1b-default-rtdb.europe-west1.firebasedatabase.app/orders/returns.json'),
      body: jsonEncode(body));

  static Future getReturs() async => jsonDecode((await http.get(Uri.parse(
          'https://rescape-72b1b-default-rtdb.europe-west1.firebasedatabase.app/orders/returns.json')))
      .body);
}
