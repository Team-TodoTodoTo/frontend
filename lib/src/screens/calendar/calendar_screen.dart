import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../widgets/section_container.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // 샘플 투두 데이터
  final Map<DateTime, List<String>> _events = {
    DateTime.utc(2025, 1, 16): ['회의', '운동하기'],
    DateTime.utc(2025, 1, 20): ['할일1', '할일2'],
  };

  List<String> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  void _onPageChanged(DateTime newFocusedDay) {
    setState(() {
      _focusedDay = newFocusedDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 연월 표시 (SectionContainer 밖으로 이동)
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${_focusedDay.year}년',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Text(
                '${_focusedDay.month}월',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SectionContainer(
              children: [
                TableCalendar(
                  rowHeight: 90,
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  startingDayOfWeek: StartingDayOfWeek.sunday,

                  // 기본 헤더 제거
                  headerVisible: false,

                  // 스와이프로 월 변경 기능
                  onPageChanged: (focusedDay) {
                    _onPageChanged(focusedDay);
                  },

                  calendarStyle: CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      color: Colors.blue.shade400,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      shape: BoxShape.circle,
                    ),
                  ),

                  eventLoader: (day) => _getEventsForDay(day),

                  calendarBuilders: CalendarBuilders(
                    dowBuilder: (context, day) {
                      switch (day.weekday) {
                        case 1:
                          return const Center(child: Text('월'));
                        case 2:
                          return const Center(child: Text('화'));
                        case 3:
                          return const Center(child: Text('수'));
                        case 4:
                          return const Center(child: Text('목'));
                        case 5:
                          return const Center(child: Text('금'));
                        case 6:
                          return const Center(
                            child:
                                Text('토', style: TextStyle(color: Colors.blue)),
                          );
                        case 7:
                          return const Center(
                            child:
                                Text('일', style: TextStyle(color: Colors.red)),
                          );
                      }
                    },
                    markerBuilder: (context, date, events) {
                      if (events.isNotEmpty) {
                        return SizedBox(
                          width: 40,
                          height: 35,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: events.map((event) {
                              return Container(
                                width: 36,
                                height: 16,
                                margin: const EdgeInsets.symmetric(vertical: 2),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade300,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    event.toString(),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 10),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
