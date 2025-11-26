class Product {
  int? id; // optional, used for database
  int qty; // represents actual stock in store
  int otherqty;
  String name;
  double price;
    double retainprice;  // retain price (special price)
  bool promo; // NEW
  int? fixedQty; // NEW: if null => user can change qty, if not null => fixed qty
  bool promoApplied;
  

  Product({
    this.id,
    this.qty = 0, // default for POS / store stock
    this.otherqty = 0,
    required this.name,
    required this.price,
     this.retainprice = 0,
    this.promo = false, // NEW
    this.fixedQty, // default null
    this.promoApplied = false,
  });

  // Total for POS (qty * price)
  double get total => qty * price;
  double get totals => otherqty * price;

  // Reduce stock after a sale
  void reduceStock(int soldQty) {
    if (qty <= 0) {
      throw Exception("$name: No stock, please add stock");
    }

    if (soldQty > qty) {
      throw Exception("$name: Not enough stock. Available: $qty");
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
