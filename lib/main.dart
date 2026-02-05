import 'package:flutter/material.dart';
import 'package:operation_brotherhood/core/utils/theme.dart';
import 'package:operation_brotherhood/features/home/presentation/screens/home_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:operation_brotherhood/core/services/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Habit Tracker App',
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
