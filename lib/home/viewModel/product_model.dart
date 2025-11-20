class ProductModel {
  final int? id;
  final String name;
  final int price;

  ProductModel({this.id, required this.name, required this.price});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      price: map['price'] as int,
    );
  }
}
