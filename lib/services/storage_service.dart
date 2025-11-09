import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quote.dart';

class StorageService {
  static const _key = 'saved_quotes_v1';

  Future<void> saveQuote(Quote q) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    list.add(jsonEncode(q.toJson()));
    await prefs.setStringList(_key, list);
  }

  Future<List<Quote>> loadQuotes() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.map((e) => Quote.fromJson(jsonDecode(e))).toList();
  }

  Future<void> saveAll(List<Quote> quotes) async {
    final prefs = await SharedPreferences.getInstance();
    final list = quotes.map((q) => jsonEncode(q.toJson())).toList();
    await prefs.setStringList(_key, list);
  }

  Future<void> updateQuote(int index, Quote q) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    if (index < 0 || index >= list.length) return;
    list[index] = jsonEncode(q.toJson());
    await prefs.setStringList(_key, list);
  }

  Future<void> deleteQuote(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    if (index < 0 || index >= list.length) return;
    list.removeAt(index);
    await prefs.setStringList(_key, list);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
