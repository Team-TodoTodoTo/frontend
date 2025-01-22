import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../shared/category_data.dart';
import '../../shared/todo_data.dart';
import '../../widgets/section_container.dart';
import '../../widgets/modal/add_todo.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveToken(String token) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('accessToken', token);
}

Future<String?> getToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('accessToken');
}

class TodoIndex extends StatefulWidget {
  const TodoIndex({super.key});

  @override
  State<TodoIndex> createState() => _TodoIndexState();
}

class _TodoIndexState extends State<TodoIndex> {
  List<Map<String, dynamic>> tasks = [];
  bool isLoading = false;

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

  // 일간 투두 조회
  Future<void> _fetchDailyTasks() async {
    setState(() {
      isLoading = true;
    });

    final String formattedDate = DateFormat('yyyy-MM-dd').format(today);

    final Uri url =
        Uri.parse('http://localhost:4000/todos/day').replace(queryParameters: {
      'date': formattedDate,
    });

    try {
      final String? token = await getToken();

      if (token == null) {
        throw Exception('로그인이 필요합니다.');
      }

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
          tasks = responseData.map<Map<String, dynamic>>((item) {
            DateTime parsedDate = DateTime.parse(item["date"]).toLocal();
            String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);

            return {
              "id": item["id"],
              "todo": item["todo"],
              "categoryId": item["categoryId"],
              "date": formattedDate,
              "isCompleted": item["isCompleted"] == 1 ? true : false,
            };
          }).toList();
        });
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('인증이 필요합니다. 다시 로그인하세요.')),
        );
        Get.offNamed('/login'); // 로그인 페이지로 이동
      } else {
        throw Exception('오늘의 할 일을 불러오지 못했습니다. 오류 코드: ${response.statusCode}');
      }
    } catch (e) {
      print('오류 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('데이터를 불러오는데 실패했습니다. 오류: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // 주간 투두 조회
  Future<void> _fetchWeeklyTasks() async {
    setState(() {
      isLoading = true;
    });

    DateTime startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));

    final String formattedStartDate =
        DateFormat('yyyy-MM-dd').format(startOfWeek);
    final String formattedEndDate = DateFormat('yyyy-MM-dd').format(endOfWeek);

    final Uri url =
        Uri.parse('http://localhost:4000/todos/week').replace(queryParameters: {
      'startDate': formattedStartDate,
      'endDate': formattedEndDate,
    });

    try {
      final String? token = await getToken(); // 저장된 토큰 불러오기

      if (token == null) {
        throw Exception('로그인이 필요합니다.');
      }

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
          tasks = responseData.map<Map<String, dynamic>>((item) {
            DateTime parsedDate = DateTime.parse(item["date"]).toLocal();
            String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);

            return {
              "id": item["id"],
              "todo": item["todo"],
              "categoryId": item["categoryId"],
              "date": formattedDate,
              "isCompleted": item["isCompleted"] == 1 ? true : false,
            };
          }).toList();
        });
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('인증이 필요합니다. 다시 로그인하세요.')),
        );
        Get.offNamed('/login'); // 로그인 페이지로 이동
      } else {
        throw Exception('할 일을 불러오지 못했습니다. 오류 코드: ${response.statusCode}');
      }
    } catch (e) {
      print('오류 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('데이터를 불러오는데 실패했습니다. 오류: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchDailyTasks();
    _fetchWeeklyTasks();
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

          // 새로운 투두 항목을 로컬 상태에 추가
          setState(() {
            tasks.add({
              "id": DateTime.now().millisecondsSinceEpoch, // 임시 ID 생성
              "todo": title,
              "categoryId": categoryData["id"],
              "date": date,
              "isCompleted": false,
            });
          });

          // 서버에서 최신 데이터를 다시 불러오기
          _fetchDailyTasks();
          _fetchWeeklyTasks();
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
      return dateString == DateFormat('yyyy-MM-dd').format(today);
    } catch (e) {
      print("날짜 파싱 오류: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Padding(
                  padding: const EdgeInsets.only(bottom: 20, top: 10),
                  child: SectionContainer(
                    title: "오늘",
                    date: getFormattedDate(today),
                    children: [
                      ...tasks.where((task) {
                        return task["date"] ==
                            DateFormat('yyyy-MM-dd').format(today);
                      }).map((task) {
                        return _buildTaskItem(
                          task["todo"] as String? ?? "제목 없음",
                          _getCategoryTitle(task["categoryId"] as int?),
                          task["isCompleted"] as bool? ?? false,
                        );
                      }),
                      _buildAddTaskButton(),
                    ],
                  )),
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
