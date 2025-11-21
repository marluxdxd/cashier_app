class DBProduct {
  int? id;
  String name;
  int price;

  DBProduct({
    this.id,
    required this.name,
    required this.price,
  });

  // Convert object → Map for SQLite insert
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
    };
  }

  // Convert Map → object when reading from DB
  factory DBProduct.fromMap(Map<String, dynamic> json) {
    return DBProduct(
      id: json['id'],
      name: json['name'],
      price: json['price'],
    );
  }
}
