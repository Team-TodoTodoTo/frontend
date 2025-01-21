import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isFormValid = false;

  // 이메일 유효성 검사 함수
  bool isValidEmail(String email) {
    final RegExp emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegExp.hasMatch(email);
  }

  // 입력 필드 상태 변경 감지 및 버튼 활성화 로직
  void _validateForm() {
    setState(() {
      isFormValid = isValidEmail(emailController.text.trim()) &&
          passwordController.text.trim().isNotEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
    emailController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 100),
            const Text(
              '정보입력',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 80),
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                '이메일',
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                hintText: '이메일을 입력하세요',
                hintStyle: TextStyle(color: Colors.grey.shade400),
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                '비밀번호',
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              obscuringCharacter: '*',
              decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                hintText: '비밀번호를 입력하세요',
                hintStyle: TextStyle(color: Colors.grey.shade400),
              ),
            ),
            const SizedBox(height: 60),
            ElevatedButton(
              onPressed: isFormValid
                  ? () {
                      String email = emailController.text.trim();
                      String password = passwordController.text.trim();

                      if (!isValidEmail(email)) {
                        Get.snackbar(
                          '입력 오류',
                          '유효한 이메일을 입력하세요.',
                          backgroundColor: Colors.red.shade100,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      } else {
                        // 유효한 이메일 및 비밀번호 입력 시 홈 화면으로 이동
                        Get.offNamed('/');
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isFormValid
                    ? const Color(0xFF397EC3)
                    : Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                '로그인',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Get.toNamed('/signin'); // 회원가입 페이지로 이동
              },
              child: const Text(
                '회원가입 하러가기',
                style: TextStyle(fontSize: 14, color: Colors.black45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
