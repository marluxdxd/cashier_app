class Product {
  int? id; // optional, used for database
  int qty; // represents actual stock in store
  String name;
  double price;

  Product({
    this.id,
    this.qty = 0, // default for POS / store stock
    required this.name,
    required this.price,
  });

  // Total for POS (qty * price)
  double get total => qty * price;

  // Reduce stock after a sale
  void reduceStock(int soldQty) {
    if (qty <= 0) {
      throw Exception("No stock, please add stock");
    }

    if (soldQty > qty) {
      throw Exception("Not enough stock. Available: $qty");
    }

    qty -= soldQty;
  }

  // Optional: Increase stock if restocking
  void addStock(int addedQty) {
    if (addedQty <= 0) return;
    qty += addedQty;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product &&
        other.id == id; // Compare by id or other fields you want
  }

  @override
  int get hashCode => id.hashCode; // Use id for unique identification
}
