import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../shared/category_data.dart';
import '../../shared/todo_data.dart';
import '../../widgets/section_container.dart';
import '../../widgets/modal/add_todo.dart';

class TodoIndex extends StatefulWidget {
  const TodoIndex({super.key});

  @override
  State<TodoIndex> createState() => _TodoIndexState();
}

class _TodoIndexState extends State<TodoIndex> {
  List<Map<String, dynamic>> tasks =
      todoList.map((task) => Map<String, dynamic>.from(task)).toList();

  final DateTime today = DateTime.now();

  String getFormattedDate(DateTime date) {
    return DateFormat("M.d. (E)", 'ko').format(date);
  }

  String getWeekRange() {
    DateTime startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));
    return "${DateFormat('M.d. (E)', 'ko').format(startOfWeek)} ~ "
        "${DateFormat('M.d. (E)', 'ko').format(endOfWeek)}";
  }

  void _toggleTask(int index) {
    setState(() {
      tasks = tasks.map((task) {
        if (tasks.indexOf(task) == index) {
          return {...task, 'isCompleted': !task['isCompleted']};
        }
        return task;
      }).toList();
    });
  }

  void _showAddTaskModal() {
    showDialog(
      context: context,
      builder: (context) => AddTodo(
        onAdd: (title, category, date) {
          final categoryData = categoryList.firstWhere(
            (item) => item["title"] == category,
            orElse: () => {"id": 1},
          );
          setState(() {
            tasks.add({
              "todo": title,
              "categoryId": categoryData["id"],
              "date": date,
              "isCompleted": false,
            });
          });
        },
      ),
    );
  }

  String _getCategoryTitle(int? categoryId) {
    if (categoryId == null) return "알 수 없음";
    final category = categoryList.firstWhere(
      (item) => item["id"] == categoryId,
      orElse: () => {"title": "알 수 없음"},
    );
    return category["title"] ?? "알 수 없음";
  }

  bool _isToday(String? dateString) {
    if (dateString == null) return false;
    try {
      DateTime taskDate = DateTime.parse(dateString);
      return taskDate.year == today.year &&
          taskDate.month == today.month &&
          taskDate.day == today.day;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 20, top: 10),
          child: SectionContainer(
            title: "오늘",
            date: getFormattedDate(today),
            children: [
              ...tasks.where((task) => _isToday(task["date"])).map((task) {
                return _buildTaskItem(
                  task["todo"] as String? ?? "제목 없음",
                  _getCategoryTitle(task["categoryId"] as int?),
                  task["isCompleted"] as bool? ?? false,
                );
              }),
              _buildAddTaskButton(),
            ],
          ),
        ),
        SectionContainer(
          title: "이번주 할일",
          date: getWeekRange(),
          children: [
            ...tasks.map((task) {
              return _buildTaskItem(
                task["todo"] as String? ?? "제목 없음",
                _getCategoryTitle(task["categoryId"] as int?),
                task["isCompleted"] as bool? ?? false,
              );
            }),
            _buildAddTaskButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildTaskItem(String title, String subtitle, bool isChecked) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isChecked ? Colors.blue.shade50 : Colors.blue.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    decoration: isChecked
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          Checkbox(
            value: isChecked,
            onChanged: (value) {
              final index = tasks.indexWhere((task) => task["todo"] == title);
              _toggleTask(index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddTaskButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _showAddTaskModal,
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.blue.shade200,
        highlightColor: Colors.blue.shade50,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text("+ 할 일을 추가하세요.", style: TextStyle(color: Colors.grey)),
          ),
        ),
      ),
    );
  }
}
