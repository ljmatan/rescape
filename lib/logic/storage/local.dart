import 'package:rescape/data/product_list.dart';
import 'package:sqflite/sqflite.dart';

abstract class DB {
  static Database _instance;
  static Database get instance => _instance;

  static Future<void> init() async {
    final String dbPath = (await getDatabasesPath()) + 'db.dart';
    _instance = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          'CREATE TABLE Products ('
          'id INTEGER PRIMARY KEY, '
          'product_id INTEGER, '
          'firebase_id TEXT, '
          'name TEST, '
          'barcode TEXT, '
          'measure TEXT, '
          'available REAL, '
          'category TEXT, '
          'section INTEGER'
          ')',
        );
      },
    );

    final Map products =
        Map.fromIterable(await _instance.rawQuery('SELECT * FROM Products'));

    if (products.isNotEmpty) ProductList.setInstance(products, true);
  }
}
