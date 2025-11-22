class Sale {
  int? id;
  String productName;
  int qty;
  int price;
  int total;
  String date;

  Sale({
    this.id,
    required this.productName,
    required this.qty,
    required this.price,
    required this.total,
    required this.date,
  });

  // Convert Sale object to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productName': productName,
      'qty': qty,
      'price': price,
      'total': total,
      'date': date,
    };
  }

  // Optional: Create Sale object from Map (for fetching)
  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'] as int?,
      productName: map['productName'] as String,
      qty: map['qty'] as int,
      price: map['price'] as int,
      total: map['total'] as int,
      date: map['date'] as String,
    );
  }
}
