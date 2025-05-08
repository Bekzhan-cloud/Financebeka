import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/transaction.dart';
import '../models/add_transaction_screen.dart'; // Импортируем экран добавления транзакции

class OperationsScreen extends StatefulWidget {
  @override
  _OperationsScreenState createState() => _OperationsScreenState();
}

class _OperationsScreenState extends State<OperationsScreen> {
  List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  // Функция для загрузки транзакций
  Future<void> _loadTransactions() async {
    final data = await DatabaseHelper.instance.getTransactions();
    setState(() {
      transactions = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: RefreshIndicator(
        onRefresh: _loadTransactions, // Обновляем данные при тянущем обновлении
        child: transactions.isEmpty
            ? Center(child: Text("Нет транзакций", style: TextStyle(color: Colors.white)))
            : ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final tx = transactions[index];
            final txDate = DateTime.parse(tx['date']);
            final txDateStr =
                '${txDate.day.toString().padLeft(2, '0')}.${txDate.month.toString().padLeft(2, '0')}.${txDate.year}';

            // Показываем заголовок даты только если дата изменилась
            bool showDateHeader = index == 0 ||
                DateTime.parse(transactions[index - 1]['date']).day != txDate.day ||
                DateTime.parse(transactions[index - 1]['date']).month != txDate.month ||
                DateTime.parse(transactions[index - 1]['date']).year != txDate.year;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showDateHeader)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                    child: Text(
                      txDateStr,
                      style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                    ),
                  ),
                ListTile(
                  tileColor: tx['amount'] < 0 ? Colors.white10 : Colors.green.withOpacity(0.1),
                  title: Text(tx['category'], style: TextStyle(color: Colors.white)),
                  subtitle: Text(tx['account'], style: TextStyle(color: Colors.grey)),
                  trailing: Text(
                    '${tx['amount']} KGS',
                    style: TextStyle(
                      color: tx['amount'] < 0 ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Colors.grey[900],
                title: Text('Выберите тип', style: TextStyle(color: Colors.white)),
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(  // Обернул в Flexible адаптивный экран
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        icon: Icon(Icons.add, color: Colors.white),
                        label: Text('Доход', style: TextStyle(color: Colors.white,fontSize: 16,)),
                        onPressed: () async {
                          Navigator.pop(context); // закрыть диалог
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddTransactionScreen(type: 'income'),
                            ),
                          );
                          _loadTransactions(); // обновить список
                        },
                      ),
                    ),
                    Flexible(  // Обернул в Flexible адаптивный экран
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        icon: Icon(Icons.remove, color: Colors.white),
                        label: Text('Расход', style: TextStyle(color: Colors.white,fontSize: 16)),
                        onPressed: () async {
                          Navigator.pop(context); // закрыть диалог
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddTransactionScreen(type: 'expense'),
                            ),
                          );
                          _loadTransactions(); // обновить список
                        },
                      ),
                    ),
                  ],
                ),

              );
            },
          );
        },
      ),

    );
  }
}
