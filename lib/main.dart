import 'package:flutter/material.dart';
import 'package:bhutan_news_app_flutter/home.dart';
import 'package:bhutan_news_app_flutter/main_screen.dart';

void main() {
  runApp(const Myapp());
}
class Myapp extends StatelessWidget {
  const Myapp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MainScreen()
    );
  }
}

