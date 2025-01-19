import 'package:flutter/material.dart';

final List<BottomNavigationBarItem> myTabs = [
  BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'),
  BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'calendar'),
];

final List<Widget> myTabItems = [
  Center(child: Text('홈')),
  Center(child: Text('캘린더')),
];

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
