import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class AddAccountScreen extends StatefulWidget {
  @override
  _AddAccountScreenState createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Добавить счёт')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Название счёта'),
              style: TextStyle(color: Colors.white),
            ),
            TextField(
              controller: _balanceController,
              decoration: InputDecoration(labelText: 'Начальный баланс'),
              keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final name = _nameController.text.trim();
                final balance = double.tryParse(_balanceController.text) ?? 0.0;

                // Проверка: имя пустое?
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Введите название счёта')),
                  );
                  return;
                }

                // Проверка: баланс отрицательный?
                if (balance < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Баланс не может быть отрицательным')),
                  );
                  return;
                }

                // Проверка: счёт с таким именем уже есть?
                final existing = await DatabaseHelper.instance.getAccountByName(name);
                if (existing != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Счёт с таким именем уже существует')),
                  );
                  return;
                }

                // Сохраняем счёт
                await DatabaseHelper.instance.insertAccount({
                  'name': name,
                  'balance': balance,
                });

                Navigator.pop(context); // Закрыть экран после добавления
              },
              child: Text('Добавить'),
            ),
          ],
        ),
      ),
    );
  }
}
