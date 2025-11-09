import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../models/quote.dart';
import '../services/storage_service.dart';

class SavedQuoteDetail extends StatefulWidget {
  final Quote quote;
  final int index;
  final VoidCallback? onUpdated;
  const SavedQuoteDetail({
    super.key,
    required this.quote,
    required this.index,
    this.onUpdated,
  });

  @override
  State<SavedQuoteDetail> createState() => _SavedQuoteDetailState();
}

class _SavedQuoteDetailState extends State<SavedQuoteDetail> {
  late Quote q;
  final StorageService _storage = StorageService();

  @override
  void initState() {
    super.initState();
    q = widget.quote;
  }

  Future<void> _simulateSend() async {
    // Simulate network send
    setState(() => q.status = 'Sending...');
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => q.status = 'Sent');
    await _storage.updateQuote(widget.index, q);
    widget.onUpdated?.call();
    if (!mounted) return;
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Quote sent (simulated)')));
  }

  void _share() {
    final buffer = StringBuffer();
    buffer.writeln('Quote for: ${q.clientName}');
    buffer.writeln('Ref: ${q.reference}');
    buffer.writeln('');
    for (final it in q.items) {
      buffer.writeln(
        '${it.name} x${it.quantity} @ ${NumberFormat.simpleCurrency(name: q.currency).format(it.rate)} = ${NumberFormat.simpleCurrency(name: q.currency).format(it.total(taxInclusive: q.taxMode == TaxMode.inclusive))}',
      );
    }
    buffer.writeln('');
    buffer.writeln(
      'Subtotal: ${NumberFormat.simpleCurrency(name: q.currency).format(q.subtotal())}',
    );
    buffer.writeln(
      'Tax: ${NumberFormat.simpleCurrency(name: q.currency).format(q.totalTax())}',
    );
    buffer.writeln(
      'Grand total: ${NumberFormat.simpleCurrency(name: q.currency).format(q.grandTotal())}',
    );
    Share.share(buffer.toString(), subject: 'Quote for ${q.clientName}');
  }

  Future<void> _saveStatus(String status) async {
    setState(() => q.status = status);
    await _storage.updateQuote(widget.index, q);
    widget.onUpdated?.call();
  }

  Future<void> _delete() async {
    await _storage.deleteQuote(widget.index);
    widget.onUpdated?.call();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.simpleCurrency(name: q.currency);
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Quote')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Client: ${q.clientName}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(q.clientAddress),
                    const SizedBox(height: 8),
                    Text('Ref: ${q.reference}'),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: q.status,
                      items: const [
                        DropdownMenuItem(value: 'Draft', child: Text('Draft')),
                        DropdownMenuItem(value: 'Sent', child: Text('Sent')),
                        DropdownMenuItem(
                          value: 'Accepted',
                          child: Text('Accepted'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) _saveStatus(v);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: q.items.length,
                          itemBuilder: (_, i) {
                            final it = q.items[i];
                            return ListTile(
                              title: Text(it.name.isEmpty ? '(item)' : it.name),
                              subtitle: Text(
                                '${it.quantity} x ${currency.format(it.rate)}',
                              ),
                              trailing: Text(
                                currency.format(
                                  it.total(
                                    taxInclusive:
                                        q.taxMode == TaxMode.inclusive,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const Divider(),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Subtotal: ${currency.format(q.subtotal())}'),
                            Text('Tax: ${currency.format(q.totalTax())}'),
                            Text(
                              'Grand: ${currency.format(q.grandTotal())}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _share,
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _simulateSend,
                    icon: const Icon(Icons.send),
                    label: const Text('Send'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _delete,
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
