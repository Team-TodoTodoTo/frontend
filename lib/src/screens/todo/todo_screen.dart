import 'package:flutter/material.dart';
import 'index.dart';

class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FD),
      body: const TodoIndex(),
    );
  }
}
