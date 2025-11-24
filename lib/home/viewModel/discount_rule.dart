class DiscountRules {
  /// Simple rule: subtract 1 peso from the total
  static int minusOne(int qty, int price) {
    if (qty <= 0) return 0;
    return (qty * price) - 1;
  }

  /// Buy 3 for 5 promo (your existing rule)
  static int buy3For5(int qty, int price) {
    if (qty <= 0 || price != 2) return qty * price;

    int promoQty = 3;
    int promoPrice = 5;

    int bundles = qty ~/ promoQty;
    int remaining = qty % promoQty;

    return (bundles * promoPrice) + (remaining * price);
  }
}
