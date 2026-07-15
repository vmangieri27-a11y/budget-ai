class Transaction {
  final int? id;
  final DateTime date;
  final String description;
  final double amount;
  final String category;
  final bool isManual;

  Transaction({
    this.id,
    required this.date,
    required this.description,
    required this.amount,
    required this.category,
    this.isManual = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date.toIso8601String(),
        'description': description,
        'amount': amount,
        'category': category,
        'isManual': isManual ? 1 : 0,
      };

  factory Transaction.fromMap(Map<String, dynamic> map) => Transaction(
        id: map['id'],
        date: DateTime.parse(map['date']),
        description: map['description'],
        amount: map['amount'],
        category: map['category'],
        isManual: map['isManual'] == 1,
      );
}