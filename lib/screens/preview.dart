import 'package:flutter/material.dart';
import 'preview_clean.dart';
import '../models/quote.dart';

/// Lightweight adapter that forwards to the cleaned preview screen implementation.
class PreviewScreen extends StatelessWidget {
  final Quote quote;
  const PreviewScreen({super.key, required this.quote});

  @override
  Widget build(BuildContext context) => PreviewCleanScreen(quote: quote);
}
