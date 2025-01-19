import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todotodoto/src/screens/todo/screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => TodoScreen(),
      },
      initialRoute: '/',
    );
  }
}
