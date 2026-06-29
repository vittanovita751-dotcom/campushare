import 'package:flutter/material.dart';
import 'student_data.dart';

// User Model Representation
class AdminUser {
  final int id;
  String name;
  String nim;
  String email;
  String faculty;
  double rating;
  int trustScore;
  String status; // 'Aktif' or 'Ditangguhkan'
  String avatarUrl;

  AdminUser({
    required this.id,
    required this.name,
    required this.nim,
    required this.email,
    required this.faculty,
    required this.rating,
    required this.trustScore,
    required this.status,
    required this.avatarUrl,
  });
}

// Item Model Representation
class AdminItem {
  final int id;
  String name;
  String category;
  String owner;
  String location;
  String status; // 'Tersedia', 'Dipinjam', 'Bermasalah'
  String imageUrl;
  bool isAsset; // true = assets/images/items/, false = network URL

  AdminItem({
    required this.id,
    required this.name,
    required this.category,
    required this.owner,
    required this.location,
    required this.status,
    required this.imageUrl,
    this.isAsset = false,
  });
}

// Transaction Model Representation
class AdminTransaction {
  final String id;
  String itemName;
  String borrower;
  String owner;
  String borrowDate;
  String returnDate;
  String status; // 'Menunggu Persetujuan', 'Dipinjam', 'Dikembalikan', 'Ditolak'

  AdminTransaction({
    required this.id,
    required this.itemName,
    required this.borrower,
    required this.owner,
    required this.borrowDate,
    required this.returnDate,
    required this.status,
  });
}

// Report Model Representation
class AdminReport {
  final int id;
  String reporter;
  String reportedUser;
  String type; // 'Kerusakan Barang', 'Keterlambatan', 'Perilaku Buruk', 'Lainnya'
  String description;
  String date;
  String status; // 'Menunggu Tinjauan', 'Peringatan Dikirim', 'Selesai', 'User Ditangguhkan'

  AdminReport({
    required this.id,
    required this.reporter,
    required this.reportedUser,
    required this.type,
    required this.description,
    required this.date,
    required this.status,
  });
}

// Notification Model Representation
class AdminNotification {
  final int id;
  String title;
  String message;
  String type; // 'user', 'item', 'transaction', 'report'
  String time;
  bool isRead;

  AdminNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.time,
    this.isRead = false,
  });
}

// System settings classes
class AppBanner {
  final int id;
  String title;
  String imageUrl;
  bool isActive;

  AppBanner({required this.id, required this.title, required this.imageUrl, required this.isActive});
}

class AppFaq {
  final int id;
  String question;
  String answer;

  AppFaq({required this.id, required this.question, required this.answer});
}

class AppPolicy {
  final int id;
  String title;
  String content;

  AppPolicy({required this.id, required this.title, required this.content});
}

// Singleton state management for CampuShare Admin
class AdminState extends ChangeNotifier {
  static final AdminState instance = AdminState._internal();
  AdminState._internal() {
    _initializeMockData();
  }

  // Lists
  final List<AdminUser> users = [];
  final List<AdminItem> items = [];
  final List<AdminTransaction> transactions = [];
  final List<AdminReport> reports = [];
  final List<AdminNotification> notifications = [];
  
  final List<String> categories = [];
  final List<String> faculties = [];
  final List<AppBanner> banners = [];
  final List<AppFaq> faqs = [];
  final List<AppPolicy> policies = [];

  // Initialize all states
  void _initializeMockData() {
    // Categories
    categories.addAll(['Buku', 'Laptop', 'Proyektor', 'Kabel HDMI', 'Jas Laboratorium', 'Kendaraan']);

    // Faculties
    faculties.addAll([
      'Fakultas Ilmu Komputer (Fasilkom)',
      'Fakultas Teknik (FT)',
      'Fakultas Ekonomi & Bisnis (FEB)',
      'Fakultas Kedokteran (FK)',
      'Fakultas MIPA (FMIPA)',
      'Fakultas Hukum (FH)',
      'Fakultas Ilmu Budaya (FIB)'
    ]);

    // Users
    users.addAll([
      AdminUser(id: 1, name: 'Novita Sari', nim: '21.11.4589', email: 'novita.sari@std.ac.id', faculty: 'Fasilkom', rating: 4.9, trustScore: 98, status: 'Aktif', avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150'),
      AdminUser(id: 2, name: 'Budi Raharjo', nim: '21.12.5690', email: 'budi.raharjo@std.ac.id', faculty: 'FT', rating: 4.6, trustScore: 92, status: 'Aktif', avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150'),
      AdminUser(id: 3, name: 'Aditya Pratama', nim: '22.01.1256', email: 'aditya.p@std.ac.id', faculty: 'FEB', rating: 4.8, trustScore: 95, status: 'Aktif', avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150'),
      AdminUser(id: 4, name: 'Siti Aminah', nim: '20.08.3245', email: 'siti.aminah@std.ac.id', faculty: 'FK', rating: 4.2, trustScore: 85, status: 'Aktif', avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150'),
      AdminUser(id: 5, name: 'Genta Perkasa', nim: '22.11.9022', email: 'genta.perkasa@std.ac.id', faculty: 'Fasilkom', rating: 3.5, trustScore: 70, status: 'Ditangguhkan', avatarUrl: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150'),
      AdminUser(id: 6, name: 'Rani Wijaya', nim: '21.05.7712', email: 'rani.wijaya@std.ac.id', faculty: 'FMIPA', rating: 4.7, trustScore: 94, status: 'Aktif', avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150'),
    ]);

    // Items — sync from StudentState (single source of truth)
    _syncItemsFromStudentState();

    // Transactions
    transactions.addAll([
      AdminTransaction(id: 'TX-10042', itemName: 'Proyektor Epson EB-X06', borrower: 'Budi Raharjo', owner: 'Novita Sari', borrowDate: '2026-06-18', returnDate: '2026-06-20', status: 'Dikembalikan'),
      AdminTransaction(id: 'TX-10043', itemName: 'Kamera DSLR Canon EOS 3000D', borrower: 'Aditya Pratama', owner: 'Budi Raharjo', borrowDate: '2026-06-20', returnDate: '2026-06-22', status: 'Dipinjam'),
      AdminTransaction(id: 'TX-10044', itemName: 'Laptop Dell Inspiron 15', borrower: 'Siti Aminah', owner: 'Rani Wijaya', borrowDate: '2026-06-21', returnDate: '2026-06-23', status: 'Menunggu Persetujuan'),
      AdminTransaction(id: 'TX-10045', itemName: 'Kabel HDMI Vention 5 Meter', borrower: 'Genta Perkasa', owner: 'Aditya Pratama', borrowDate: '2026-06-15', returnDate: '2026-06-17', status: 'Ditolak'),
      AdminTransaction(id: 'TX-10046', itemName: 'Honda Beat FI 2019', borrower: 'Novita Sari', owner: 'Budi Raharjo', borrowDate: '2026-06-21', returnDate: '2026-06-24', status: 'Dipinjam'),
    ]);

    // Reports
    reports.addAll([
      AdminReport(id: 1, reporter: 'Siti Aminah', reportedUser: 'Budi Raharjo', type: 'Kerusakan Barang', description: 'Jas lab yang dipinjam kembali dengan noda tinta permanen yang besar di lengan kanan.', date: '2026-06-19', status: 'Menunggu Tinjauan'),
      AdminReport(id: 2, reporter: 'Novita Sari', reportedUser: 'Genta Perkasa', type: 'Keterlambatan', description: 'Proyektor tidak dikembalikan tepat waktu selama 3 hari tanpa memberikan kabar sama sekali.', date: '2026-06-14', status: 'Peringatan Dikirim'),
      AdminReport(id: 3, reporter: 'Aditya Pratama', reportedUser: 'Siti Aminah', type: 'Perilaku Buruk', description: 'Membatalkan pinjaman secara sepihak setelah saya menunggu selama 1 jam di tempat janjian.', date: '2026-06-10', status: 'Selesai'),
    ]);

    // Banners
    banners.addAll([
      AppBanner(id: 1, title: 'Poster Event Berbagi Kampus', imageUrl: 'https://images.unsplash.com/photo-1523240795612-9a054b0db644?w=400', isActive: true),
      AppBanner(id: 2, title: 'Tips Aman Meminjam Barang', imageUrl: 'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=400', isActive: true),
      AppBanner(id: 3, title: 'Promo Kerjasama BEM Universitas', imageUrl: 'https://images.unsplash.com/photo-1524178232363-1fb2b075b655?w=400', isActive: false),
    ]);

    // FAQs
    faqs.addAll([
      AppFaq(id: 1, question: 'Bagaimana jika barang yang saya pinjam rusak?', answer: 'Anda dapat melaporkan kerusakan tersebut melalui form pengembalian atau langsung berdiskusi dengan pemilik barang. Admin juga dapat menengahi jika ada perselisihan.'),
      AppFaq(id: 2, question: 'Apakah peminjaman barang ini berbayar?', answer: 'Platform CampuShare ditujukan untuk peminjaman gratis (sukarela) antar mahasiswa demi menunjang aktivitas belajar.'),
      AppFaq(id: 3, question: 'Bagaimana cara menaikkan Trust Score?', answer: 'Kembalikan barang tepat waktu, jaga kondisi barang pinjaman dengan baik, dan berikan penilaian ulasan yang jujur kepada pengguna lain.'),
    ]);

    // Policies
    policies.addAll([
      AppPolicy(id: 1, title: 'Syarat dan Ketentuan Peminjam', content: 'Peminjam bertanggung jawab penuh atas barang yang dipinjam. Peminjam wajib mengembalikan barang dalam kondisi semula dan tepat waktu sesuai batas durasi yang disepakati.'),
      AppPolicy(id: 2, title: 'Tanggung Jawab Pemilik Barang', content: 'Pemilik barang wajib menjelaskan kondisi barang secara jujur pada deskripsi serta memastikan barang dalam keadaan aman dan layak pakai sebelum dipinjamkan.'),
      AppPolicy(id: 3, title: 'Sanksi Keterlambatan dan Pelanggaran', content: 'Keterlambatan pengembalian tanpa konfirmasi akan mengurangi Trust Score sebesar 5 poin per hari. Jika Trust Score mencapai di bawah 50, akun mahasiswa akan dinonaktifkan sementara.'),
    ]);

    // Notifications
    notifications.addAll([
      AdminNotification(id: 1, title: 'Pengguna Baru Terdaftar', message: 'Rani Wijaya (NIM: 21.05.7712) telah mendaftar di platform.', type: 'user', time: '5 menit yang lalu'),
      AdminNotification(id: 2, title: 'Pengajuan Pinjam Baru', message: 'Siti Aminah mengajukan peminjaman Laptop Dell Inspiron 15.', type: 'transaction', time: '12 menit yang lalu'),
      AdminNotification(id: 3, title: 'Barang Baru Ditambahkan', message: 'Budi Raharjo menambahkan Honda Beat FI 2019 ke kategori Kendaraan.', type: 'item', time: '35 menit yang lalu'),
      AdminNotification(id: 4, title: 'Laporan Kerusakan Masuk', message: 'Siti Aminah melaporkan kerusakan barang oleh Budi Raharjo.', type: 'report', time: '1 jam yang lalu'),
    ]);
  }

  // --- ACTIONS ---

  // User Actions
  void registerOrAddUser({
    required String name,
    required String nim,
    required String email,
    required String faculty,
  }) {
    final exists = users.any((u) => u.email.toLowerCase() == email.toLowerCase() || u.nim == nim);
    if (!exists) {
      final newUser = AdminUser(
        id: users.isNotEmpty ? (users.map((u) => u.id).reduce((a, b) => a > b ? a : b) + 1) : 1,
        name: name,
        nim: nim,
        email: email,
        faculty: faculty,
        rating: 5.0,
        trustScore: 100,
        status: 'Aktif',
        avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      );
      users.add(newUser);
      
      // Tambahkan notifikasi ke Admin
      addNotification(
        'Pengguna Baru Terdaftar',
        '$name (NIM: $nim) mendaftar di platform.',
        'user',
      );
      notifyListeners();
    }
  }

  void suspendUser(int id) {
    final idx = users.indexWhere((u) => u.id == id);
    if (idx != -1) {
      users[idx].status = users[idx].status == 'Aktif' ? 'Ditangguhkan' : 'Aktif';
      notifyListeners();
    }
  }

  void deleteUser(int id) {
    users.removeWhere((u) => u.id == id);
    notifyListeners();
  }

  void editUser(int id, String newName, String newNim, String newEmail, String newFaculty, int trustScore) {
    final idx = users.indexWhere((u) => u.id == id);
    if (idx != -1) {
      users[idx].name = newName;
      users[idx].nim = newNim;
      users[idx].email = newEmail;
      users[idx].faculty = newFaculty;
      users[idx].trustScore = trustScore;
      notifyListeners();
    }
  }

  // Item Actions
  /// Sync items dari StudentState — single source of truth.
  /// Dipanggil saat init dan setiap kali student menambah/mengubah barang.
  void _syncItemsFromStudentState() {
    items.clear();
    for (final s in StudentState.instance.items) {
      items.add(AdminItem(
        id: s.id,
        name: s.name,
        category: s.category,
        owner: s.owner,
        location: '${s.specificLocation} (${s.facultyLocation})',
        status: s.status,
        imageUrl: s.imageUrl,
        isAsset: s.isAsset,
      ));
    }
  }

  /// Dipanggil dari luar (misal setelah student upload barang baru) agar admin
  /// langsung melihat data terbaru.
  void syncFromStudent() {
    _syncItemsFromStudentState();
    notifyListeners();
  }

  void addItem({
    required String name,
    required String category,
    required String owner,
    required String location,
    required String imageUrl,
    String status = 'Tersedia',
  }) {
    final newId = items.isNotEmpty ? (items.map((i) => i.id).reduce((a, b) => a > b ? a : b) + 1) : 1;
    items.insert(
      0,
      AdminItem(
        id: newId,
        name: name,
        category: category,
        owner: owner,
        location: location,
        status: status,
        imageUrl: imageUrl,
      ),
    );
    notifyListeners();
  }

  void toggleItemProblematic(int id) {
    final idx = items.indexWhere((item) => item.id == id);
    if (idx != -1) {
      final newStatus = items[idx].status == 'Bermasalah' ? 'Tersedia' : 'Bermasalah';
      items[idx].status = newStatus;
      // Sync balik ke StudentState
      final sIdx = StudentState.instance.items.indexWhere((s) => s.id == id);
      if (sIdx != -1) {
        StudentState.instance.items[sIdx] = StudentState.instance.items[sIdx].copyWith(status: newStatus);
      }
      notifyListeners();
    }
  }

  void deleteItem(int id) {
    items.removeWhere((item) => item.id == id);
    // Sync balik ke StudentState
    StudentState.instance.items.removeWhere((s) => s.id == id);
    StudentState.instance.notifyAll();
    notifyListeners();
  }

  void editItem(int id, String newName, String newCategory, String newLocation, String newStatus) {
    final idx = items.indexWhere((item) => item.id == id);
    if (idx != -1) {
      items[idx].name = newName;
      items[idx].category = newCategory;
      items[idx].location = newLocation;
      items[idx].status = newStatus;
      // Sync balik ke StudentState
      final sIdx = StudentState.instance.items.indexWhere((s) => s.id == id);
      if (sIdx != -1) {
        final old = StudentState.instance.items[sIdx];
        StudentState.instance.items[sIdx] = StudentItem(
          id: old.id,
          name: newName,
          category: newCategory,
          owner: old.owner,
          ownerRating: old.ownerRating,
          ownerTrustScore: old.ownerTrustScore,
          facultyLocation: old.facultyLocation,
          specificLocation: old.specificLocation,
          status: newStatus,
          description: old.description,
          imageUrl: old.imageUrl,
          isAsset: old.isAsset,
        );
        StudentState.instance.notifyAll();
      }
      notifyListeners();
    }
  }

  // Transaction Actions
  void updateTransactionStatus(String id, String status) {
    final idx = transactions.indexWhere((tx) => tx.id == id);
    if (idx != -1) {
      final tx = transactions[idx];
      tx.status = status;
      // Also sync actual item status
      final itemIdx = items.indexWhere((item) => item.name == tx.itemName);
      if (itemIdx != -1) {
        if (status == 'Dipinjam') {
          items[itemIdx].status = 'Dipinjam';
        } else if (status == 'Dikembalikan' || status == 'Ditolak') {
          items[itemIdx].status = 'Tersedia';
        }
      }

      // Sync dengan Student State
      final studentState = StudentState.instance;

      // 1. Sync student items list
      final sItemIdx = studentState.items.indexWhere((item) => item.name == tx.itemName);
      if (sItemIdx != -1) {
        String studentStatus = 'Tersedia';
        if (status == 'Dipinjam') {
          studentStatus = 'Dipinjam';
        } else if (status == 'Menunggu Persetujuan') {
          studentStatus = 'Menunggu Persetujuan';
        }
        studentState.items[sItemIdx] = studentState.items[sItemIdx].copyWith(status: studentStatus);
      }

      // 2. Sync student rentHistory list
      final sHistIdx = studentState.rentHistory.indexWhere(
          (h) => h['id'] == id || (h['itemName'] == tx.itemName && h['status'] == 'Menunggu Persetujuan'));
      if (sHistIdx != -1) {
        studentState.rentHistory[sHistIdx]['status'] = status;
      }

      // 3. Kirim notifikasi ke Mahasiswa
      String title = '';
      String msg = '';
      if (status == 'Dipinjam') {
        title = 'Peminjaman Disetujui! 🎉';
        msg = 'Pengajuan pinjam "${tx.itemName}" Anda telah disetujui oleh admin.';
      } else if (status == 'Ditolak') {
        title = 'Peminjaman Ditolak ❌';
        msg = 'Maaf, pengajuan pinjam "${tx.itemName}" Anda telah ditolak oleh admin.';
      } else if (status == 'Dikembalikan') {
        title = 'Pengembalian Diterima 📦';
        msg = 'Terima kasih, pengembalian barang "${tx.itemName}" telah dikonfirmasi oleh admin.';
      }

      if (title.isNotEmpty) {
        studentState.addNotification(title, msg);
      }

      notifyListeners();
    }
  }

  // Report Actions
  void updateReportStatus(int id, String status) {
    final idx = reports.indexWhere((rep) => rep.id == id);
    if (idx != -1) {
      reports[idx].status = status;
      notifyListeners();
    }
  }

  /// Kirim peringatan ke terlapor: kurangi trust score -10, ubah status laporan.
  void warnUser(int reportId) {
    final rIdx = reports.indexWhere((r) => r.id == reportId);
    if (rIdx == -1) return;
    reports[rIdx].status = 'Peringatan Dikirim';
    final reportedName = reports[rIdx].reportedUser;

    final uIdx = users.indexWhere((u) => u.name == reportedName);
    if (uIdx != -1) {
      users[uIdx].trustScore = (users[uIdx].trustScore - 10).clamp(0, 100);
      // Juga sync ke student state
      final s = StudentState.instance;
      if (s.currentUser?.name == reportedName) {
        s.currentUser = StudentUser(
          id: s.currentUser!.id,
          name: s.currentUser!.name,
          nim: s.currentUser!.nim,
          email: s.currentUser!.email,
          faculty: s.currentUser!.faculty,
          rating: s.currentUser!.rating,
          trustScore: users[uIdx].trustScore,
          avatarUrl: s.currentUser!.avatarUrl,
        );
      }
    }
    notifyListeners();
  }

  /// Tangguhkan akun terlapor langsung dari halaman laporan.
  void suspendFromReport(int reportId) {
    final rIdx = reports.indexWhere((r) => r.id == reportId);
    if (rIdx == -1) return;
    reports[rIdx].status = 'User Ditangguhkan';
    final reportedName = reports[rIdx].reportedUser;

    final uIdx = users.indexWhere((u) => u.name == reportedName);
    if (uIdx != -1) {
      users[uIdx].status = 'Ditangguhkan';
    }
    notifyListeners();
  }

  /// Cabut penangguhan akun dari halaman laporan dan tandai laporan selesai.
  void liftSuspensionFromReport(int reportId) {
    final rIdx = reports.indexWhere((r) => r.id == reportId);
    if (rIdx == -1) return;
    final reportedName = reports[rIdx].reportedUser;
    reports[rIdx].status = 'Selesai';

    final uIdx = users.indexWhere((u) => u.name == reportedName);
    if (uIdx != -1) {
      users[uIdx].status = 'Aktif';
    }
    notifyListeners();
  }

  /// Tandai laporan selesai tanpa aksi lain.
  void resolveReport(int reportId) {
    final rIdx = reports.indexWhere((r) => r.id == reportId);
    if (rIdx == -1) return;
    reports[rIdx].status = 'Selesai';
    notifyListeners();
  }

  // Settings Actions
  void addCategory(String category) {
    if (category.isNotEmpty && !categories.contains(category)) {
      categories.add(category);
      notifyListeners();
    }
  }

  void deleteCategory(String category) {
    categories.remove(category);
    notifyListeners();
  }

  void addFaculty(String faculty) {
    if (faculty.isNotEmpty && !faculties.contains(faculty)) {
      faculties.add(faculty);
      notifyListeners();
    }
  }

  void deleteFaculty(String faculty) {
    faculties.remove(faculty);
    notifyListeners();
  }

  void toggleBannerActive(int id) {
    final idx = banners.indexWhere((b) => b.id == id);
    if (idx != -1) {
      banners[idx].isActive = !banners[idx].isActive;
      notifyListeners();
    }
  }

  void addBanner(String title, String imageUrl) {
    if (title.isNotEmpty && imageUrl.isNotEmpty) {
      banners.add(AppBanner(id: banners.length + 1, title: title, imageUrl: imageUrl, isActive: true));
      notifyListeners();
    }
  }

  void deleteBanner(int id) {
    banners.removeWhere((b) => b.id == id);
    notifyListeners();
  }

  void addFaq(String question, String answer) {
    if (question.isNotEmpty && answer.isNotEmpty) {
      faqs.add(AppFaq(id: faqs.length + 1, question: question, answer: answer));
      notifyListeners();
    }
  }

  void deleteFaq(int id) {
    faqs.removeWhere((f) => f.id == id);
    notifyListeners();
  }

  void addPolicy(String title, String content) {
    if (title.isNotEmpty && content.isNotEmpty) {
      policies.add(AppPolicy(id: policies.length + 1, title: title, content: content));
      notifyListeners();
    }
  }

  void deletePolicy(int id) {
    policies.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  // General Notification Helpers
  void addNotification(String title, String message, String type) {
    notifications.insert(0, AdminNotification(
      id: notifications.length + 1,
      title: title,
      message: message,
      type: type,
      time: 'Baru saja',
    ));
    notifyListeners();
  }

  void markNotificationsRead() {
    for (var n in notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  // Trigger dynamic simulation events (e.g. for demonstrating real-time updates)
  void simulateNewNotification() {
    final userEvents = [
      {'title': 'Pengguna Baru Terdaftar', 'msg': 'Diana Kusuma (NIM: 22.09.4320) mendaftar.', 'type': 'user'},
      {'title': 'Pengajuan Pinjam Baru', 'msg': 'Aditya Pratama mengajukan pinjam Proyektor Epson.', 'type': 'transaction'},
      {'title': 'Barang Baru Ditambahkan', 'msg': 'Novita Sari mengupload Jas Laboratorium Fisika.', 'type': 'item'},
      {'title': 'Laporan Terlambat Baru', 'msg': 'Rani Wijaya mengadukan keterlambatan pengembalian.', 'type': 'report'},
    ];
    final ev = (userEvents..shuffle()).first;
    addNotification(ev['title']!, ev['msg']!, ev['type']!);
  }
}
