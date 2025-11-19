class Product {
  int qty;        // quantity the customer buys
  final String name;
  final double price; // price per unit

  Product({
    this.qty = 0,  // default 0, user can change
    required this.name,
    required this.price,
  });

  double get total => qty * price; // calculate total for this product
}
