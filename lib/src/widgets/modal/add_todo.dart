import 'package:flutter/material.dart';

class AddTodo extends StatefulWidget {
  final Function(String title, String category, String date) onAdd;

  const AddTodo({
    super.key,
    required this.onAdd,
  });

  @override
  State<AddTodo> createState() => _AddTodoState();
}

class _AddTodoState extends State<AddTodo> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _yearController =
      TextEditingController(text: DateTime.now().year.toString());
  final TextEditingController _monthController = TextEditingController(
      text: DateTime.now().month.toString().padLeft(2, '0'));
  final TextEditingController _dayController = TextEditingController(
      text: DateTime.now().day.toString().padLeft(2, '0'));
  String _selectedCategory = "카테고리1";

  final List<String> _categories = ["카테고리1", "카테고리2", "카테고리3"];

  void _incrementDate() {
    int year = int.parse(_yearController.text);
    int month = int.parse(_monthController.text);
    int day = int.parse(_dayController.text);

    final newDate = DateTime(year, month, day + 1);
    _yearController.text = newDate.year.toString();
    _monthController.text = newDate.month.toString().padLeft(2, '0');
    _dayController.text = newDate.day.toString().padLeft(2, '0');
  }

  void _decrementDate() {
    int year = int.parse(_yearController.text);
    int month = int.parse(_monthController.text);
    int day = int.parse(_dayController.text);

    final newDate = DateTime(year, month, day - 1);
    _yearController.text = newDate.year.toString();
    _monthController.text = newDate.month.toString().padLeft(2, '0');
    _dayController.text = newDate.day.toString().padLeft(2, '0');
  }

  void _submit() {
    if (_titleController.text.isNotEmpty) {
      final date =
          "${_yearController.text} ${_monthController.text} ${_dayController.text}";
      widget.onAdd(
        _titleController.text,
        _selectedCategory,
        date,
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("할일 제목을 입력하세요!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Todo 등록",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: "할 일을 작성해주세요.",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: _categories
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _yearController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "YYYY",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _monthController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "MM",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _dayController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "DD",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    "취소",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: _submit,
                  child: const Text(
                    "저장",
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
