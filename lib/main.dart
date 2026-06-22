import 'package:flutter/material.dart';
import 'screens/admin_login_screen.dart';
import 'screens/student/student_splash_screen.dart';

void main() {
  runApp(const CampuShareApp());
}

class CampuShareApp extends StatelessWidget {
  const CampuShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CampuShare Portal',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const PortalSelectionScreen(),
    );
  }
}

class PortalSelectionScreen extends StatelessWidget {
  const PortalSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 700;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE3F2FD),
              Color(0xFFBBDEFB),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.share_location_rounded,
                  size: 64,
                  color: Color(0xFF1E88E5),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Selamat Datang di CampuShare',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Silakan pilih portal akses yang ingin Anda masuki',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 40),
                Flex(
                  direction: isDesktop ? Axis.horizontal : Axis.vertical,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Card 1: Mobile App Student
                    _buildSelectionCard(
                      context,
                      title: 'Aplikasi Mahasiswa (Mobile Simulation)',
                      description: 'Akses fitur meminjam, meminjamkan barang, chat, geolocation, rating & trust score.',
                      icon: Icons.phone_android_rounded,
                      color: const Color(0xFF1976D2),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const StudentSplashScreen()),
                        );
                      },
                    ),
                    const SizedBox(width: 24, height: 24),
                    // Card 2: Web Dashboard Admin
                    _buildSelectionCard(
                      context,
                      title: 'Dashboard Admin (Web Portal)',
                      description: 'Manajemen pengguna, audit barang, review transaksi, penanganan laporan, pengaturan sistem.',
                      icon: Icons.admin_panel_settings_rounded,
                      color: const Color(0xFF43A047),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final width = MediaQuery.of(context).size.width;
    final cardWidth = width > 700 ? 300.0 : double.infinity;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: cardWidth,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
          border: Border.all(color: Colors.grey.shade100, width: 1.5),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= DATABASE LOKAL MOCK (SIMULASI) =================
// Data User Awal
List<Map<String, dynamic>> lokalUsers = [
  {'id': 1, 'nama': 'Novita', 'alamat': 'Purwokerto', 'role': 'mahasiswa'},
  {'id': 2, 'nama': 'Budi', 'alamat': 'Banyumas', 'role': 'mahasiswa'},
  // Hanya satu admin (Okta) untuk menyetujui peminjaman
  {'id': 3, 'nama': 'Okta', 'alamat': 'Admin Center', 'role': 'admin'},
];

// Data Barang Awal
List<Map<String, dynamic>> lokalItems = [
  {'id': 1, 'nama_barang': 'Proyektor Epson', 'owner_id': 1, 'owner_name': 'Novita', 'status': 'tersedia', 'peminjam_sekarang': ''},
  {'id': 2, 'nama_barang': 'Kamera DSLR Canon', 'owner_id': 2, 'owner_name': 'Budi', 'status': 'tersedia', 'peminjam_sekarang': ''},
  {'id': 3, 'nama_barang': 'Speaker Portable', 'owner_id': 3, 'owner_name': 'Okta', 'status': 'tersedia', 'peminjam_sekarang': ''},
  // Barang di bawah ini dikelola oleh admin Okta sehingga semua peminjaman diarahkan ke Okta
  {'id': 4, 'nama_barang': 'Laptop Dell Inspiron', 'owner_id': 3, 'owner_name': 'Okta', 'status': 'tersedia', 'peminjam_sekarang': ''},
  {'id': 5, 'nama_barang': 'Microphone USB', 'owner_id': 3, 'owner_name': 'Okta', 'status': 'tersedia', 'peminjam_sekarang': ''},
  {'id': 6, 'nama_barang': 'Proyektor Mini', 'owner_id': 3, 'owner_name': 'Okta', 'status': 'tersedia', 'peminjam_sekarang': ''},
  {'id': 7, 'nama_barang': 'Tripod Kamera', 'owner_id': 3, 'owner_name': 'Okta', 'status': 'tersedia', 'peminjam_sekarang': ''},
  {'id': 8, 'nama_barang': 'Headset Gaming', 'owner_id': 3, 'owner_name': 'Okta', 'status': 'tersedia', 'peminjam_sekarang': ''},
  {'id': 9, 'nama_barang': 'Papan Tulis Portable', 'owner_id': 3, 'owner_name': 'Okta', 'status': 'tersedia', 'peminjam_sekarang': ''},
  {'id': 10, 'nama_barang': 'Kabel HDMI 5m', 'owner_id': 3, 'owner_name': 'Okta', 'status': 'tersedia', 'peminjam_sekarang': ''},
];

// Data Notifikasi / Pengajuan Pinjaman
List<Map<String, dynamic>> lokalLoans = [];

// State Pengguna yang Sedang Login
Map<String, dynamic>? currentUser;

// ================= SCREEN 1: REGISTRASI (TAMBAH NAMA BARU) =================
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  String _selectedRole = 'mahasiswa';

  void _prosesDaftar() {
    if (_nameController.text.isEmpty || _alamatController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua kolom harus diisi!')),
      );
      return;
    }

    // Tambah data baru ke list lokalUsers
    int newId = lokalUsers.length + 1;
    lokalUsers.add({
      'id': newId,
      'nama': _nameController.text,
      'alamat': _alamatController.text,
      'role': _selectedRole,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pendaftaran Berhasil! Data otomatis masuk database lokal.')),
    );
    Navigator.pop(context); // Kembali ke halaman login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CampuShare - Daftar Akun')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nama Lengkap Baru', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _alamatController,
              decoration: const InputDecoration(labelText: 'Alamat Tinggal', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedRole,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'mahasiswa', child: Text('Mahasiswa')),
                DropdownMenuItem(value: 'admin', child: Text('Admin Kampus')),
              ],
              onChanged: (value) => setState(() => _selectedRole = value!),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _prosesDaftar,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size.fromHeight(50)),
              child: const Text('Daftar & Simpan', style: TextStyle(color: Colors.white, fontSize: 16)),
            )
          ],
        ),
      ),
    );
  }
}

// ================= SCREEN 2: LOGIN SCREEN =================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedRole = 'mahasiswa';

  void _prosesLogin() {
    if (_nameController.text.isEmpty) return;

    // Cari nama dan role di list lokalUsers
    var userKetemu = lokalUsers.firstWhere(
      (user) => user['nama'].toLowerCase() == _nameController.text.toLowerCase() && user['role'] == _selectedRole,
      orElse: () => {},
    );

    if (userKetemu.isNotEmpty) {
      currentUser = userKetemu;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User tidak ditemukan! Coba daftar akun dulu.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CampuShare - Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🏫 CampuShare Hub', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.indigo)),
            const SizedBox(height: 30),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Masukkan Nama Lengkap', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedRole,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'mahasiswa', child: Text('Mahasiswa')),
                DropdownMenuItem(value: 'admin', child: Text('Admin Kampus')),
              ],
              onChanged: (value) => setState(() => _selectedRole = value!),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _prosesLogin,
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              child: const Text('Masuk Aplikasi', style: TextStyle(fontSize: 16)),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
              },
              child: const Text('Belum punya akun? Daftar di Sini'),
            )
          ],
        ),
      ),
    );
  }
}

// ================= SCREEN 3: DASHBOARD UTAMA =================
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _itemNameController = TextEditingController();

  bool get _isAdmin => currentUser?['role'] == 'admin';
  bool get _isMahasiswa => currentUser?['role'] == 'mahasiswa';

  @override
  void dispose() {
    _itemNameController.dispose();
    super.dispose();
  }

  void _ajukanPeminjaman(Map<String, dynamic> barang) {
    // Cari admin Okta untuk menerima notifikasi peminjaman
    var adminOkta = lokalUsers.firstWhere((u) => u['nama'].toString().toLowerCase() == 'okta', orElse: () => {});
    int ownerForNotification = (adminOkta.isNotEmpty && adminOkta['id'] != null) ? adminOkta['id'] : barang['owner_id'];

    setState(() {
      lokalLoans.add({
        'id': lokalLoans.length + 1,
        'item_id': barang['id'],
        'nama_barang': barang['nama_barang'],
        // Arahkan semua peminjaman mahasiswa ke admin Okta agar bisa diproses segera
        'owner_id': ownerForNotification,
        'borrower_name': currentUser?['nama'],
        'batas_waktu': '3 Hari Ke Depan',
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pengajuan pinjam ${barang['nama_barang']} terkirim ke admin Okta.')),
    );
  }

  void _tambahBarangBaru() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Barang Baru'),
          content: TextField(
            controller: _itemNameController,
            decoration: const InputDecoration(
              labelText: 'Nama Barang',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _itemNameController.clear();
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_itemNameController.text.trim().isEmpty) {
                  return;
                }
                setState(() {
                  int newItemId = lokalItems.length + 1;
                  lokalItems.add({
                    'id': newItemId,
                    'nama_barang': _itemNameController.text.trim(),
                    'owner_id': currentUser?['id'],
                    'owner_name': currentUser?['nama'],
                    'status': 'tersedia',
                    'peminjam_sekarang': '',
                  });
                });
                _itemNameController.clear();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Barang baru berhasil ditambahkan.')),
                );
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _responsPeminjaman(Map<String, dynamic> loan, bool disetujui) {
    setState(() {
      if (disetujui) {
        // Update status barang di list lokal
        var barang = lokalItems.firstWhere((item) => item['id'] == loan['item_id']);
        barang['status'] = 'dipinjam';
        barang['peminjam_sekarang'] = loan['borrower_name'];
      }
      // Hapus dari daftar notifikasi setelah direspons
      lokalLoans.removeWhere((l) => l['id'] == loan['id']);
    });
  }

  void _kembalikanBarang(Map<String, dynamic> barang) {
    setState(() {
      barang['status'] = 'tersedia';
      barang['peminjam_sekarang'] = '';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Barang ${barang['nama_barang']} berhasil dikembalikan.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter notifikasi peminjaman yang masuk ke user ini (sebagai pemilik barang)
    List<Map<String, dynamic>> myNotifications = lokalLoans.where((loan) => loan['owner_id'] == currentUser?['id']).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('CampuShare (${currentUser?['nama']})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          if (_isAdmin) ...[
            const Text('👨‍💼 Admin Menu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _tambahBarangBaru,
              icon: const Icon(Icons.add),
              label: const Text('+ Tambah Barang Baru'),
            ),
            const SizedBox(height: 20),
          ],

          if (myNotifications.isNotEmpty) ...[
            const Text('🔔 Notifikasi Peminjaman Masuk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange)),
            const Divider(),
            ...myNotifications.map((notif) => Card(
              color: Colors.orange.shade50,
              child: ListTile(
                title: Text("${notif['borrower_name']} ingin meminjam [${notif['nama_barang']}]"),
                subtitle: Text("Batas Waktu: ${notif['batas_waktu']}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.check, color: Colors.green), onPressed: () => _responsPeminjaman(notif, true)),
                    IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () => _responsPeminjaman(notif, false)),
                  ],
                ),
              ),
            )),
            const SizedBox(height: 20),
          ] else if (_isAdmin) ...[
            Card(
              color: Colors.blue.shade50,
              child: const ListTile(
                leading: Icon(Icons.info_outline, color: Colors.blue),
                title: Text('Tidak ada notifikasi peminjaman saat ini.'),
              ),
            ),
            const SizedBox(height: 20),
          ],

          const Text('📦 Daftar Inventaris Barang Kampus', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(),
          ...lokalItems.map((barang) {
            bool dipinjam = barang['status'] == 'dipinjam';
            bool milikSendiri = barang['owner_id'] == currentUser?['id'];

            return Card(
              child: ListTile(
                leading: Icon(dipinjam ? Icons.lock : Icons.lock_open, color: dipinjam ? Colors.red : Colors.green),
                title: Text(barang['nama_barang']),
                subtitle: Text(dipinjam
                    ? "Status: Dipinjam oleh ${barang['peminjam_sekarang']}"
                    : "Status: Tersedia (Pemilik: ${barang['owner_name']})"),
                trailing: _isMahasiswa && !dipinjam && !milikSendiri
                    ? ElevatedButton(
                        onPressed: () => _ajukanPeminjaman(barang),
                        child: const Text('Pinjam'),
                      )
                    : (dipinjam && barang['peminjam_sekarang'] == currentUser?['nama']
                        ? ElevatedButton(
                            onPressed: () => _kembalikanBarang(barang),
                            child: const Text('Kembalikan'),
                          )
                        : (dipinjam
                            ? const Text('SHARED 📢', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))
                            : null)),
              ),
            );
          }),
        ],
      ),
    );
  }
}