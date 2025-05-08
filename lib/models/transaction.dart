class TransactionModel {
  final int id;
  final String title;
  final double amount;
  final String date;
  final String category;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: map['date'],
      category: map['category'],
    );
  }
}
