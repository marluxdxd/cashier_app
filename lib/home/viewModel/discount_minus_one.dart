class DiscountMinusOne {
  static int apply(int qty, int price) {
    // must be exactly 3 qty
    if (qty != 3) {
      return -1;
    }

    return (qty * price) - 1;
  }
}
