import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/database_helper.dart';
import '../models/add_account_screen.dart';

class HomeScreenContent extends StatefulWidget {
  @override
  _HomeScreenContentState createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  List<Map<String, dynamic>> accounts = [];

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final data = await DatabaseHelper.instance.getAccounts();
    if (mounted) {
      setState(() {
        accounts = data;
      });
    }
  }

  double getTotalBalance() {
    return accounts.fold(0.0, (sum, acc) => sum + (acc['balance'] ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        //Общий баланс
        title: Text(
          '${getTotalBalance().toStringAsFixed(0)} KGS',
          style: TextStyle(fontSize: 20),
        ),
        actions: [
          //IconButton(onPressed: () {}, icon: Icon(Icons.pie_chart)),
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddAccountScreen()),
              );
              _loadAccounts();
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: AccountListView(
        accounts: accounts,
        onRefresh: _loadAccounts,
      ),
    );
  } //header
}

class AccountListView extends StatelessWidget {
  final List<Map<String, dynamic>> accounts;
  final TextStyle amountStyle = TextStyle(fontSize: 16, color: Colors.white);
  final Function onRefresh;

  AccountListView({
    required this.accounts,
    required this.onRefresh,
  });
  //Счета
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: [
            sectionTitle("Банки"),
            for (var account in accounts)
              if (account['name'] != null && account['balance'] != null)
                accountRow(account['name'], account['balance'].toString()),
            //linkButton("Показать ещё счета"),
            sectionTitle("Накопления"),
            amountBox("13 466,83 KGS"),
            /*sectionTitle("Долги"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("10 000,00 KGS", style: amountStyle),
              Text(" / 0,00 KGS",
                  style: amountStyle.copyWith(color: Colors.grey)),
            ],
          ),
          SizedBox(height: 20),*/
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(title, style: TextStyle(fontSize: 16, color: Colors.white)),
    );
  }

  Widget accountRow(String name, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance,
                  color: Colors.white, size: 20), // Логотип
              SizedBox(width: 8), // Отступ между логотипом и названием
              Text(name, style: amountStyle),
            ],
          ),
          Row(
            children: [
              Text(amount, style: amountStyle),
              SizedBox(width: 4), // Отступ между суммой и валютой
              Text("KGS",
                  style: amountStyle.copyWith(color: Colors.grey)), // Валюта
            ],
          ),
        ],
      ),
    );
  }

  Widget amountBox(String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(amount, style: amountStyle),
    );
  }

  Widget linkButton(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: TextStyle(color: Colors.blueAccent, fontSize: 14),
      ),
    );
  }
}

//Планы
class PlansScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Center(child: Text('Планы', style: TextStyle(color: Colors.white)));
}

/*
//Аналитика
class AnalyticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
      child: Text('Аналитика', style: TextStyle(color: Colors.white)));
}*/
//Настройки
class MoreScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Center(child: Text('Ещё', style: TextStyle(color: Colors.red)));
}
