import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarIndex extends StatefulWidget {
  const CalendarIndex({super.key});

  @override
  State<CalendarIndex> createState() => _CalendarIndexState();
}

class _CalendarIndexState extends State<CalendarIndex> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<String>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _events = {
      DateTime.utc(2024, 1, 16): ['회의'],
      DateTime.utc(2024, 1, 20): ['할일1', '할일2'],
    };
  }

  List<String> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FD),
      appBar: AppBar(
        title: const Text('캘린더', style: TextStyle(color: Colors.black)),
        backgroundColor: const Color(0xFFF5F7FD),
        elevation: 1,
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            startingDayOfWeek: StartingDayOfWeek.sunday,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
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
            headerStyle: const HeaderStyle(titleCentered: true),
            eventLoader: _getEventsForDay,
          ),
        ],
      ),
    );
  }
}
