import 'package:flutter/material.dart';
import 'package:flutter_german/app_colors.dart';
import 'package:flutter_german/screens/input_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        cardTheme: CardThemeData(color: AppColors.primaryCard),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: AppColors.primaryText,
            backgroundColor: AppColors.primaryAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          ),
        ),
      ),
      home: Scaffold(body: Center(child: InputScreen())),
    );
  }
}
