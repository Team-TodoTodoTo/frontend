import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class EditCategoryModal extends StatefulWidget {
  const EditCategoryModal({super.key});

  @override
  State<EditCategoryModal> createState() => _EditCategoryModalState();
}

class _EditCategoryModalState extends State<EditCategoryModal> {
  final TextEditingController _categoryController = TextEditingController();
  bool _isSubmitting = false;
  List<Map<String, dynamic>> _categories = [];
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  // 카테고리 리스트 조회
  Future<void> _fetchCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });

    final String? token = await getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다. 다시 로그인하세요.')),
      );
      return;
    }

    final Uri url = Uri.parse('http://localhost:4000/categories');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        setState(() {
          _categories = responseData
              .map((item) => {
                    "id": item["id"],
                    "title": item["title"],
                  })
              .toList();
        });
      } else {
        throw Exception('카테고리 목록 불러오기 실패: 상태 코드 ${response.statusCode}');
      }
    } catch (e) {
      print('카테고리 조회 중 오류 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('카테고리 조회 실패: $e')),
      );
    } finally {
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  // 카테고리 삭제
  Future<void> _deleteCategory(int categoryId) async {
    final String? token = await getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다. 다시 로그인하세요.')),
      );
      return;
    }

    final Uri url = Uri.parse('http://localhost:4000/categories/$categoryId');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('카테고리가 삭제되었습니다.')),
        );
        _fetchCategories(); // 삭제 후 목록 갱신
      } else {
        throw Exception('카테고리 삭제 실패: 상태 코드 ${response.statusCode}');
      }
    } catch (e) {
      print('카테고리 삭제 중 오류 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('카테고리 삭제 중 오류 발생: $e')),
      );
    }
  }

  // 카테고리 추가 요청
  Future<void> _addCategory() async {
    if (_categoryController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('카테고리명을 입력해주세요.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final String? token = await getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다. 다시 로그인하세요.')),
      );
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    final Uri url = Uri.parse('http://localhost:4000/categories');
    final Map<String, dynamic> categoryData = {
      "title": _categoryController.text.trim(),
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(categoryData),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('카테고리가 추가되었습니다.')),
        );
        _categoryController.clear();
        _fetchCategories(); // 추가 후 리스트 갱신
      } else {
        throw Exception('카테고리 추가 실패: 상태 코드 ${response.statusCode}');
      }
    } catch (e) {
      print('카테고리 추가 중 오류 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('카테고리 추가 중 오류 발생: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
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
            const Text(
              "카테고리 관리",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _isLoadingCategories
                ? const Center(child: CircularProgressIndicator())
                : _categories.isNotEmpty
                    ? Column(
                        children: _categories.map((category) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECEDF4),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    category["title"],
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.black),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.redAccent),
                                  onPressed: () async {
                                    bool confirmDelete =
                                        await _showDeleteConfirmation();
                                    if (confirmDelete) {
                                      _deleteCategory(category["id"]);
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      )
                    : const Center(
                        child: Text("등록된 카테고리가 없습니다.",
                            style: TextStyle(color: Colors.grey)),
                      ),
            const SizedBox(height: 16),
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(
                hintText: "카테고리명을 입력하세요",
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFFECEDF4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("취소", style: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: _isSubmitting ? null : _addCategory,
                  child: _isSubmitting
                      ? const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.0)
                      : const Text("추가",
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmation() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("삭제 확인"),
            content: const Text("정말 삭제하시겠습니까?"),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("취소")),
              TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("삭제")),
            ],
          ),
        ) ??
        false;
  }
}
