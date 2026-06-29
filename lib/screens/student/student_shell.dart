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
  State<StudentShell> createState() => StudentShellState();
}

// ── Public agar bisa diakses dari HomeTab via context ──────────────────────
class StudentShellState extends State<StudentShell> {
  int _currentIndex = 0;

  // State pencarian yang dibagi antara HomeTab → SearchTab
  String _initialSearchQuery = '';
  String _initialSearchCategory = 'Semua';

  // Navigasi ke tab Cari dengan query & kategori terisi otomatis
  void navigateToSearch({String query = '', String category = 'Semua'}) {
    setState(() {
      _initialSearchQuery = query;
      _initialSearchCategory = category;
      _currentIndex = 1; // index tab Cari
    });
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild SearchTab setiap kali query/category berubah dengan UniqueKey
    final searchTab = StudentSearchTab(
      key: ValueKey('$_initialSearchQuery:$_initialSearchCategory'),
      initialQuery: _initialSearchQuery,
      initialCategory: _initialSearchCategory,
    );

    final tabs = [
      const StudentHomeTab(),
      searchTab,
      const StudentAddItemTab(),
      const StudentChatTab(),
      const StudentProfileTab(),
    ];

    return ListenableBuilder(
      listenable: StudentState.instance,
      builder: (context, child) {
        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: tabs,
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
            indicatorColor: const Color(0xFF64B5F6).withValues(alpha: 0.2),
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
