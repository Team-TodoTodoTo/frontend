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

  // 일간 투두 조회 함수 수정
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

        if (responseData.isEmpty) {
          print('일간 투두가 비어있음: $responseData');
        } else {
          print('일간 투두 응답 확인: $responseData');
        }

        setState(() {
          tasks = responseData.map<Map<String, dynamic>>((item) {
            final categoryTitle = item.containsKey("categoryTitle") &&
                    item["categoryTitle"] != null
                ? item["categoryTitle"]
                : "카테고리 없음";

            return {
              "id": item["id"],
              "todo": item["todo"],
              "categoryId": item["categoryId"],
              "categoryTitle": categoryTitle,
              "date": DateFormat('yyyy-MM-dd')
                  .format(DateTime.parse(item["date"]).toLocal()), // 로컬 시간 변환
              "isCompleted": item["isCompleted"] == 1 ? true : false,
            };
          }).toList();

          print("업데이트된 tasks 리스트: $tasks"); // 로깅 추가
        });
      } else {
        print('서버 응답 오류 (일간): ${response.statusCode}');
        throw Exception('오늘의 할 일을 불러오지 못했습니다. 오류 코드: ${response.statusCode}');
      }
    } catch (e) {
      print('일간 투두 조회 오류 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오늘의 할 일을 불러오는데 실패했습니다. 오류: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

// 주간 투두 조회 함수 수정
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
            final categoryTitle = item.containsKey("categoryTitle") &&
                    item["categoryTitle"] != null
                ? item["categoryTitle"]
                : "카테고리 없음";

            return {
              "id": item["id"],
              "todo": item["todo"],
              "categoryId": item["categoryId"],
              "categoryTitle": categoryTitle,
              "date": item["date"],
              "isCompleted": item["isCompleted"] == 1 ? true : false,
            };
          }).toList();
        });
      } else {
        print('서버 응답 오류: ${response.statusCode}');
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

  // 투두 수정
  Future<void> _updateTodoStatus(
      Map<String, dynamic> todo, bool newStatus) async {
    final Uri url = Uri.parse('http://localhost:4000/todos/${todo["id"]}');

    final String? token = await getToken();
    if (token == null) {
      print('로그인 필요 - 토큰 없음');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다. 다시 로그인하세요.')),
      );
      Get.offNamed('/login');
      return;
    }

    final Map<String, dynamic> updatedTodo = {
      "todo": todo["todo"],
      "categoryId": todo["categoryId"],
      "categoryTitle": todo["categoryTitle"],
      "date": todo["date"],
      "isCompleted": newStatus, // 불리언 값 유지
    };

    print('PUT 요청 보냄: $updatedTodo'); // 요청 로그 확인

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
        final updatedData = jsonDecode(response.body);
        print(
            '서버 업데이트 성공: ${updatedData["id"]}, 상태=${updatedData["isCompleted"]}');
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

  @override
  void initState() {
    super.initState();
    _fetchDailyTasks();
    _fetchWeeklyTasks();
  }

  void _toggleTask(int index) async {
    final task = tasks[index];
    final bool newStatus = !task['isCompleted'];

    print(
        '투두 상태 변경 요청: ID=${task["id"]}, 현재 상태=${task["isCompleted"]}, 변경 상태=$newStatus');

    setState(() {
      tasks[index] = {...task, "isCompleted": newStatus};
    });

    await _updateTodoStatus(task, newStatus);

    print(
        '투두 상태 변경 완료: ID=${task["id"]}, 새로운 상태=${tasks[index]["isCompleted"]}');
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
              "categoryTitle": categoryData["title"],
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
                    ...tasks
                        .asMap()
                        .entries
                        .where((entry) =>
                            DateFormat('yyyy-MM-dd').format(
                                DateTime.parse(entry.value["date"])
                                    .toLocal()) ==
                            DateFormat('yyyy-MM-dd').format(today))
                        .map((entry) {
                      final index = entry.key;
                      final task = entry.value;
                      return _buildTaskItem(
                        task["todo"] as String? ?? "제목 없음",
                        task["categoryTitle"] as String? ?? "카테고리 없음",
                        task["isCompleted"] as bool? ?? false,
                        index, // 인덱스를 전달
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
                  ...tasks.asMap().entries.map((entry) {
                    final index = entry.key;
                    final task = entry.value;
                    return _buildTaskItem(
                      task["todo"] as String? ?? "제목 없음",
                      task["categoryTitle"] as String? ?? "카테고리 없음",
                      task["isCompleted"] as bool? ?? false,
                      index,
                    );
                  }),
                  _buildAddTaskButton(),
                ],
              ),
            ],
          );
  }

  // UI에 적용 부분 수정
  Widget _buildTaskItem(
      String title, String categoryTitle, bool isChecked, int index) {
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
                  categoryTitle, // 카테고리 제목 표시
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          Checkbox(
            value: isChecked,
            onChanged: (value) async {
              _toggleTask(index); // 상태 업데이트
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
