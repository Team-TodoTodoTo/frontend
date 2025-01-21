import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isFormValid = false;
  bool isLoading = false;

  // 이메일 유효성 검사
  bool isValidEmail(String email) {
    final RegExp emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegExp.hasMatch(email);
  }

  // 입력 필드 상태 감지
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

  Future<void> _login() async {
    setState(() {
      isLoading = true;
    });

    const String apiUrl = 'http://localhost:4000/auth/login';

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    final Map<String, String> body = {
      "email": emailController.text.trim(),
      "password": passwordController.text.trim(),
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final String accessToken = responseData['accessToken'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', accessToken);

        Get.snackbar('로그인 성공', '환영합니다!',
            backgroundColor: Colors.green.shade100,
            snackPosition: SnackPosition.BOTTOM);

        Get.offNamed('/');
      } else {
        Get.snackbar('로그인 실패', '이메일 또는 비밀번호가 올바르지 않습니다.',
            backgroundColor: Colors.red.shade100,
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('오류 발생', '서버와의 통신에 실패했습니다.',
          backgroundColor: Colors.red.shade100,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
            const Text('로그인',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 80),
            _buildInputField('이메일', emailController, false),
            _buildInputField('비밀번호', passwordController, true),
            const SizedBox(height: 60),
            ElevatedButton(
              onPressed: isFormValid && !isLoading ? _login : null,
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
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('로그인',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Get.toNamed('/signin'),
              child: const Text('회원가입 하러가기',
                  style: TextStyle(fontSize: 14, color: Colors.black45)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
      String label, TextEditingController controller, bool obscureText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, color: Colors.black87)),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            border: const UnderlineInputBorder(),
            hintText: '$label을 입력하세요',
            hintStyle: TextStyle(color: Colors.grey.shade400),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
