import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  bool isLoading = false;

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

  Future<void> _signup() async {
    setState(() {
      isLoading = true;
    });

    const String url = 'http://localhost:4000/auth/signup';

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    final Map<String, dynamic> body = {
      "email": emailController.text.trim(),
      "password": passwordController.text.trim(),
      "nickname": nameController.text.trim(),
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        Get.snackbar(
          '가입 완료',
          '회원가입이 완료되었습니다.',
          backgroundColor: Colors.green.shade100,
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.offNamed('/login');
      } else {
        final responseData = jsonDecode(response.body);
        Get.snackbar(
          '가입 실패',
          responseData['message'] ?? '회원가입에 실패했습니다.',
          backgroundColor: Colors.red.shade100,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        '오류',
        '서버와의 통신에 실패했습니다.',
        backgroundColor: Colors.red.shade100,
        snackPosition: SnackPosition.BOTTOM,
      );
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                '정보입력',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 50),
              _buildInputField('이름', '홍길동', nameController),
              _buildInputField('이메일', 'abcde@gmail.com', emailController),
              _buildInputField('비밀번호', '비밀번호 (8자 이상)', passwordController,
                  obscureText: true),
              _buildInputField('비밀번호 확인', '비밀번호 확인', confirmPasswordController,
                  obscureText: true),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: isFormValid && !isLoading ? _signup : null,
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
                    : const Text(
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
      ),
    );
  }

  Widget _buildInputField(
      String label, String hint, TextEditingController controller,
      {bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.black87),
        ),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            border: const UnderlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
