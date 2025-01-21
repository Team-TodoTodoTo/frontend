import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

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
      isFormValid = nameController.text.trim().isNotEmpty &&
          isValidEmail(emailController.text.trim()) &&
          passwordController.text.trim().length >= 8 &&
          passwordController.text.trim() ==
              confirmPasswordController.text.trim();
    });
  }

  @override
  void initState() {
    super.initState();
    // 입력 필드 상태 변경 감지 리스너 등록
    nameController.addListener(_validateForm);
    emailController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
    confirmPasswordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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
            const SizedBox(height: 50),
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                '이름',
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ),
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: '홍길동',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                border: const UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
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
                hintText: 'abcde@gmail.com',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                border: const UnderlineInputBorder(),
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
                hintText: '비밀번호 (8자 이상)',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                border: const UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                '비밀번호 확인',
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ),
            TextFormField(
              controller: confirmPasswordController,
              obscureText: true,
              obscuringCharacter: '*',
              decoration: InputDecoration(
                hintText: '비밀번호 확인',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                border: const UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: isFormValid
                  ? () {
                      Get.snackbar(
                        '가입 완료',
                        '회원가입이 완료되었습니다.',
                        backgroundColor: Colors.green.shade100,
                        snackPosition: SnackPosition.BOTTOM,
                      );
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
                '가입하기',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Get.offNamed('/login'); // 로그인 페이지로 이동
              },
              child: const Text(
                '닫기',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
