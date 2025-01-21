import 'package:flutter/material.dart';
import '../../widgets/section_container.dart';
import '../../widgets/modal/add_todo.dart';

class TodoIndex extends StatefulWidget {
  const TodoIndex({super.key});

  @override
  State<TodoIndex> createState() => _TodoIndexState();
}

class _TodoIndexState extends State<TodoIndex> {
  List<Map<String, dynamic>> tasks = [
    {"title": "자고 싶어요", "subtitle": "카테고리 이름", "isChecked": true},
    {"title": "언제 다 해", "subtitle": "카테고리 이름", "isChecked": false},
  ];

  void _toggleTask(int index) {
    setState(() {
      tasks[index]['isChecked'] = !tasks[index]['isChecked'];
    });
  }

  void _showAddTaskModal() {
    showDialog(
      context: context,
      builder: (context) => AddTodo(
        onAdd: (title, category, date) {
          setState(() {
            tasks.add({
              "title": title,
              "subtitle": category,
              "isChecked": false,
            });
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 20, top: 10), // 간격 추가
          child: SectionContainer(
            title: "오늘",
            date: "1.16. (목)",
            children: [_buildAddTaskButton()],
          ),
        ),
        SectionContainer(
          title: "이번주 할일",
          date: "1.13. ~ 1.19.",
          children: [
            ...tasks.asMap().entries.map((entry) {
              int index = entry.key;
              var task = entry.value;
              return _buildTaskItem(
                  index, task["title"], task["subtitle"], task["isChecked"]);
            }),
            _buildAddTaskButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildTaskItem(
      int index, String title, String subtitle, bool isChecked) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
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
              _toggleTask(index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddTaskButton() {
    return Material(
      color: Colors.transparent, // 배경 투명 설정
      child: InkWell(
        onTap: _showAddTaskModal,
        borderRadius: BorderRadius.circular(12), // 클릭 이펙트를 버튼 모양에 맞춤
        splashColor: Colors.blue.shade200, // 클릭 시 물결 효과 색상
        highlightColor: Colors.blue.shade50, // 클릭 시 강조 색상
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
