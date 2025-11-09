import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/quote.dart';

class PreviewCleanScreen extends StatelessWidget {
  final Quote quote;
  const PreviewCleanScreen({super.key, required this.quote});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.simpleCurrency(name: quote.currency);
    return Scaffold(
      appBar: AppBar(title: const Text('Quote Preview')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo placeholder
                    Container(
                      width: 100,
                      height: 60,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: const Center(child: Text('LOGO')),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Your Company',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('Client: ${quote.clientName}'),
                            Text('Ref: ${quote.reference}'),
                            Text(quote.clientAddress),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Status: ${quote.status}'),
                        Text(
                          'Date: ${DateFormat.yMMMd().format(DateTime.now())}',
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 24),
                Table(
                  border: TableBorder.all(color: Colors.grey.shade300),
                  columnWidths: const {
                    0: FlexColumnWidth(4),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(1),
                    3: FlexColumnWidth(1),
                  },
                  children: [
                    TableRow(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(6),
                          child: Text(
                            'Description',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(6),
                          child: Text(
                            'Qty',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(6),
                          child: Text(
                            'Unit',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(6),
                          child: Text(
                            'Total',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    ...quote.items.map(
                      (it) => TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(6),
                            child: Text(it.name.isEmpty ? '(item)' : it.name),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(6),
                            child: Text(it.quantity.toString()),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(6),
                            child: Text(
                              NumberFormat.simpleCurrency(
                                name: quote.currency,
                              ).format(it.rate),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(6),
                            child: Text(
                              currency.format(
                                it.total(
                                  taxInclusive:
                                      quote.taxMode == TaxMode.inclusive,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Subtotal: ${currency.format(quote.subtotal())}'),
                      Text('Tax: ${currency.format(quote.totalTax())}'),
                      Text(
                        'Grand total: ${currency.format(quote.grandTotal())}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Notes',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Thank you for your business. This quote is valid for 30 days.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
