import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../widgets/section_container.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  Map<String, List<Map<String, dynamic>>> monthlyTodos = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchMonthlyTodos();
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<void> _fetchMonthlyTodos() async {
    setState(() {
      isLoading = true;
    });

    DateTime now = DateTime.now(); // 현재 날짜
    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    DateTime endOfMonth = DateTime(now.year, now.month + 1, 0);

    final String formattedStartDate =
        "${startOfMonth.year}-${startOfMonth.month.toString().padLeft(2, '0')}-${startOfMonth.day.toString().padLeft(2, '0')}";
    final String formattedEndDate =
        "${endOfMonth.year}-${endOfMonth.month.toString().padLeft(2, '0')}-${endOfMonth.day.toString().padLeft(2, '0')}";

    print('조회할 달의 시작 날짜: $formattedStartDate');
    print('조회할 달의 끝 날짜: $formattedEndDate');

    final Uri url = Uri.parse('http://localhost:4000/todos/month')
        .replace(queryParameters: {
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

        print('서버 응답 데이터: $responseData'); // 응답 데이터 로깅

        setState(() {
          monthlyTodos.clear(); // 기존 데이터를 초기화
          for (var item in responseData) {
            String formattedDate = DateFormat('yyyy-MM-dd')
                .format(DateTime.parse(item["date"]).toLocal());

            // 기존 투두가 있으면 추가, 없으면 새 리스트 생성
            if (!monthlyTodos.containsKey(formattedDate)) {
              monthlyTodos[formattedDate] = [];
            }

            if (monthlyTodos[formattedDate]!.length < 3) {
              monthlyTodos[formattedDate]!.add({
                "id": item["id"],
                "todo": item["todo"],
                "categoryId": item["categoryId"],
                "isCompleted": item["isCompleted"] == 1 ? true : false,
              });
            }
          }
        });

        print('처리된 투두 데이터: $monthlyTodos'); // 디버깅 확인
      } else {
        throw Exception('투두 목록을 불러오지 못했습니다. 상태 코드: ${response.statusCode}');
      }
    } catch (e) {
      print('오류 발생: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(day);

    return monthlyTodos[formattedDate] ?? [];
  }

  void _onPageChanged(DateTime newFocusedDay) {
    setState(() {
      _focusedDay = newFocusedDay;
    });
  }

  // 달의 주 수를 계산하는 함수
  int _getWeekCount(DateTime date) {
    DateTime firstDay = DateTime(date.year, date.month, 1);
    DateTime lastDay = DateTime(date.year, date.month + 1, 0);
    int firstWeekday = firstDay.weekday % 7;
    int totalDays = lastDay.day;
    return ((totalDays + firstWeekday) / 7).ceil(); // 4, 5, 6 중 하나
  }

  @override
  Widget build(BuildContext context) {
    int weekCount = _getWeekCount(_focusedDay);
    double screenHeight = MediaQuery.of(context).size.height;

    // SectionContainer 내부 패딩 + 요일 텍스트 높이 합산
    double containerPadding = 32.0; // 상하 패딩 합 (가정값)
    double weekdayTextHeight = 30.0; // 요일 텍스트 높이

    // section container에서 요일 텍스트를 제외한 높이 계산
    double availableHeight =
        screenHeight * 0.6 - containerPadding - weekdayTextHeight;

    // 날짜 박스의 높이를 동적으로 조절
    double rowHeight = availableHeight / weekCount;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FD),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 40, right: 16.0, top: 16.0, bottom: 16.0), // 왼쪽 패딩 적용
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    '${_focusedDay.year}년',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_focusedDay.month}월',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // 추가된 SectionContainer (투두투두투)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SectionContainer(
                title: '투두투두투',
                date: '투두투두투와 함께 시간을 효율적으로 사용해보세요!',
                children: const [],
              ),
            ),

            Flexible(
              fit: FlexFit.tight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SectionContainer(
                  children: [
                    TableCalendar(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        startingDayOfWeek: StartingDayOfWeek.sunday,
                        headerVisible: false,
                        rowHeight: rowHeight, // 동적으로 계산된 날짜 박스 높이 적용
                        onPageChanged: (focusedDay) {
                          _onPageChanged(focusedDay);
                        },
                        calendarStyle: CalendarStyle(
                          defaultTextStyle: const TextStyle(
                            fontSize: 12, // 날짜 텍스트 크기 12로 조정
                            fontWeight: FontWeight.normal,
                            color: Colors.black, // 기본 텍스트 색상
                          ),
                          todayDecoration: BoxDecoration(
                            color: Colors.blue.shade200,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.blue.shade400,
                                width: 1), // 선택적 테두리
                          ),
                          todayTextStyle: const TextStyle(
                            fontSize: 12, // 텍스트 크기 유지
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        eventLoader: (day) {
                          final events = _getEventsForDay(day);
                          return events;
                        },
                        calendarBuilders: CalendarBuilders(
                            defaultBuilder: (context, day, focusedDay) {
                          TextStyle textStyle = const TextStyle(
                            fontSize: 12, // 날짜 크기 조정
                            fontWeight: FontWeight.normal,
                            color: Colors.black, // 기본 날짜 색상
                          );

                          if (day.weekday == DateTime.saturday) {
                            textStyle = textStyle.copyWith(
                                color: Colors.blue); // 토요일 파란색
                          } else if (day.weekday == DateTime.sunday) {
                            textStyle = textStyle.copyWith(
                                color: Colors.red); // 일요일 빨간색
                          }

                          return Center(
                            child: Text(
                              '${day.day}', // 날짜 숫자 표시
                              style: textStyle,
                            ),
                          );
                        },

                            // 요일(월~일) 스타일 변경
                            dowBuilder: (context, day) {
                          final textStyle = const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          );

                          switch (day.weekday) {
                            case DateTime.saturday:
                              return Center(
                                  child: Text('토',
                                      style: textStyle.copyWith(
                                          color: Colors.blue)));
                            case DateTime.sunday:
                              return Center(
                                  child: Text('일',
                                      style: textStyle.copyWith(
                                          color: Colors.red)));
                            case DateTime.monday:
                              return Center(child: Text('월', style: textStyle));
                            case DateTime.tuesday:
                              return Center(child: Text('화', style: textStyle));
                            case DateTime.wednesday:
                              return Center(child: Text('수', style: textStyle));
                            case DateTime.thursday:
                              return Center(child: Text('목', style: textStyle));
                            case DateTime.friday:
                              return Center(child: Text('금', style: textStyle));
                          }
                          return null;
                        }, markerBuilder: (context, date, events) {
                          if (events.isNotEmpty) {
                            return Positioned(
                              top: 60, // 날짜 아래 여백 설정
                              left: 0,
                              right: 0,
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start, // 투두 왼쪽 정렬
                                children: events.take(3).map((event) {
                                  final todoText = (event
                                          as Map<String, dynamic>?)?["todo"] ??
                                      '';
                                  final isCompleted =
                                      event?["isCompleted"] ?? false;

                                  return Container(
                                    margin: const EdgeInsets.only(
                                        top: 2), // 투두 항목 간격 조정
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 3),
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width /
                                                  7 -
                                              10, // 날짜 칸 크기 맞춤
                                    ),
                                    decoration: BoxDecoration(
                                      color: isCompleted
                                          ? Colors.blue.shade100
                                          : Colors
                                              .blue.shade300, // 완료 여부에 따른 색상 변경
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      todoText.length > 6
                                          ? '${todoText.substring(0, 6)}...'
                                          : todoText, // 길이 초과 처리
                                      style: TextStyle(
                                        color:
                                            Colors.white, // 완료 여부에 따른 텍스트 색상 변경
                                        fontSize: 10,
                                        decoration: isCompleted
                                            ? TextDecoration.lineThrough
                                            : TextDecoration
                                                .none, // 완료된 항목은 취소선 적용
                                        decorationColor: Colors.blue,
                                        overflow:
                                            TextOverflow.ellipsis, // 초과 텍스트 처리
                                      ),
                                      maxLines: 1, // 한 줄만 표시
                                    ),
                                  );
                                }).toList(),
                              ),
                            );
                          }
                          return null; // 투두 항목이 없으면 아무것도 표시하지 않음
                        })),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
