import 'package:flutter/material.dart';
import '../models/transaction.dart' as model;
import '../db/database_helper.dart';

class TransactionProvider extends ChangeNotifier {
  List<model.Transaction> _transactions = [];
  bool isLoading = false;
  String? lastError;

  List<model.Transaction> get transactions => _transactions;

  double get balance => _transactions.fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpenses => _transactions
      .where((t) => t.amount < 0)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalIncome => _transactions
      .where((t) => t.amount > 0)
      .fold(0.0, (sum, t) => sum + t.amount);

  Map<String, double> get expensesByCategory {
    final map = <String, double>{};
    for (final t in _transactions.where((t) => t.amount < 0)) {
      map[t.category] = (map[t.category] ?? 0) + t.amount.abs();
    }
    return map;
  }

  Future<void> loadTransactions() async {
    isLoading = true;
    notifyListeners();
    try {
      _transactions = await DatabaseHelper.instance.getAllTransactions();
      lastError = null;
    } catch (e) {
      lastError = 'Errore caricamento dati: $e';
    }
    isLoading = false;
    notifyListeners();
  }

  Future<bool> addTransaction(model.Transaction t) async {
    try {
      final inserted = await DatabaseHelper.instance.insertTransaction(t);
      _transactions.insert(0, inserted);
      lastError = null;
      notifyListeners();
      return true;
    } catch (e) {
      lastError = 'Errore salvataggio: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await DatabaseHelper.instance.deleteTransaction(id);
      _transactions.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      lastError = 'Errore eliminazione: $e';
      notifyListeners();
    }
  }
}