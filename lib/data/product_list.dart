import 'package:rescape/data/models/product_model.dart';
import 'package:rescape/logic/storage/local.dart';

abstract class ProductList {
  static List<ProductModel> _instance = [];
  static List<ProductModel> get instance => _instance;

  static Set<String> _categories = {};
  static Set<String> get categories => _categories;

  static Future<void> setInstance(Map products, [bool cached = false]) async {
    _instance.clear();
    _categories.clear();
    await DB.instance.delete('Products');
    for (var product in products.entries) {
      if (!cached)
        await DB.instance.insert(
          'Products',
          {
            'product_id': product.value['product_id'],
            'name': product.value['name'],
            'barcode': product.key,
            'measure': product.value['measure'],
            'available': (product.value['available'] ?? 0.0).runtimeType == int
                ? product.value['available'].toDouble()
                : (product.value['available'] ?? 0.0),
            'category': product.value['category'],
            'section': product.value['section'],
          },
        );
      _categories.add(product.value['category']);
      _instance.add(ProductModel(
        id: product.value['product_id'],
        name: product.value['name'],
        barcode: cached ? product.value['barcode'] : product.key,
        category: product.value['category'],
        measureType: product.value['measure'].startsWith('QTY')
            ? Measure.qty
            : Measure.kg,
        quantity: product.value['measure'].startsWith('QTY')
            ? int.parse(product.value['measure'].substring(3))
            : null,
        available: (product.value['available'] ?? 0.0).runtimeType == int
            ? product.value['available'].toDouble()
            : (product.value['available'] ?? 0.0),
        section: product.value['section'],
      ));
    }
  }
}
