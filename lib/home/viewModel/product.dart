class Product {
  int? id;       // optional, used for database
  int qty;
 String name;
   double price;

  Product({
    this.id,
    this.qty = 0,  // default for POS
    required this.name,
    required this.price,
  });

  double get total => qty * price;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id; // Compare by id or other fields you want
  }

  @override
  int get hashCode => id.hashCode;  // Use id for unique identification
}
