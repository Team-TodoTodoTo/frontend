import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DailyTodoModal extends StatefulWidget {
  final DateTime selectedDate;
  final List<Map<String, dynamic>> todos;

  const DailyTodoModal({
    super.key,
    required this.selectedDate,
    required this.todos,
  });

  @override
  State<DailyTodoModal> createState() => _DailyTodoModalState();
}

class _DailyTodoModalState extends State<DailyTodoModal> {
  List<Map<String, dynamic>> _todos = [];

  @override
  void initState() {
    super.initState();
    _todos = List.from(widget.todos); // 기존 리스트 복사
  }

  // 토큰 가져오기
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  // 서버로 상태 업데이트 요청
  Future<void> _updateTodoStatus(int index) async {
    final todo = _todos[index];
    final bool newStatus = !todo['isCompleted'];
    final Uri url = Uri.parse('http://localhost:4000/todos/${todo["id"]}');

    final String? token = await getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다. 다시 로그인하세요.')),
      );
      return;
    }

    final Map<String, dynamic> updatedTodo = {
      "todo": todo["todo"],
      "categoryId": todo["categoryId"],
      "date": todo["date"] ??
          DateFormat('yyyy-MM-dd').format(DateTime.now()), // null 방지
      "isCompleted": newStatus,
    };

    print("PUT 요청 데이터: ${jsonEncode(updatedTodo)}");

    print('PUT 요청 보냄: $updatedTodo'); // 요청 확인 로그

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updatedTodo),
      );

      if (response.statusCode == 200) {
        setState(() {
          _todos[index]['isCompleted'] = newStatus;
        });
        final updatedData = jsonDecode(response.body);
        print(
            '서버 업데이트 성공: ID=${updatedData["id"]}, 상태=${updatedData["isCompleted"]}');
      } else {
        print(
            '서버 업데이트 실패 - 상태 코드: ${response.statusCode}, 응답: ${response.body}');
        throw Exception('서버 업데이트 실패');
      }
    } catch (e) {
      print('서버 업데이트 중 오류 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('상태 변경에 실패했습니다. 오류: $e')),
      );
    }
  }

  // 체크박스 클릭 시 상태 변경 및 서버 반영
  void _toggleTask(int index) async {
    await _updateTodoStatus(index); // 서버 요청 후 상태 변경
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('yyyy년 MM월 dd일').format(widget.selectedDate),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _todos.isNotEmpty
                ? Column(
                    children: _todos.map((todo) {
                      int index = _todos.indexOf(todo);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: todo['isCompleted']
                              ? Colors.blue.shade50
                              : Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    todo['todo'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      decoration: todo['isCompleted']
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                    ),
                                  ),
                                  Text(
                                    '카테고리 ID: ${todo["categoryId"]}',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade700),
                                  ),
                                ],
                              ),
                            ),
                            Checkbox(
                              value: todo['isCompleted'],
                              onChanged: (value) {
                                _toggleTask(index);
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  )
                : const Center(
                    child: Text(
                      "등록된 투두가 없습니다.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(_todos),
                child: const Text(
                  "닫기",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
