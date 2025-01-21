import 'package:flutter/material.dart';
import '../../widgets/section_container.dart';
import '../../shared/category_data.dart';
import '../../shared/todo_data.dart';

class TodoIndex extends StatefulWidget {
  const TodoIndex({super.key});

  @override
  State<TodoIndex> createState() => _TodoIndexState();
}

class _TodoIndexState extends State<TodoIndex> {
  late List<Map<String, dynamic>> todos;

  @override
  void initState() {
    super.initState();
    todos = List<Map<String, dynamic>>.from(todoList);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionContainer(
          title: "오늘의 할 일",
          date: "1.16. (목)",
          children: _buildTaskList("2025-01-16"),
        ),
        const SizedBox(height: 16),
        SectionContainer(
          title: "이번 주 할 일",
          date: "1.13. ~ 1.19.",
          children: _buildTaskListForWeek(["2025-01-16", "2025-01-18"]),
        ),
      ],
    );
  }

  List<Widget> _buildTaskList(String date) {
    final filteredTodos = todos.where((todo) => todo['date'] == date).toList();
    return filteredTodos.map((task) => _buildTaskItem(task)).toList();
  }

  List<Widget> _buildTaskListForWeek(List<String> dates) {
    final filteredTodos =
        todos.where((todo) => dates.contains(todo['date'])).toList();
    return filteredTodos.map((task) => _buildTaskItem(task)).toList();
  }

  Widget _buildTaskItem(Map<String, dynamic> task) {
    final category = categoryList.firstWhere(
      (cat) => cat['id'] == task['categoryId'],
      orElse: () => {"title": "알 수 없음"},
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: task["isCompleted"] ? Colors.blue.shade50 : Colors.blue.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task["todo"],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    decoration: task["isCompleted"]
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                Text(
                  category["title"],
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          Checkbox(
            value: task["isCompleted"] ?? false,
            onChanged: (value) {
              _toggleTaskCompletion(task);
            },
          ),
        ],
      ),
    );
  }

  void _toggleTaskCompletion(Map<String, dynamic> task) {
    setState(() {
      final index = todos.indexWhere((t) => t == task);
      if (index != -1) {
        todos[index] = {
          ...task,
          "isCompleted": !task["isCompleted"],
        };
      }
    });
  }
}
