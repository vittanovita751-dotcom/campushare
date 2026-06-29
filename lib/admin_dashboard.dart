import 'package:flutter/material.dart';
import 'admin_data.dart';
import 'screens/admin_login_screen.dart';
import 'screens/admin_home_tab.dart';
import 'screens/admin_users_tab.dart';
import 'screens/admin_items_tab.dart';
import 'screens/admin_transactions_tab.dart';
import 'screens/admin_reports_tab.dart';
import 'screens/admin_ratings_tab.dart';
import 'screens/admin_settings_tab.dart';

class AdminDashboardShell extends StatefulWidget {
  const AdminDashboardShell({super.key});

  @override
  State<AdminDashboardShell> createState() => _AdminDashboardShellState();
}

class _AdminDashboardShellState extends State<AdminDashboardShell> {
  int _currentTab = 0;
  bool _isSidebarExpanded = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> _tabTitles = [
    'Ringkasan Dashboard',
    'Manajemen Pengguna',
    'Manajemen Inventaris Barang',
    'Manajemen Transaksi',
    'Laporan & Pengaduan',
    'Reputasi & Rating Pengguna',
    'Pengaturan Sistem',
  ];

  Widget _buildActiveTab() {
    // PENTING: jangan pakai `const` di sini. Widget di-render di dalam
    // AnimatedBuilder yang mendengarkan AdminState.instance — kalau pakai
    // `const`, Flutter menganggap widgetnya identik antar rebuild dan akan
    // SKIP rebuild tab aktif, sehingga data baru (misalnya transaksi
    // peminjaman dari mahasiswa) tidak langsung muncul di dashboard admin.
    switch (_currentTab) {
      case 0:
        return AdminHomeTab();
      case 1:
        return AdminUsersTab();
      case 2:
        return AdminItemsTab();
      case 3:
        return AdminTransactionsTab();
      case 4:
        return AdminReportsTab();
      case 5:
        return AdminRatingsTab();
      case 6:
        return AdminSettingsTab();
      default:
        return AdminHomeTab();
    }
  }

  void _onMenuItemSelected(int index) {
    setState(() {
      _currentTab = index;
    });
    if (MediaQuery.of(context).size.width <= 1000) {
      Navigator.pop(context); // Close mobile drawer
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1000;

    return AnimatedBuilder(
      animation: AdminState.instance,
      builder: (context, child) {
        final unreadCount = AdminState.instance.notifications.where((n) => !n.isRead).length;

        // Drawer / Sidebar Widget
        Widget sidebarWidget = Container(
          width: _isSidebarExpanded ? 260 : 80,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(4, 0),
              )
            ],
            border: Border(right: BorderSide(color: Colors.grey.shade200, width: 1)),
          ),
          child: Column(
            children: [
              // Sidebar Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: _isSidebarExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF64B5F6).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: Color(0xFF1E88E5),
                        size: 24,
                      ),
                    ),
                    if (_isSidebarExpanded) ...[
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'CampuShare',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF0D47A1),
                              ),
                            ),
                            Text(
                              'Admin Hub',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]
                  ],
                ),
              ),
              const Divider(height: 1),
              const SizedBox(height: 16),
              // Menu Items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    _buildSidebarItem(0, Icons.dashboard_outlined, Icons.dashboard_rounded, 'Dashboard'),
                    _buildSidebarItem(1, Icons.people_outline_rounded, Icons.people_rounded, 'Pengguna'),
                    _buildSidebarItem(2, Icons.inventory_2_outlined, Icons.inventory_2_rounded, 'Barang'),
                    _buildSidebarItem(3, Icons.swap_horiz_rounded, Icons.swap_horizontal_circle_rounded, 'Transaksi'),
                    _buildSidebarItem(4, Icons.report_gmailerrorred_outlined, Icons.report_gmailerrorred_rounded, 'Laporan'),
                    _buildSidebarItem(5, Icons.star_outline_rounded, Icons.star_rounded, 'Rating & Reputasi'),
                    _buildSidebarItem(6, Icons.settings_outlined, Icons.settings_rounded, 'Pengaturan'),
                  ],
                ),
              ),
              // Sidebar Footer / Logout
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: _isSidebarExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
                  children: [
                    if (_isSidebarExpanded) ...[
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(0xFFBBDEFB),
                        child: Text('OK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0D47A1))),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Admin Okta',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              'Super Admin',
                              style: TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                    IconButton(
                      icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                      tooltip: 'Logout',
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

        return Scaffold(
          key: _scaffoldKey,
          drawer: !isDesktop ? Drawer(child: sidebarWidget) : null,
          body: Row(
            children: [
              if (isDesktop) sidebarWidget,
              Expanded(
                child: Container(
                  color: const Color(0xFFF5F7FA), // Soft light grey canvas
                  child: Column(
                    children: [
                      // Header Bar
                      _buildHeader(isDesktop, unreadCount),
                      // Active screen area
                      Expanded(
                        child: ClipRect(
                          child: _buildActiveTab(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSidebarItem(int index, IconData outlineIcon, IconData solidIcon, String title) {
    final isSelected = _currentTab == index;
    final icon = isSelected ? solidIcon : outlineIcon;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: () => _onMenuItemSelected(index),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE3F2FD) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: _isSidebarExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFF1E88E5) : Colors.grey.shade600,
                size: 22,
              ),
              if (_isSidebarExpanded) ...[
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? const Color(0xFF1E88E5) : Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDesktop, int unreadCount) {
    return SafeArea(
      bottom: false,
      child: _buildHeaderContent(isDesktop, unreadCount),
    );
  }

  Widget _buildHeaderContent(bool isDesktop, int unreadCount) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: Row(
        children: [
          // Sidebar toggler
          if (!isDesktop)
            IconButton(
              icon: const Icon(Icons.menu_rounded, size: 22),
              padding: const EdgeInsets.all(8),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            )
          else
            IconButton(
              icon: Icon(
                _isSidebarExpanded ? Icons.menu_open_rounded : Icons.menu_rounded,
                size: 22,
              ),
              padding: const EdgeInsets.all(8),
              onPressed: () => setState(() => _isSidebarExpanded = !_isSidebarExpanded),
            ),
          const SizedBox(width: 4),
          // Active Screen Title — center aligned & ellipsis on mobile
          Expanded(
            child: Text(
              _tabTitles[_currentTab],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF263238),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 4),
          // Simulasi — icon only on mobile, compact on all
          Tooltip(
            message: 'Simulasi Notifikasi Real-time',
            child: InkWell(
              onTap: () {
                AdminState.instance.simulateNewNotification();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.bolt_rounded, color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Expanded(child: Text('Notifikasi baru dipicu!', style: TextStyle(fontSize: 12))),
                      ],
                    ),
                    duration: const Duration(seconds: 2),
                    backgroundColor: const Color(0xFF64B5F6),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    margin: const EdgeInsets.all(12),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 10 : 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange.shade100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt_rounded, color: Colors.orangeAccent, size: 16),
                    if (isDesktop) ...[
                      const SizedBox(width: 4),
                      const Text('Simulasi', style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Notification Bell
          _buildNotificationBell(unreadCount),
          const SizedBox(width: 6),
          // Admin avatar only (no text on mobile to save space)
          CircleAvatar(
            radius: 16,
            backgroundImage: const NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=80'),
            backgroundColor: Colors.grey.shade200,
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildNotificationBell(int unreadCount) {
    return PopupMenuButton<int>(
      iconSize: 28,
      padding: const EdgeInsets.all(10),
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(Icons.notifications_rounded, color: Colors.grey.shade700, size: 28),
          if (unreadCount > 0)
            Positioned(
              right: -3,
              top: -3,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Text(
                  '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      itemBuilder: (context) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AdminState.instance.markNotificationsRead();
        });
        final notices = AdminState.instance.notifications;
        if (notices.isEmpty) {
          return [
            const PopupMenuItem(
              enabled: false,
              child: SizedBox(
                width: 320,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text('Tidak ada notifikasi baru', style: TextStyle(color: Colors.grey)),
                  ),
                ),
              ),
            )
          ];
        }

        return [
          PopupMenuItem(
            enabled: false,
            child: Container(
              width: 320,
              padding: const EdgeInsets.only(bottom: 8),
              // PERBAIKAN DI SINI: Memasukkan border ke dalam BoxDecoration
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
              ),
              child: Row(
                children: [
                  const Text(
                    'Notifikasi Terbaru',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 14),
                  ),
                  const Spacer(),
                  Text(
                    '${notices.length} Total',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF1E88E5)),
                  ),
                ],
              ),
            ),
          ),
          ...notices.map((n) {
            IconData icon = Icons.info_outline;
            Color iconColor = Colors.blue;
            if (n.type == 'user') {
              icon = Icons.person_add_rounded;
              iconColor = Colors.green;
            } else if (n.type == 'item') {
              icon = Icons.add_photo_alternate_rounded;
              iconColor = Colors.orange;
            } else if (n.type == 'transaction') {
              icon = Icons.swap_horiz_rounded;
              iconColor = Colors.blue;
            } else if (n.type == 'report') {
              icon = Icons.gavel_rounded;
              iconColor = Colors.red;
            }

            return PopupMenuItem<int>(
              value: n.id,
              child: SizedBox(
                width: 320,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: iconColor, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            n.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            n.message,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            n.time,
                            style: const TextStyle(fontSize: 9, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ];
      },
    );
  }
}