import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const MiaohuiApp());
}

class MiaohuiApp extends StatelessWidget {
  const MiaohuiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '秒回',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF6B6B),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF6B6B),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}
