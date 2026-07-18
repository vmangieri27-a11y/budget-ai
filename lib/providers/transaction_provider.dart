import 'package:flutter/material.dart';
import '../models/transaction.dart' as model;
import '../db/database_helper.dart';

enum DateFilterPeriod { tutti, questoMese, meseScorso, questoAnno }

class ImportSummary {
  final int imported;
  final int duplicatesSkipped;
  final int oldImportedReplaced;
  final int manualRemoved;

  ImportSummary({
    required this.imported,
    required this.duplicatesSkipped,
    required this.oldImportedReplaced,
    required this.manualRemoved,
  });
}

class TransactionProvider extends ChangeNotifier {
  List<model.Transaction> _transactions = [];
  bool isLoading = false;
  String? lastError;

  DateFilterPeriod selectedPeriod = DateFilterPeriod.tutti;

  List<model.Transaction> get transactions => _transactions;

  void setPeriod(DateFilterPeriod period) {
    selectedPeriod = period;
    notifyListeners();
  }

  DateTimeRange? get _periodRange {
    final now = DateTime.now();
    switch (selectedPeriod) {
      case DateFilterPeriod.tutti:
        return null;
      case DateFilterPeriod.questoMese:
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 1);
        return DateTimeRange(start: start, end: end);
      case DateFilterPeriod.meseScorso:
        final start = DateTime(now.year, now.month - 1, 1);
        final end = DateTime(now.year, now.month, 1);
        return DateTimeRange(start: start, end: end);
      case DateFilterPeriod.questoAnno:
        final start = DateTime(now.year, 1, 1);
        final end = DateTime(now.year + 1, 1, 1);
        return DateTimeRange(start: start, end: end);
    }
  }

  /// Transazioni filtrate in base al periodo attualmente selezionato.
  /// Usato sia dalla Home (statistiche) sia dalla lista Movimenti.
  List<model.Transaction> get transactionsForPeriod {
    final range = _periodRange;
    if (range == null) return _transactions;
    return _transactions
        .where((t) => !t.date.isBefore(range.start) && t.date.isBefore(range.end))
        .toList();
  }

  double get balance =>
      transactionsForPeriod.fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpenses => transactionsForPeriod
      .where((t) => t.amount < 0)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalIncome => transactionsForPeriod
      .where((t) => t.amount > 0)
      .fold(0.0, (sum, t) => sum + t.amount);

  Map<String, double> get expensesByCategory {
    final map = <String, double>{};
    for (final t in transactionsForPeriod.where((t) => t.amount < 0)) {
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

  String _normalize(String s) =>
      s.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Importa un estratto conto completo.
  ///
  /// - Rimuove i vecchi movimenti IMPORTATI che ricadono nello stesso periodo
  ///   coperto dal nuovo estratto (il nuovo file li sostituisce interamente).
  /// - Rimuove eventuali movimenti MANUALI già presenti che risultano identici
  ///   (stessa descrizione + stessa data) a un movimento del nuovo estratto,
  ///   per evitare di contarli due volte.
  /// - Scarta i doppioni interni al file stesso (stessa descrizione + data).
  Future<ImportSummary> importStatement(List<model.Transaction> imported) async {
    if (imported.isEmpty) {
      return ImportSummary(
        imported: 0,
        duplicatesSkipped: 0,
        oldImportedReplaced: 0,
        manualRemoved: 0,
      );
    }

    // 1. Dedup interno al file appena importato
    final seen = <String>{};
    final deduped = <model.Transaction>[];
    int duplicatesSkipped = 0;
    for (final t in imported) {
      final key =
          '${_normalize(t.description)}|${t.date.year}-${t.date.month}-${t.date.day}';
      if (seen.contains(key)) {
        duplicatesSkipped++;
        continue;
      }
      seen.add(key);
      deduped.add(t);
    }

    // 2. Periodo coperto dal nuovo estratto
    final dates = deduped.map((t) => t.date).toList();
    final minDate = dates.reduce((a, b) => a.isBefore(b) ? a : b);
    final maxDate = dates.reduce((a, b) => a.isAfter(b) ? a : b);
    final rangeStart = DateTime(minDate.year, minDate.month, minDate.day);
    final rangeEnd =
        DateTime(maxDate.year, maxDate.month, maxDate.day, 23, 59, 59);

    // 3. Rimuovi i vecchi movimenti IMPORTATI nello stesso periodo
    final oldImported = _transactions
        .where((t) =>
            !t.isManual &&
            !t.date.isBefore(rangeStart) &&
            !t.date.isAfter(rangeEnd))
        .toList();
    for (final t in oldImported) {
      if (t.id != null) {
        await DatabaseHelper.instance.deleteTransaction(t.id!);
      }
    }
    _transactions.removeWhere((t) => oldImported.contains(t));

    // 4. Rimuovi eventuali movimenti MANUALI già coperti dal nuovo estratto
    int manualRemoved = 0;
    final manualInRange = _transactions
        .where((t) =>
            t.isManual &&
            !t.date.isBefore(rangeStart) &&
            !t.date.isAfter(rangeEnd))
        .toList();
    for (final manual in manualInRange) {
      final matches = deduped.any((imp) =>
          _normalize(imp.description) == _normalize(manual.description) &&
          _sameDay(imp.date, manual.date));
      if (matches) {
        if (manual.id != null) {
          await DatabaseHelper.instance.deleteTransaction(manual.id!);
        }
        _transactions.removeWhere((t) => t.id == manual.id);
        manualRemoved++;
      }
    }

    // 5. Inserisci i nuovi movimenti
    for (final t in deduped) {
      final inserted = await DatabaseHelper.instance.insertTransaction(t);
      _transactions.insert(0, inserted);
    }

    _transactions.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();

    return ImportSummary(
      imported: deduped.length,
      duplicatesSkipped: duplicatesSkipped,
      oldImportedReplaced: oldImported.length,
      manualRemoved: manualRemoved,
    );
  }
}