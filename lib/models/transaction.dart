class Transaction {
  final int? id;
  final DateTime date;
  final String description;
  final double amount;
  final String category;
  final bool isManual;
  final String? source;

  Transaction({
    this.id,
    required this.date,
    required this.description,
    required this.amount,
    required this.category,
    this.isManual = false,
    this.source,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date.toIso8601String(),
        'description': description,
        'amount': amount,
        'category': category,
        'isManual': isManual ? 1 : 0,
        'source': source,
      };

  factory Transaction.fromMap(Map<String, dynamic> map) => Transaction(
        id: map['id'] as int?,
        date: DateTime.parse(map['date']),
        description: map['description'],
        amount: (map['amount'] as num).toDouble(),
        category: map['category'],
        isManual: map['isManual'] == 1,
        source: map['source'],
      );
}