class Sale {
  final int? id;
  final String productName;
  final int qty;
  final int price;
  final int total;
  final String date;

  Sale({
    this.id,
    required this.productName,
    required this.qty,
    required this.price,
    required this.total,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'productName': productName,
      'qty': qty,
      'price': price,
      'total': total,
      'date': date,
    };
  }
}
