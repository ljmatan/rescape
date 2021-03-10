enum Measure { qty, kg }

class ProductModel {
  int id;
  String name, barcode, category, firebaseID;
  Measure measureType;
  int quantity;
  double available;
  int section;

  ProductModel({
    this.id,
    this.firebaseID,
    this.name,
    this.barcode,
    this.category,
    this.measureType,
    this.quantity,
    this.available,
    this.section,
  });
}
