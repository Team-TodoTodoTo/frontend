import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todotodoto/src/home.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => Home(),
      },
      initialRoute: '/',
    );
  }
}
