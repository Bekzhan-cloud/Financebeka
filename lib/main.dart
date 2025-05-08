import 'package:flutter/material.dart';
import 'screens/Home.dart';
import 'screens/OperationsScreen.dart';
import 'screens/AnalyticsScreen.dart';
import 'screens/settings.dart';
import 'package:google_fonts/google_fonts.dart';
void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  // Здесь определяем глобальные параметры для приложения
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Manager',
      theme: ThemeData(
        primarySwatch: Colors.red,
        textTheme: GoogleFonts.montserratTextTheme(),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          titleTextStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.black,
          selectedItemColor: Colors.red,
          unselectedItemColor: Colors.grey,
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: _onGenerateRoute,
      // Гибкое использование роутов с передачей данных через arguments
    );
  }

  // Управление роутами через onGenerateRoute
  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case '/operations':
        return MaterialPageRoute(builder: (_) => OperationsScreen());
      case '/settings':
        return MaterialPageRoute(builder: (_) => SettingsScreen());
      default:
        return MaterialPageRoute(builder: (_) => HomeScreen()); // Default route
    }
  }
}
// модуль реализует главный экран с навигацией в нижней части (Bottom Navigation Bar) для
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}
// Состояние главного экрана
class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // Индекс текущей выбранной вкладки

  // Список экранов, которые отображаются в зависимости от выбранной вкладки
  final List<Widget> _screens = [
    HomeScreenContent(), // Экран "Счета"
    OperationsScreen(),  // Экран "Операции"
    PlansScreen(),       // Экран "Планы"
    AnalyticsScreen(),   // Экран "Аналитика"
    MoreScreen(),        // Экран "Ещё" настройки
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Фон всего экрана — чёрный
      body: _screens[_currentIndex], // Отображаем активный экран из списка
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black, // Чёрный фон панели навигации
        selectedItemColor: Colors.red, // Цвет выбранной иконки и текста
        unselectedItemColor: Colors.grey, // Цвет невыбранных иконок и текста
        currentIndex: _currentIndex, // Текущий выбранный индекс
        onTap: (index) {
          // Обработка нажатий по вкладкам
          setState(() {
            _currentIndex = index; // Обновляем текущий индекс
          });
        },
        items: [
          // Элементы нижней панели навигации
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet), label: 'Счета'),
          BottomNavigationBarItem(
              icon: Icon(Icons.compare_arrows), label: 'Операции'),
          BottomNavigationBarItem(
              icon: Icon(Icons.credit_card), label: 'Планы'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: 'Аналитика'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Ещё'),
        ],
      ),
    );
  }
}