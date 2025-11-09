import 'quote_item.dart';

enum TaxMode { exclusive, inclusive }

class Quote {
  String clientName;
  String clientAddress;
  String reference;
  List<QuoteItem> items;
  String currency;
  TaxMode taxMode;
  String status; // Draft, Sent, Accepted

  Quote({
    this.clientName = '',
    this.clientAddress = '',
    this.reference = '',
    this.items = const [],
    this.currency = 'USD',
    this.taxMode = TaxMode.exclusive,
    this.status = 'Draft',
  });

  double subtotal() => items.fold(0.0, (p, e) => p + e.netAmount());

  double totalTax() => items.fold(
    0.0,
    (p, e) => p + e.taxAmount(taxInclusive: taxMode == TaxMode.inclusive),
  );

  double grandTotal() {
    if (taxMode == TaxMode.inclusive) {
      return items.fold(0.0, (p, e) => p + e.total(taxInclusive: true));
    }

    return subtotal() + totalTax();
  }

  Map<String, dynamic> toJson() => {
    'clientName': clientName,
    'clientAddress': clientAddress,
    'reference': reference,
    'currency': currency,
    'taxMode': taxMode == TaxMode.inclusive ? 'inclusive' : 'exclusive',
    'status': status,
    'items': items.map((e) => e.toJson()).toList(),
  };

  factory Quote.fromJson(Map<String, dynamic> j) => Quote(
    clientName: j['clientName'] ?? '',
    clientAddress: j['clientAddress'] ?? '',
    reference: j['reference'] ?? '',
    currency: j['currency'] ?? 'USD',
    taxMode: (j['taxMode'] ?? 'exclusive') == 'inclusive'
        ? TaxMode.inclusive
        : TaxMode.exclusive,
    status: j['status'] ?? 'Draft',
    items: (j['items'] as List<dynamic>? ?? [])
        .map((e) => QuoteItem.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
  );
}
