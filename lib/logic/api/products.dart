import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rescape/data/product_list.dart';

abstract class ProductsAPI {
  static Future getList() async {
    final response = await http.get(Uri.parse(
        'https://rescape-72b1b-default-rtdb.europe-west1.firebasedatabase.app/products.json'));

    final Map products = jsonDecode(response.body);

    await ProductList.setInstance(products);
  }

  static Future<http.Response> create(
          double available,
          int barcode,
          String category,
          String measure,
          String name,
          int id,
          int section) async =>
      await http.patch(
          Uri.parse(
              'https://rescape-72b1b-default-rtdb.europe-west1.firebasedatabase.app/products/$barcode.json'),
          body: jsonEncode({
            'available': available,
            'category': category,
            'measure': measure,
            'name': name,
            'product_id': id,
            'section': section
          }));

  static Future<http.Response> deleteProduct(String barcode) async =>
      await http.delete(Uri.parse(
          'https://rescape-72b1b-default-rtdb.europe-west1.firebasedatabase.app/products/$barcode.json'));

  static Future<http.Response> setProductSection(
          String barcode, int section) async =>
      await http.patch(
        Uri.parse(
            'https://rescape-72b1b-default-rtdb.europe-west1.firebasedatabase.app/products/$barcode.json'),
        body: jsonEncode({'section': section}),
      );

  static Future<http.Response> setProductAvailability(
          String barcode, double available) async =>
      await http.patch(
        Uri.parse(
            'https://rescape-72b1b-default-rtdb.europe-west1.firebasedatabase.app/products/$barcode.json'),
        body: jsonEncode({'available': available}),
      );

  static Future<http.Response> massProductAvailabilityUpdate(Map body) async =>
      await http.patch(
        Uri.parse(
            'https://rescape-72b1b-default-rtdb.europe-west1.firebasedatabase.app/products.json'),
        body: jsonEncode(body),
      );
}
