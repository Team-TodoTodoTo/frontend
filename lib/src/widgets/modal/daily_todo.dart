import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    _todos = List.from(widget.todos); // 리스트 복사하여 변경 가능하도록 설정
  }

  void _toggleTask(int index) {
    setState(() {
      _todos[index]['isCompleted'] = !_todos[index]['isCompleted'];
    });
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
                                int index = _todos.indexOf(todo);
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
                onPressed: () => Navigator.of(context).pop(),
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
