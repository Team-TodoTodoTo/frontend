import 'package:flutter/material.dart';
import "index.dart";

final List<BottomNavigationBarItem> myTabs = [
  BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'),
  BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'calendar'),
];

final List<Widget> myTabItems = [
  const TodoIndex(),
  Center(child: Text('캘린더')),
];

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});
  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF5F7FD),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF5F7FD),
          title: const Text(
            '투두투두투',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18.0),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              color: Colors.grey.shade300,
              height: 1.0,
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color(0xFFF5F7FD),
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: myTabs,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: myTabItems,
        ));
  }
}
