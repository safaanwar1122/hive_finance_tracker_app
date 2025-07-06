import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_financial_tracker_app/models/category_model.dart';
import 'package:hive_financial_tracker_app/models/monthly_report_model.dart';
import 'package:hive_financial_tracker_app/models/transaction_model.dart';
import 'package:hive_financial_tracker_app/screens/auth_screen.dart';
import 'package:hive_financial_tracker_app/screens/backuo_restore_screen.dart';
import 'package:hive_financial_tracker_app/screens/last_month_report_screen.dart';
import 'package:hive_financial_tracker_app/screens/recent_report_screen.dart';
import 'package:hive_financial_tracker_app/screens/settings_screen.dart';
import 'package:hive_financial_tracker_app/screens/transaction_list_screen.dart';
import 'package:hive_financial_tracker_app/viewmodel_controller/theme_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'screens/add_transaction_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/category_screen.dart';
import 'screens/dash_board_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var appDocDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocDir.path);
  // Register adapters
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(CategoryModelAdapter());
  Hive.registerAdapter(MonthlyReportModelAdapter());
  // Optionally clear boxes for testing (uncomment only when needed)
  //await Hive.deleteBoxFromDisk('transactions');
  //await Hive.deleteBoxFromDisk('monthlyReports');
  // Open boxes
  await Hive.openBox<TransactionModel>('transactions');
  await Hive.openBox<CategoryModel>('categories');
  await Hive.openBox<MonthlyReportModel>('monthlyReports');

  var categoryBox = Hive.box<CategoryModel>('categories');
  var transactionBox = Hive.box<TransactionModel>('transactions');

  if (categoryBox.isEmpty) {
    final defaultCategories = ['Food', 'Salary', 'Travel', 'Shopping', 'Misc'];
    for (var categoryName in defaultCategories) {
      categoryBox.add(CategoryModel(categoryName: categoryName));
    }
    print("Added default categories");
  }
//Add test transactions for June 2025

 /* if (transactionBox.isEmpty) {
    await transactionBox.addAll([
      TransactionModel(
        amount: 5000,
        description: 'Salary for July',
        category: 'Salary',
        date: DateTime.now().subtract(const Duration(minutes: 1)),
        isIncome: true,
      ),
      TransactionModel(
        amount: 2000,
        description: 'Grocery Shopping',
        category: 'Food',
        date: DateTime.now().subtract(const Duration(minutes: 1, seconds: 30)),
        isIncome: false,
      ),
      TransactionModel(
        amount: 1000,
        description: 'Travel Expense',
        category: 'Travel',
        date: DateTime.now().subtract(const Duration(seconds: 30)),
        isIncome: false,
      ),
    ]);
    print("Added test transactions for June 2025");
  }*/
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
 //   final transactionBox=Hive.box<TransactionModel>('transactions');
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Flutter Demo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(

              /*colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,*/
              ),
          darkTheme: ThemeData.dark(),
          themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
          home: const AuthenticationScreen(),
          routes: {
            '/authScreen': (context) => AuthenticationScreen(),
            '/dashboard': (context) => DashboardScreen(),
            '/add-transaction': (context) => AddTransactionScreen(),
            '/transactions': (context) => TransactionListScreen(),
            '/categories': (context) => CategoryScreen(),
            '/analytics': (context) => AnalyticsScreen(),
            '/settings': (context) => SettingsScreen(),
            '/backup': (context) => BackupRestoreScreen(),
            '/monthlyReport': (context) => RecentReportScreen(),
          },
        );
      },
    );
  }
}
