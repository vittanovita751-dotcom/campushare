import 'package:flutter/material.dart';
import '../../student_data.dart';
import '../../widgets/item_image.dart';
import 'student_item_detail_screen.dart';
import 'student_shell.dart'; // untuk StudentShellState.navigateToSearch

class StudentHomeTab extends StatefulWidget {
  const StudentHomeTab({super.key});

  @override
  State<StudentHomeTab> createState() => _StudentHomeTabState();
}

class _StudentHomeTabState extends State<StudentHomeTab> {
  String _selectedCategory = '';
  String _selectedLocation = 'Semua Lokasi'; // ← state lokasi baru
  int _lastNotifCount = 0;

  // ── Daftar lokasi/fakultas sesuai data barang yang ada ──────────────────
  static const List<Map<String, dynamic>> _locations = [
    {'name': 'Semua Lokasi',    'icon': Icons.location_city_rounded,    'short': 'Semua'},
    {'name': 'Fasilkom',        'icon': Icons.computer_rounded,          'short': 'Fasilkom'},
    {'name': 'Fakultas Teknik', 'icon': Icons.engineering_rounded,       'short': 'FT'},
    {'name': 'FEB',             'icon': Icons.account_balance_rounded,   'short': 'FEB'},
    {'name': 'FK',              'icon': Icons.local_hospital_rounded,    'short': 'FK'},
    {'name': 'FMIPA',           'icon': Icons.science_rounded,           'short': 'FMIPA'},
    {'name': 'FH',              'icon': Icons.gavel_rounded,             'short': 'FH'},
    {'name': 'FIB',             'icon': Icons.history_edu_rounded,       'short': 'FIB'},
  ];

  @override
  void initState() {
    super.initState();
    final state = StudentState.instance;
    _lastNotifCount = state.notifications.length;
    state.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    final state = StudentState.instance;
    if (state.notifications.length > _lastNotifCount && mounted) {
      final newest = state.notifications.first;
      _lastNotifCount = state.notifications.length;
      _showNotificationBanner(newest);
    } else {
      _lastNotifCount = state.notifications.length;
    }
  }

  void _showNotificationBanner(StudentNotification notif) {
    final isSuccess = notif.title.contains('Disetujui') || notif.title.contains('Diterima');
    final isError = notif.title.contains('Ditolak');
    Color bgColor = const Color(0xFF1E88E5);
    IconData iconData = Icons.notifications_active_rounded;
    if (isSuccess) { bgColor = Colors.green.shade600; iconData = Icons.check_circle_rounded; }
    else if (isError) { bgColor = Colors.redAccent; iconData = Icons.cancel_rounded; }
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(iconData, color: Colors.white, size: 22),
        const SizedBox(width: 12),
        Expanded(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(notif.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
          Text(notif.message, style: const TextStyle(fontSize: 11, color: Colors.white70), maxLines: 2, overflow: TextOverflow.ellipsis),
        ])),
      ]),
      backgroundColor: bgColor,
      duration: const Duration(seconds: 4),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      action: SnackBarAction(label: 'Lihat', textColor: Colors.white,
        onPressed: () => _showNotificationsBottomSheet(context, StudentState.instance)),
    ));
  }

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Buku', 'icon': Icons.book_rounded},
    {'name': 'Laptop', 'icon': Icons.laptop_chromebook_rounded},
    {'name': 'Proyektor', 'icon': Icons.videocam_rounded},
    {'name': 'Kabel HDMI', 'icon': Icons.settings_input_hdmi_rounded},
    {'name': 'Jas Laboratorium', 'icon': Icons.science_rounded},
    {'name': 'Kendaraan', 'icon': Icons.directions_bike_rounded},
  ];

  // ── Controller untuk search bar di beranda ───────────────────────────────
  final TextEditingController _searchController = TextEditingController();

  // ── Mapping kata kunci → kategori ────────────────────────────────────────
  static const Map<String, String> _keywordToCategory = {
    'buku': 'Buku', 'book': 'Buku', 'kalkulus': 'Buku', 'novel': 'Buku',
    'referensi': 'Buku', 'modul': 'Buku', 'diktat': 'Buku',
    'laptop': 'Laptop', 'komputer': 'Laptop', 'notebook': 'Laptop',
    'asus': 'Laptop', 'dell': 'Laptop', 'lenovo': 'Laptop', 'macbook': 'Laptop',
    'proyektor': 'Proyektor', 'projector': 'Proyektor', 'epson': 'Proyektor',
    'tripod': 'Proyektor', 'kamera': 'Proyektor', 'camera': 'Proyektor',
    'hdmi': 'Kabel HDMI', 'kabel': 'Kabel HDMI', 'cable': 'Kabel HDMI',
    'vention': 'Kabel HDMI', 'powerbank': 'Kabel HDMI', 'power bank': 'Kabel HDMI',
    'jas': 'Jas Laboratorium', 'lab': 'Jas Laboratorium', 'laboratorium': 'Jas Laboratorium',
    'kimia': 'Jas Laboratorium', 'fisika': 'Jas Laboratorium',
    'motor': 'Kendaraan', 'kendaraan': 'Kendaraan', 'honda': 'Kendaraan',
    'yamaha': 'Kendaraan', 'beat': 'Kendaraan', 'mio': 'Kendaraan',
    'sepeda': 'Kendaraan', 'vespa': 'Kendaraan',
  };

  String _detectCategory(String text) {
    final lower = text.toLowerCase().trim();
    for (final entry in _keywordToCategory.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return 'Semua';
  }

  // ── Bottom sheet pilih lokasi/fakultas ───────────────────────────────────
  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      // PERBAIKAN 1: isScrollControlled=true agar sheet bisa memenuhi layar
      // dan tidak overflow vertikal
      isScrollControlled: true,
      // PERBAIKAN 2: useSafeArea agar tidak tertutup system bar bawah
      useSafeArea: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            // PERBAIKAN 3: DraggableScrollableSheet agar bisa ditarik ke atas
            // dan seluruh konten bisa diakses tanpa terpotong
            return DraggableScrollableSheet(
              initialChildSize: 0.6,   // tampil 60% layar awalnya
              minChildSize: 0.4,       // minimum 40%
              maxChildSize: 0.92,      // bisa ditarik sampai 92% layar
              expand: false,
              builder: (ctx, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Handle drag indicator — tidak ikut scroll
                      Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 4),
                        child: Center(
                          child: Container(
                            width: 40, height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                      // Konten scrollable
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E88E5).withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.location_on_rounded,
                                      color: Color(0xFF1E88E5), size: 20),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Pilih Lokasi Barang',
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0D47A1)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Tampilkan barang berdasarkan lokasi/fakultas',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 20),
                            // Grid tombol lokasi — hanya tampilkan "Semua" + fakultas yang punya barang
                            Builder(builder: (ctx) {
                              final activeLocations = _locations.where((loc) {
                                if (loc['name'] == 'Semua Lokasi') return true;
                                return StudentState.instance.items
                                    .any((item) => item.facultyLocation == loc['name']);
                              }).toList();
                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 3.2,
                                ),
                                itemCount: activeLocations.length,
                                itemBuilder: (ctx, index) {
                                  final loc = activeLocations[index];
                                  final isSelected = _selectedLocation == loc['name'];
                                  return InkWell(
                                    onTap: () {
                                      setState(() { _selectedLocation = loc['name']; });
                                      Navigator.pop(ctx);
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 180),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isSelected ? const Color(0xFF1E88E5) : Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected ? const Color(0xFF1E88E5) : Colors.grey.shade200,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(loc['icon'] as IconData, size: 18,
                                              color: isSelected ? Colors.white : const Color(0xFF1E88E5)),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              loc['short'] as String,
                                              style: TextStyle(
                                                fontSize: 13, fontWeight: FontWeight.bold,
                                                color: isSelected ? Colors.white : Colors.black87,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (isSelected)
                                            const Icon(Icons.check_circle_rounded, size: 14, color: Colors.white),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 8),
                            // Daftar ringkasan — hanya fakultas yang punya barang tersedia
                            ...() {
                              final rows = <Widget>[];
                              for (final loc in _locations) {
                                if (loc['name'] == 'Semua Lokasi') continue;
                                final count = StudentState.instance.items
                                    .where((item) => item.facultyLocation == loc['name'] && item.status == 'Tersedia')
                                    .length;
                                if (count == 0) continue; // skip fakultas tanpa barang
                                rows.add(Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Icon(loc['icon'] as IconData, size: 14, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Text(
                                        loc['name'] as String,
                                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1E88E5).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '$count barang tersedia',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF1E88E5),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ));
                              }
                              return rows;
                            }(),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _handleSearchSubmit(String query) {
    if (query.trim().isEmpty) return;
    final detectedCategory = _detectCategory(query);
    final shellState = context.findAncestorStateOfType<StudentShellState>();
    shellState?.navigateToSearch(
      query: detectedCategory != 'Semua' ? '' : query,
      category: detectedCategory,
    );
    _searchController.clear();
  }

  @override
  void dispose() {
    _searchController.dispose();
    StudentState.instance.removeListener(_onStateChanged);
    super.dispose();
  }

  void _showNotificationsBottomSheet(BuildContext context, StudentState state) {
    state.markNotificationsRead();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return ListenableBuilder(
          listenable: state,
          builder: (context, child) {
            final notices = state.notifications;
            return Container(
              height: MediaQuery.of(context).size.height * 0.65,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Notifikasi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D47A1),
                          ),
                        ),
                        if (notices.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              state.clearAllNotifications();
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Hapus Semua',
                              style: TextStyle(color: Colors.redAccent, fontSize: 12),
                            ),
                          )
                      ],
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: notices.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.notifications_none_rounded,
                                  size: 64,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Belum ada notifikasi',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            itemCount: notices.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final note = notices[index];
                              final isSuccess = note.title.contains('Disetujui') || note.title.contains('Diterima');
                              final isError = note.title.contains('Ditolak');
                              
                              Color iconBgColor = const Color(0xFF64B5F6).withValues(alpha: 0.12);
                              Color iconColor = const Color(0xFF1E88E5);
                              IconData iconData = Icons.notifications_active_outlined;

                              if (isSuccess) {
                                iconBgColor = Colors.green.shade50;
                                iconColor = Colors.green;
                                iconData = Icons.check_circle_outline_rounded;
                              } else if (isError) {
                                iconBgColor = Colors.red.shade50;
                                iconColor = Colors.redAccent;
                                iconData = Icons.error_outline_rounded;
                              }

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: iconBgColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        iconData,
                                        color: iconColor,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            note.title,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            note.message,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade700,
                                              height: 1.3,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            note.time,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = StudentState.instance;

    // ── Filter nearbyItems berdasarkan lokasi yang dipilih ─────────────────
    final nearbyItems = state.items.where((i) {
      if (_selectedCategory.isNotEmpty && i.category != _selectedCategory) return false;
      if (!i.status.contains('Tersedia')) return false;
      if (_selectedLocation == 'Semua Lokasi') return true;
      return i.facultyLocation == _selectedLocation;
    }).toList();

    final latestItems = state.items.where((i) {
      if (_selectedCategory.isNotEmpty && i.category != _selectedCategory) return false;
      return i.status == 'Tersedia';
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(state.currentUser?.avatarUrl ?? 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=80'),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Halo, Mahasiswa!', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)),
                Text(state.currentUser?.name ?? 'Novita Sari', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
              ],
            ),
          ],
        ),
        actions: [
          ListenableBuilder(
            listenable: state,
            builder: (context, child) {
              final unreadCount = state.notifications.where((n) => !n.isRead).length;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded, color: Colors.black87),
                    onPressed: () => _showNotificationsBottomSheet(context, state),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
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
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBarSection(),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Text(
                'Kategori Barang',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
              ),
            ),
            _buildCategoriesSection(),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _selectedLocation == 'Semua Lokasi'
                          ? 'Barang di Semua Fakultas'
                          : 'Barang di $_selectedLocation',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      final shellState = context.findAncestorStateOfType<StudentShellState>();
                      shellState?.navigateToSearch();
                    },
                    icon: const Icon(Icons.grid_view_rounded, size: 14, color: Color(0xFF1E88E5)),
                    label: const Text('Lihat Semua', style: TextStyle(fontSize: 12, color: Color(0xFF1E88E5))),
                  )
                ],
              ),
            ),
            _buildNearbySection(nearbyItems),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Text(
                'Barang Terbaru',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
              ),
            ),
            _buildLatestSection(latestItems),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBarSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: Color(0xFF64B5F6), size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Cari barang, buku, laptop, motor...',
                  hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                  border: InputBorder.none,
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: _handleSearchSubmit, // ← tekan Enter/Search
                onTap: () {
                  // Ketuk search bar langsung buka halaman Cari
                  final shellState =
                      context.findAncestorStateOfType<StudentShellState>();
                  shellState?.navigateToSearch();
                },
              ),
            ),
            VerticalDivider(
                color: Colors.grey.shade300,
                width: 24,
                thickness: 1,
                indent: 12,
                endIndent: 12),
            // ── Tombol lokasi — bisa diklik untuk ganti lokasi ──────────
            GestureDetector(
              onTap: _showLocationPicker,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: _selectedLocation == 'Semua Lokasi'
                        ? Colors.grey
                        : const Color(0xFF1E88E5),
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 90),
                    child: Text(
                      _selectedLocation == 'Semua Lokasi'
                          ? 'Lokasi'
                          : _selectedLocation,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _selectedLocation == 'Semua Lokasi'
                            ? Colors.black54
                            : const Color(0xFF1E88E5),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.arrow_drop_down_rounded,
                      size: 16,
                      color: _selectedLocation == 'Semua Lokasi'
                          ? Colors.grey
                          : const Color(0xFF1E88E5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat['name'];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedCategory = isSelected ? '' : cat['name'];
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 78,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF64B5F6) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.01),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      cat['icon'],
                      color: isSelected ? Colors.white : const Color(0xFF64B5F6),
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        cat['name'],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNearbySection(List<StudentItem> itemsList) {
    if (itemsList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24.0),
        child: Center(child: Text('Tidak ada barang terdekat di kategori ini.', style: TextStyle(color: Colors.grey, fontSize: 13))),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.76,
      ),
      itemCount: itemsList.length,
      itemBuilder: (context, index) {
        final item = itemsList[index];
        return _buildItemCard(item);
      },
    );
  }

  Widget _buildLatestSection(List<StudentItem> itemsList) {
    if (itemsList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24.0),
        child: Center(child: Text('Tidak ada barang terbaru di kategori ini.', style: TextStyle(color: Colors.grey, fontSize: 13))),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: itemsList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = itemsList[index];
        return _buildItemRow(item);
      },
    );
  }

  Widget _buildItemCard(StudentItem item) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => StudentItemDetailScreen(item: item)),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.015),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ItemImage(
                item: item,
                width: double.infinity,
                fit: BoxFit.cover,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF64B5F6).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.category,
                      style: const TextStyle(color: Color(0xFF1E88E5), fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: Colors.grey, size: 12),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          item.facultyLocation,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 12),
                          const SizedBox(width: 2),
                          Text('${item.ownerRating}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Trust: ${item.ownerTrustScore}',
                          style: TextStyle(color: Colors.green.shade700, fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(StudentItem item) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => StudentItemDetailScreen(item: item)),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.01),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ItemImage(
              item: item,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.circular(12),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF64B5F6).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.category,
                          style: const TextStyle(color: Color(0xFF1E88E5), fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 12),
                          const SizedBox(width: 2),
                          Text('${item.ownerRating}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: Colors.grey, size: 12),
                      const SizedBox(width: 2),
                      Text(item.facultyLocation, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      const Spacer(),
                      Text(
                        'Trust Score: ${item.ownerTrustScore}',
                        style: TextStyle(color: Colors.green.shade600, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}