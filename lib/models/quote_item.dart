class QuoteItem {
  String name;
  double quantity;
  double rate;
  double discount;
  double taxPercent;

  QuoteItem({
    this.name = '',
    this.quantity = 1,
    this.rate = 0,
    this.discount = 0,
    this.taxPercent = 0,
  });

  double netAmount() {
    final effective = (rate - discount) * quantity;
    return effective;
  }

  double taxAmount({bool taxInclusive = false}) {
    final base = netAmount();
    if (taxInclusive) {
      // If tax is inclusive, we'll calculate the tax portion from base
      final divisor = 1 + taxPercent / 100.0;
      final exclusive = base / divisor;
      return base - exclusive;
    }
    return base * (taxPercent / 100.0);
  }

  double total({bool taxInclusive = false}) {
    final base = netAmount();
    if (taxInclusive) return base; // already includes tax
    return base + taxAmount(taxInclusive: false);
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'quantity': quantity,
    'rate': rate,
    'discount': discount,
    'taxPercent': taxPercent,
  };

  factory QuoteItem.fromJson(Map<String, dynamic> j) => QuoteItem(
    name: j['name'] ?? '',
    quantity: (j['quantity'] ?? 1).toDouble(),
    rate: (j['rate'] ?? 0).toDouble(),
    discount: (j['discount'] ?? 0).toDouble(),
    taxPercent: (j['taxPercent'] ?? 0).toDouble(),
  );
}
