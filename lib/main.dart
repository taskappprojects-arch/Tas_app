import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_app/providers/task_provider.dart';
import 'package:todo_app/providers/language_provider.dart';
import 'package:todo_app/providers/finance_provider.dart';
import 'package:todo_app/providers/khata_provider.dart';
import 'package:todo_app/providers/user_provider.dart';
import 'package:todo_app/screens/splash_screen.dart';
import 'package:todo_app/utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  
  // Open Hive Boxes
  await Hive.openBox<String>('tasksBox');
  await Hive.openBox<String>('financeBox');
  await Hive.openBox<String>('khataBox');
  await Hive.openBox<String>('userBox');
  await Hive.openBox('settingsBox');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => FinanceProvider()),
        ChangeNotifierProvider(create: (_) => KhataProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My To-Do App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
