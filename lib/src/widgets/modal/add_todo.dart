import 'package:flutter/material.dart';
import '../../shared/category_data.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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

  List<Map<String, dynamic>> _categories = [];
  String? _selectedCategory;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  // 저장된 토큰 가져오기
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  // 카테고리 리스트를 서버에서 가져오는 함수
  Future<void> _fetchCategories() async {
    setState(() {
      isLoading = true;
    });

    const String apiUrl = 'http://localhost:4000/categories';

    try {
      final String? token = await getToken();
      if (token == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        setState(() {
          _categories = responseData.map((item) {
            return {
              "id": item["id"],
              "title": item["title"],
            };
          }).toList();
          _selectedCategory =
              _categories.isNotEmpty ? _categories.first["title"] : null;
        });
      } else {
        throw Exception('카테고리 데이터를 불러오지 못했습니다.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('카테고리 불러오기 실패: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // 투두 생성 API 호출 함수
  Future<void> _createTodo() async {
    setState(() {
      isLoading = true;
    });

    const String apiUrl = 'http://localhost:4000/todos';

    try {
      final String? token = await getToken();
      if (token == null) {
        throw Exception('로그인이 필요합니다.');
      }

      // 선택한 카테고리의 ID 찾기
      final selectedCategoryId = _categories.firstWhere(
        (element) => element["title"] == _selectedCategory,
        orElse: () => {"id": null},
      )["id"];

      final Map<String, dynamic> body = {
        "todo": _titleController.text,
        "categoryId": selectedCategoryId,
        "date":
            "${_yearController.text}-${_monthController.text}-${_dayController.text}"
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('투두가 성공적으로 등록되었습니다!')),
        );
        Navigator.of(context).pop();
      } else {
        throw Exception('투두 등록 실패: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('투두 등록 실패: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _submit() async {
    if (_titleController.text.isNotEmpty && _selectedCategory != null) {
      final date =
          "${_yearController.text}-${_monthController.text}-${_dayController.text}";

      try {
        final String? token = await getToken();
        if (token == null) throw Exception('로그인이 필요합니다.');

        final categoryId = categoryList.firstWhere(
          (item) => item["title"] == _selectedCategory,
          orElse: () => {"id": 1},
        )["id"];

        final response = await http.post(
          Uri.parse('http://localhost:4000/todos'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            "todo": _titleController.text,
            "categoryId": categoryId,
            "date": date,
          }),
        );

        if (response.statusCode == 201) {
          widget.onAdd(_titleController.text, _selectedCategory!, date);
          Navigator.of(context).pop();
        } else {
          throw Exception('할 일을 추가하지 못했습니다.');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류 발생: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("할 일 제목과 카테고리를 입력하세요!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
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
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFECEDF4),
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
                        .map<DropdownMenuItem<String>>(
                            (category) => DropdownMenuItem<String>(
                                  value: category["title"] as String,
                                  child: Text(category["title"] as String),
                                ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFECEDF4),
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
                            fillColor: const Color(0xFFECEDF4),
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
                            fillColor: const Color(0xFFECEDF4),
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
                            fillColor: const Color(0xFFECEDF4),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("취소",
                            style: TextStyle(color: Colors.grey)),
                      ),
                      const SizedBox(width: 16),
                      TextButton(
                        onPressed: _submit,
                        child: const Text("저장",
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
