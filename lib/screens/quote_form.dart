import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/quote.dart';
import '../models/quote_item.dart';
import 'preview_clean.dart';
import 'saved_quote_detail.dart';
import '../services/storage_service.dart';

class QuoteFormScreen extends StatefulWidget {
  const QuoteFormScreen({super.key});

  @override
  State<QuoteFormScreen> createState() => _QuoteFormScreenState();
}

class _QuoteFormScreenState extends State<QuoteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  Quote quote = Quote(items: [QuoteItem()]);
  final StorageService _storage = StorageService();

  late NumberFormat currencyFormat;

  @override
  void initState() {
    super.initState();
    _updateCurrencyFormat();
  }

  void _updateCurrencyFormat() {
    currencyFormat = NumberFormat.simpleCurrency(name: quote.currency);
  }

  void _addItem() {
    setState(
      () => quote.items = List<QuoteItem>.from(quote.items)..add(QuoteItem()),
    );
  }

  void _removeItem(int index) {
    setState(() {
      final list = List<QuoteItem>.from(quote.items);
      list.removeAt(index);
      quote.items = list;
    });
  }

  void _onChanged() => setState(() {});

  Widget _buildItemRow(int index) {
    final item = quote.items[index];
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    initialValue: item.name,
                    decoration: const InputDecoration(
                      labelText: 'Product / Service',
                    ),
                    onChanged: (v) => item.name = v,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: item.quantity.toString(),
                    decoration: const InputDecoration(labelText: 'Qty'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => item.quantity = double.tryParse(v) ?? 0,
                    onEditingComplete: _onChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: item.rate.toString(),
                    decoration: const InputDecoration(labelText: 'Rate'),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (v) => item.rate = double.tryParse(v) ?? 0,
                    onEditingComplete: _onChanged,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: item.discount.toString(),
                    decoration: const InputDecoration(labelText: 'Discount'),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (v) => item.discount = double.tryParse(v) ?? 0,
                    onEditingComplete: _onChanged,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: item.taxPercent.toString(),
                    decoration: const InputDecoration(labelText: 'Tax %'),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (v) => item.taxPercent = double.tryParse(v) ?? 0,
                    onEditingComplete: _onChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Item total: ${currencyFormat.format(item.total(taxInclusive: quote.taxMode == TaxMode.inclusive))}',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: quote.items.length > 1
                      ? () => _removeItem(index)
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Quote Builder'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'save') {
                await _storage.saveQuote(quote);
                if (!mounted) return;
                // Safe to show snackbar after mounted check.
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Quote saved locally')),
                );
                // Trigger a rebuild so the Saved Quotes FutureBuilder reloads
                setState(() {});
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'save', child: Text('Save locally')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Client Info',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: quote.clientName,
                        decoration: const InputDecoration(
                          labelText: 'Client name',
                        ),
                        onChanged: (v) => quote.clientName = v,
                      ),
                      TextFormField(
                        initialValue: quote.clientAddress,
                        decoration: const InputDecoration(labelText: 'Address'),
                        onChanged: (v) => quote.clientAddress = v,
                      ),
                      TextFormField(
                        initialValue: quote.reference,
                        decoration: const InputDecoration(
                          labelText: 'Reference',
                        ),
                        onChanged: (v) => quote.reference = v,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text('Tax mode: '),
                          const SizedBox(width: 8),
                          DropdownButton<TaxMode>(
                            value: quote.taxMode,
                            items: const [
                              DropdownMenuItem(
                                value: TaxMode.exclusive,
                                child: Text('Tax exclusive'),
                              ),
                              DropdownMenuItem(
                                value: TaxMode.inclusive,
                                child: Text('Tax inclusive'),
                              ),
                            ],
                            onChanged: (v) => setState(
                              () => quote.taxMode = v ?? TaxMode.exclusive,
                            ),
                          ),
                          const Spacer(),
                          DropdownButton<String>(
                            value: quote.currency,
                            items: const [
                              DropdownMenuItem(
                                value: 'USD',
                                child: Text('USD'),
                              ),
                              DropdownMenuItem(
                                value: 'EUR',
                                child: Text('EUR'),
                              ),
                              DropdownMenuItem(
                                value: 'INR',
                                child: Text('INR'),
                              ),
                            ],
                            onChanged: (v) => setState(() {
                              quote.currency = v ?? 'USD';
                              _updateCurrencyFormat();
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Line Items',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: quote.items.length,
                        itemBuilder: (_, i) => _buildItemRow(i),
                      ),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _addItem,
                            icon: const Icon(Icons.add),
                            label: const Text('Add item'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PreviewCleanScreen(quote: quote),
                                ),
                              );
                            },
                            icon: const Icon(Icons.visibility),
                            label: const Text('Preview'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Card(
                        color: Colors.grey.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Subtotal: ${currencyFormat.format(quote.subtotal())}',
                              ),
                              Text(
                                'Tax: ${currencyFormat.format(quote.totalTax())}',
                              ),
                              Text(
                                'Grand total: ${currencyFormat.format(quote.grandTotal())}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Saved Quotes (from local storage)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FutureBuilder<List<Quote>>(
                        future: _storage.loadQuotes(),
                        builder: (context, snap) {
                          if (!snap.hasData) {
                            return const Text('Loading...');
                          }
                          final list = snap.data!;
                          if (list.isEmpty) {
                            return const Text('No saved quotes');
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: list.length,
                            itemBuilder: (context, i) {
                              final q = list[i];
                              return ListTile(
                                title: Text(
                                  q.clientName.isEmpty
                                      ? '(No client)'
                                      : q.clientName,
                                ),
                                subtitle: Text(
                                  'Total: ${currencyFormat.format(q.grandTotal())} - ${q.status}',
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () async {
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => SavedQuoteDetail(
                                        quote: q,
                                        index: i,
                                        onUpdated: () {
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                  );
                                  setState(() {});
                                },
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
