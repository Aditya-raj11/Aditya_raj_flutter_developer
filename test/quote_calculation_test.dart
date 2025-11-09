import 'package:flutter_test/flutter_test.dart';
import 'package:internship/models/quote_item.dart';

void main() {
  test('per-item total exclusive tax', () {
    final item = QuoteItem(
      name: 'X',
      quantity: 2,
      rate: 50,
      discount: 5,
      taxPercent: 10,
    );
    // net = (50-5)*2 = 90
    expect(item.netAmount(), 90);
    // tax = 90 * 0.1 = 9
    expect(item.taxAmount(taxInclusive: false), closeTo(9, 1e-6));
    expect(item.total(taxInclusive: false), closeTo(99, 1e-6));
  });

  test('inclusive tax calculation', () {
    final item = QuoteItem(
      name: 'Y',
      quantity: 1,
      rate: 110,
      discount: 0,
      taxPercent: 10,
    );
    // If rate already includes 10% tax, tax portion = 10
    expect(item.taxAmount(taxInclusive: true), closeTo(10, 1e-6));
    expect(item.total(taxInclusive: true), 110);
  });
}
