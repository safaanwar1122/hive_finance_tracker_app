import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_financial_tracker_app/models/category_model.dart';
import 'package:hive_financial_tracker_app/models/transaction_model.dart';
import 'package:hive_financial_tracker_app/screens/auth_screen.dart';
import 'package:hive_financial_tracker_app/screens/backuo_restore_screen.dart';
import 'package:hive_financial_tracker_app/screens/settings_screen.dart';
import 'package:hive_financial_tracker_app/screens/transaction_list_screen.dart';
import 'package:hive_financial_tracker_app/viewmodel_controller/theme_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'screens/add_transaction_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/category_screen.dart';
import 'screens/dash_board_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  var appDocDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocDir.path);
  Hive.registerAdapter(TransactionModelAdapter());
 // await Hive.deleteBoxFromDisk('transactions');
  await Hive.openBox<TransactionModel>('transactions');
  Hive.registerAdapter(CategoryModelAdapter());
  await Hive.openBox<CategoryModel>('categories');
  var categoryBox=Hive.box<CategoryModel>('categories');
  if(categoryBox.isEmpty){
    final defaultCategories=['Food', 'Salary', 'Travel', 'Shopping', 'Misc'];
    for(var categoryName in defaultCategories){
      categoryBox.add(CategoryModel(categoryName: categoryName));
    }
  }

  runApp(
      ChangeNotifierProvider(create: (_)=>ThemeProvider(),
      child: const MyApp(),
      ),
      );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child){
        return  MaterialApp(
          title: 'Flutter Demo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(

            /*colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,*/
          ),
          darkTheme: ThemeData.dark(),
          themeMode: themeProvider.isDark?ThemeMode.dark:ThemeMode.light,
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
          },
        );
      },

    );
  }
}
