import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class AddTransactionScreen extends StatefulWidget {
  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
  final String type; // 'income' или 'expense'

  AddTransactionScreen({required this.type});

}

class _AddTransactionScreenState extends State<AddTransactionScreen> {

  List<Map<String, dynamic>> accounts = []; //массив счетов
  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }
  List<Map<String, dynamic>> get currentCategories =>
      widget.type == 'income' ? incomeCategories : expenseCategories;


  Future<void> _loadAccounts() async {
    final data = await DatabaseHelper.instance.getAccounts();
    if (mounted) {
      setState(() {
        accounts = data;
        if (accounts.isNotEmpty) {
          account = accounts[0]['name']; // допустим, в таблице поле называется 'name'
        }
      });
    }
  }

  final _formKey = GlobalKey<FormState>();

  double amount = 0.0;
  String category = '';
  String account = '';
  DateTime selectedDate = DateTime.now();
  String place = '';
  String comment = '';
  bool repeat = false;

  List<Map<String, dynamic>> incomeCategories = [
    {'label': 'Зарплата', 'icon': Icons.attach_money},
    {'label': 'Подарок', 'icon': Icons.card_giftcard},
    {'label': 'Возврат', 'icon': Icons.undo},
  ];

  List<Map<String, dynamic>> expenseCategories = [
    {'label': 'Проезд', 'icon': Icons.directions_bus},
    {'label': 'Обед', 'icon': Icons.lunch_dining},
    {'label': 'Фаст фуд', 'icon': Icons.fastfood},
    {'label': 'Покупки', 'icon': Icons.shopping_cart},
    {'label': 'Другое', 'icon': Icons.more_horiz},
  ];


  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  Future<void> _saveTransaction() async {
    if (amount <= 0 || category.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Заполните сумму и выберите категорию'),
      ));
      return;
    }

    try {
      final adjustedAmount = widget.type == 'expense' ? -amount : amount;

      await DatabaseHelper.instance.insertTransaction({
        'title': comment.isEmpty ? category : comment,
        'amount': adjustedAmount, // здесь тоже поправим
        'category': category,
        'account': account,
        'date': selectedDate.toIso8601String(),
        'place': place,
        'repeat': repeat ? 1 : 0,
        'type': widget.type // <-- добавим тип
      });


      Navigator.pop(context);
    } catch (e) {
      print("Ошибка при сохранении транзакции: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.type == 'income' ? 'Доход' : 'Расход'),
        actions: [
          TextButton(
            onPressed: _saveTransaction,
            child: Text('Сохранить', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Ввод суммы
            TextFormField(
              keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.white, fontSize: 36),
              decoration: InputDecoration(
                hintText: '0 c',
                hintStyle: TextStyle(color: Colors.white30, fontSize: 36),
                border: InputBorder.none,
              ),
              onChanged: (value) =>
              amount = double.tryParse(value.replaceAll(',', '.')) ?? 0.0,
            ),
            SizedBox(height: 16),

            // Категории
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: currentCategories.length,
                itemBuilder: (context, index) {
                  final item = currentCategories[index];
                  final isSelected = category == item['label'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        category = item['label'];
                      });
                    },
                    child: Container(
                      width: 80,
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color:
                        isSelected ? Colors.white12 : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.white24,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(item['icon'], color: Colors.white),
                          SizedBox(height: 4),
                          Text(item['label'],
                              style: TextStyle(
                                  color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            accounts.isNotEmpty
                ? DropdownButtonFormField<String>(
              value: account.isNotEmpty ? account : null,
              dropdownColor: Colors.black,
              style: TextStyle(color: Colors.white),
              onChanged: (String? newValue) {
                setState(() {
                  account = newValue!;
                });
              },
              items: accounts.map<DropdownMenuItem<String>>((acc) {
                return DropdownMenuItem<String>(
                  value: acc['name'],
                  child: Text(acc['name'], style: TextStyle(color: Colors.white)),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Счёт',
                labelStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            )
                : Center(
              child: CircularProgressIndicator(),
            ),


            // дата
              Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Дата:',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: Text(
                    '${selectedDate.day.toString().padLeft(2, '0')}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.year}',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),


            // Место платежа
            TextFormField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                  labelText: 'Место платежа',
                  labelStyle: TextStyle(color: Colors.white54)),
              onChanged: (value) => place = value,
            ),

            // Комментарий
            TextFormField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                  labelText: 'Комментарий',
                  labelStyle: TextStyle(color: Colors.white54)),
              onChanged: (value) => comment = value,
            ),

            // Повтор
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Повторять операцию',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                Switch(
                  value: repeat,
                  onChanged: (value) {
                    setState(() {
                      repeat = value;
                    });
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
