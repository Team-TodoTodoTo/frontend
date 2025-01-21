import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'layout/main_layout.dart';
import 'screens/auth/login.dart';
import 'screens/auth/signin.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: Get.key,
      initialRoute: '/login', // 초기 경로를 로그인 페이지로 설정
      getPages: [
        GetPage(name: '/', page: () => const MainLayout()),
        GetPage(name: '/login', page: () => LoginPage()), // 로그인 페이지
        GetPage(name: '/signin', page: () => SigninPage()), // 회원가입 페이지
      ],
      unknownRoute:
          GetPage(name: '/notfound', page: () => const NotFoundPage()),
    );
  }
}

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('페이지를 찾을 수 없습니다.')),
    );
  }
}
