import 'package:flutter/material.dart';
import '../../student_data.dart';
import 'student_home_tab.dart';
import 'student_search_tab.dart';
import 'student_add_item_tab.dart';
import 'student_chat_tab.dart';
import 'student_profile_tab.dart';

class StudentShell extends StatefulWidget {
  const StudentShell({super.key});

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const StudentHomeTab(),
    const StudentSearchTab(),
    const StudentAddItemTab(),
    const StudentChatTab(),
    const StudentProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: StudentState.instance,
      builder: (context, child) {
        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: _tabs,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            backgroundColor: Colors.white,
            elevation: 8,
            indicatorColor: const Color(0xFF64B5F6).withOpacity(0.2),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded, color: Color(0xFF1E88E5)),
                label: 'Beranda',
              ),
              NavigationDestination(
                icon: Icon(Icons.search_rounded),
                selectedIcon: Icon(Icons.search_rounded, color: Color(0xFF1E88E5)),
                label: 'Cari',
              ),
              NavigationDestination(
                icon: Icon(Icons.add_circle_outline_rounded),
                selectedIcon: Icon(Icons.add_circle_rounded, color: Color(0xFF1E88E5)),
                label: 'Tambah',
              ),
              NavigationDestination(
                icon: Icon(Icons.chat_bubble_outline_rounded),
                selectedIcon: Icon(Icons.chat_bubble_rounded, color: Color(0xFF1E88E5)),
                label: 'Chat',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded, color: Color(0xFF1E88E5)),
                label: 'Profil',
              ),
            ],
          ),
        );
      },
    );
  }
}
