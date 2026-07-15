import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart' as model;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  DatabaseHelper._init();

  static const String _boxName = 'transactions';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  Box get _box => Hive.box(_boxName);

  Future<model.Transaction> insertTransaction(model.Transaction t) async {
    final map = t.toMap();
    final key = await _box.add(map);
    return model.Transaction(
      id: key,
      date: t.date,
      description: t.description,
      amount: t.amount,
      category: t.category,
      isManual: t.isManual,
    );
  }

  Future<List<model.Transaction>> getAllTransactions() async {
    final entries = _box.toMap();
    final list = entries.entries.map((e) {
      final map = Map<String, dynamic>.from(e.value as Map);
      map['id'] = e.key;
      return model.Transaction.fromMap(map);
    }).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Future<void> deleteTransaction(int id) async {
    await _box.delete(id);
  }
}