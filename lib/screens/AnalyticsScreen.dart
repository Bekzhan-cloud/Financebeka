// Импорт необходимых пакетов
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Для отображения круговой диаграммы
import '../database/database_helper.dart'; // Подключение к базе данных

// Определение возможных периодов анализа
enum Period { today, month, year }

// Экран аналитики — stateful виджет
class AnalyticsScreen extends StatefulWidget {
  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  // По умолчанию выбран анализ за месяц
  Period _selectedPeriod = Period.month;

  // Загрузка и фильтрация транзакций по выбранному периоду
  Future<Map<String, dynamic>> _loadAnalytics(Period period) async {
    final txns = await DatabaseHelper.instance
        .getTransactions(); // Получение всех транзакций
    final now = DateTime.now();

    // Фильтрация транзакций по выбранному периоду
    List<Map<String, dynamic>> filtered = txns.where((t) {
      DateTime d = DateTime.parse(t['date'] as String);
      switch (period) {
        case Period.today:
          return d.year == now.year && d.month == now.month && d.day == now.day;
        case Period.month:
          return d.year == now.year && d.month == now.month;
        case Period.year:
          return d.year == now.year;
      }
    }).toList();

    // Расчёт доходов и расходов
    double totalIncome = 0;
    double totalExpense = 0;
    Map<String, double> expenseByCategory = {};

    for (var t in filtered) {
      final amount = (t['amount'] as num).toDouble();
      final type = t['type'] as String;
      final category = t['category'] as String? ?? 'Без категории';

      if (type == 'income') {
        totalIncome += amount; // Суммируем доходы
      } else {
        totalExpense += amount.abs(); // Суммируем расходы
        expenseByCategory[category] = (expenseByCategory[category] ?? 0) +
            amount.abs(); // Группировка расходов по категориям
      }
    }

    // Возвращаем готовые данные
    return {
      'income': totalIncome,
      'expense': totalExpense,
      'net': totalIncome - totalExpense,
      'byCategory': expenseByCategory,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Тёмный фон
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Аналитика'), // Заголовок
      ),
      body: Column(
        children: [
          // Переключатель периода (Сегодня / Месяц / Год)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: Period.values.map((p) {
                final label = {
                  Period.today: 'Сегодня',
                  Period.month: 'Месяц',
                  Period.year: 'Год',
                }[p]!;
                final selected = p == _selectedPeriod;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(label),
                    selected: selected,
                    onSelected: (_) => setState(() =>
                        _selectedPeriod = p), // Обновляем выбранный период
                    backgroundColor: Colors.grey[800],
                    selectedColor: Colors.red,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.grey[400],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Загрузка аналитики
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _loadAnalytics(
                  _selectedPeriod), // Загружаем данные по выбранному периоду
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator()); // Индикатор загрузки
                }
                if (snap.hasError) {
                  return Center(
                    child: Text('Ошибка загрузки',
                        style: TextStyle(color: Colors.red)),
                  ); // Сообщение об ошибке
                }

                // Распаковка полученных данных
                final data = snap.data!;
                final inc = data['income'] as double;
                final exp = data['expense'] as double;
                final net = data['net'] as double;
                final byCat = data['byCategory'] as Map<String, double>;

                // Создание секций круговой диаграммы
                final colors = [
                  Colors.red,
                  Colors.green,
                  Colors.orange,
                  Colors.purple,
                  Colors.yellow,
                  Colors.cyan,
                ]; // Список цветов для категорий

                final sections =
                    byCat.entries.toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  final e = entry.value;
                  return PieChartSectionData(
                    value: e.value,
                    title: e.value.toStringAsFixed(0),
                    radius: 50,
                    color: colors[index % colors.length],
                    titleStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList();

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Основные показатели
                      Text('Доход: ${inc.toStringAsFixed(0)} KGS',
                          style: TextStyle(color: Colors.green, fontSize: 16)),
                      Text('Расход: ${exp.toStringAsFixed(0)} KGS',
                          style: TextStyle(color: Colors.red, fontSize: 16)),
                      Text('Чистый: ${net.toStringAsFixed(0)} KGS',
                          style: TextStyle(
                              color: net >= 0 ? Colors.green : Colors.red,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 16),

                      // Проверка: есть ли вообще расходы
                      if (sections.isEmpty)
                        Center(
                          child: Text('Нет расходов за период',
                              style: TextStyle(color: Colors.white70)),
                        )
                      else
                        // Отображение круговой диаграммы
                        Expanded(
                          child: PieChart(
                            PieChartData(
                              sections: sections,
                              centerSpaceRadius: 30,
                              sectionsSpace: 2,
                            ),
                          ),
                        ),

                      SizedBox(height: 16),

                      // Список расходов по категориям
                      Text('Расходы по категориям:',
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                      Expanded(
                        child: ListView(
                          children: byCat.entries
                              .toList()
                              .asMap()
                              .entries
                              .map((entry) {
                            final index = entry.key;
                            final e = entry.value;
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: colors[
                                    index % colors.length], // Цвет категории
                                radius: 8,
                              ),
                              title: Text(e.key,
                                  style: TextStyle(color: Colors.white)),
                              trailing: Text(
                                '${e.value.toStringAsFixed(0)} KGS',
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
