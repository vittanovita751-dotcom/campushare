import 'package:flutter/material.dart';
import 'admin_data.dart';

// User representation on mobile client
class StudentUser {
  final int id;
  final String name;
  final String nim;
  final String email;
  final String faculty;
  final double rating;
  final int trustScore;
  final String avatarUrl;

  StudentUser({
    required this.id,
    required this.name,
    required this.nim,
    required this.email,
    required this.faculty,
    required this.rating,
    required this.trustScore,
    required this.avatarUrl,
  });
}

// Student Notification representation
class StudentNotification {
  final int id;
  final String title;
  final String message;
  final String time;
  bool isRead;

  StudentNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    this.isRead = false,
  });
}


// Item representation on mobile client
class StudentItem {
  final int id;
  final String name;
  final String category;
  final String owner;
  final double ownerRating;
  final int ownerTrustScore;
  final String facultyLocation;
  final String specificLocation;
  final String status; // 'Tersedia', 'Dipinjam', 'Menunggu Persetujuan'
  final String description;
  final String imageUrl;
  final bool isAsset; // true = assets/images/items/, false = network URL

  StudentItem({
    required this.id,
    required this.name,
    required this.category,
    required this.owner,
    required this.ownerRating,
    required this.ownerTrustScore,
    required this.facultyLocation,
    required this.specificLocation,
    required this.status,
    required this.description,
    required this.imageUrl,
    this.isAsset = false,
  });

  StudentItem copyWith({String? status}) {
    return StudentItem(
      id: id,
      name: name,
      category: category,
      owner: owner,
      ownerRating: ownerRating,
      ownerTrustScore: ownerTrustScore,
      facultyLocation: facultyLocation,
      specificLocation: specificLocation,
      status: status ?? this.status,
      description: description,
      imageUrl: imageUrl,
      isAsset: isAsset,
    );
  }
}

// Chat room and messages structures
class ChatMessage {
  final String sender;
  final String text;
  final String time;
  final bool isMe;

  ChatMessage({required this.sender, required this.text, required this.time, required this.isMe});
}

class ChatRoom {
  final int id;
  final String peerName;
  final String peerAvatar;
  final String itemName;
  final List<ChatMessage> messages;

  ChatRoom({
    required this.id,
    required this.peerName,
    required this.peerAvatar,
    required this.itemName,
    required this.messages,
  });
}

// Format DateTime jadi string 'YYYY-MM-DD' (tanpa perlu package intl)
String _formatDateYmd(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.year}-${two(d.month)}-${two(d.day)}';
}

// Ubah teks durasi seperti '3 Hari' / '1 Minggu' jadi jumlah hari
int _parseDurationToDays(String duration) {
  final match = RegExp(r'(\d+)').firstMatch(duration);
  final n = match != null ? int.tryParse(match.group(1)!) ?? 3 : 3;
  if (duration.toLowerCase().contains('minggu')) {
    return n * 7;
  }
  return n;
}

class StudentState extends ChangeNotifier {
  static final StudentState instance = StudentState._internal();
  StudentState._internal() {
    _initMockData();
  }

  /// Publik wrapper agar AdminState bisa memicu rebuild widget student
  /// setelah melakukan perubahan pada items dari sisi admin.
  void notifyAll() => notifyListeners();

  // Active student session user details
  StudentUser? currentUser;
  
  final List<StudentItem> items = [];
  final List<ChatRoom> chats = [];
  final List<Map<String, dynamic>> rentHistory = [];
  final List<StudentNotification> notifications = [];

  void addNotification(String title, String message) {
    notifications.insert(0, StudentNotification(
      id: notifications.length + 1,
      title: title,
      message: message,
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

  void clearAllNotifications() {
    notifications.clear();
    notifyListeners();
  }

  void _initMockData() {
    // Current signed-in Student: Novita Sari
    currentUser = StudentUser(
      id: 1,
      name: 'Novita Sari',
      nim: '21.11.4589',
      email: 'novita.sari@std.ac.id',
      faculty: 'Fakultas Ilmu Komputer (Fasilkom)',
      rating: 4.9,
      trustScore: 98,
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
    );

    // Initial item stock
    items.addAll([
      StudentItem(
        id: 1,
        name: 'Buku Kalkulus Purcell Edisi 9',
        category: 'Buku',
        owner: 'Siti Aminah',
        ownerRating: 4.5,
        ownerTrustScore: 89,
        facultyLocation: 'FMIPA',
        specificLocation: 'Kost Lavender B3',
        status: 'Tersedia',
        description: 'Buku Kalkulus Purcell untuk semester 1-2. Masih bersih dan jarang dicoret-coret. Durasi pinjam maksimal 1 minggu.',
        imageUrl: 'assets/images/items/buku_kalkulus.jpg',
        isAsset: true,
      ),
      StudentItem(
        id: 2,
        name: 'Laptop Asus Core i5 Slim',
        category: 'Laptop',
        owner: 'Budi Raharjo',
        ownerRating: 4.6,
        ownerTrustScore: 92,
        facultyLocation: 'Fakultas Teknik',
        specificLocation: 'Lab Robotik Lt.2',
        status: 'Tersedia',
        description: 'Laptop Asus Core i5 RAM 8GB. Baterai tahan 3 jam. Sangat cocok untuk pengerjaan tugas mendadak. Harap dijaga baik-baik.',
        imageUrl: 'assets/images/items/laptop_asus.jpg',
        isAsset: true,
      ),
      StudentItem(
        id: 3,
        name: 'Proyektor Epson EB-X06',
        category: 'Proyektor',
        owner: 'Aditya Pratama',
        ownerRating: 4.8,
        ownerTrustScore: 95,
        facultyLocation: 'Fasilkom',
        specificLocation: 'Ruang BEM Fasilkom',
        status: 'Dipinjam',
        description: 'Proyektor Epson EB-X06 3600 lumens, resolusi XGA. Lengkap dengan kabel HDMI & remote. Peminjaman khusus untuk kegiatan organisasi.',
        imageUrl: 'assets/images/items/proyektor_epson.jpg',
        isAsset: true,
      ),
      StudentItem(
        id: 4,
        name: 'Kabel HDMI Vention 5 Meter',
        category: 'Kabel HDMI',
        owner: 'Aditya Pratama',
        ownerRating: 4.8,
        ownerTrustScore: 95,
        facultyLocation: 'Fasilkom',
        specificLocation: 'Ruang BEM Fasilkom',
        status: 'Tersedia',
        description: 'Kabel HDMI Vention 5m, support 4K. Kuat dan awet. Tolong kembalikan dalam kondisi tergulung rapi.',
        imageUrl: 'assets/images/items/kabel_hdmi.jpg',
        isAsset: true,
      ),
      StudentItem(
        id: 5,
        name: 'Jas Lab Kimia Ukuran L',
        category: 'Jas Laboratorium',
        owner: 'Siti Aminah',
        ownerRating: 4.5,
        ownerTrustScore: 89,
        facultyLocation: 'FK',
        specificLocation: 'Lab Farmasi Dasar',
        status: 'Tersedia',
        description: 'Jas laboratorium warna putih polos, bahan katun tebal, ukuran L. Sudah dicuci bersih dan wangi.',
        imageUrl: 'assets/images/items/jas_lab.jpg',
        isAsset: true,
      ),
      StudentItem(
        id: 6,
        name: 'Honda Beat FI 2019',
        category: 'Kendaraan',
        owner: 'Rani Wijaya',
        ownerRating: 4.7,
        ownerTrustScore: 94,
        facultyLocation: 'FEB',
        specificLocation: 'Kost Pondok Hijau',
        status: 'Tersedia',
        description: 'Motor Honda Beat FI 2019. Mesin prima, bensin selalu diisi pertamax. Wajib memiliki SIM C aktif untuk peminjaman kendaraan ini.',
        imageUrl: 'assets/images/items/honda_beat.jpg',
        isAsset: true,
      ),
      // ===== ITEM BARU =====
      StudentItem(
        id: 7,
        name: 'Buku Pemrograman Python ML',
        category: 'Buku',
        owner: 'Rafi Ardian',
        ownerRating: 4.7,
        ownerTrustScore: 91,
        facultyLocation: 'Fasilkom',
        specificLocation: 'Sekretariat Himakom Lt.1',
        status: 'Tersedia',
        description: 'Buku Fundamental of Python for Machine Learning – Teguh Wahyono (Edisi Revisi). Cocok untuk mata kuliah AI & Machine Learning. Maks pinjam 5 hari.',
        imageUrl: 'assets/images/items/buku_python.jpg',
        isAsset: true,
      ),
      StudentItem(
        id: 8,
        name: 'Buku Algoritma & Pemrograman',
        category: 'Buku',
        owner: 'Rafi Ardian',
        ownerRating: 4.7,
        ownerTrustScore: 91,
        facultyLocation: 'Fasilkom',
        specificLocation: 'Sekretariat Himakom Lt.1',
        status: 'Tersedia',
        description: 'Buku Latih Algoritma & Pemrograman oleh Kurnia Adi Cahyanto, M.Kom. Berisi latihan soal lengkap untuk pemula hingga menengah. Maks pinjam 5 hari.',
        imageUrl: 'assets/images/items/buku_algoritma.jpg',
        isAsset: true,
      ),
      StudentItem(
        id: 9,
        name: 'ASUS TUF Gaming A15',
        category: 'Laptop',
        owner: 'Rafi Ardian',
        ownerRating: 4.7,
        ownerTrustScore: 91,
        facultyLocation: 'Fasilkom',
        specificLocation: 'Sekretariat Himakom Lt.1',
        status: 'Tersedia',
        description: 'Laptop Gaming ASUS TUF A15, AMD Ryzen 7, RAM 16GB, RTX 3060. Cocok untuk rendering, simulasi, atau keperluan komputasi berat. Maks pinjam 1 hari.',
        imageUrl: 'assets/images/items/asus_tuf.jpg',
        isAsset: true,
      ),

      // ── Proyektor ────────────────────────────────────────────────────────
      StudentItem(
        id: 10,
        name: 'Proyektor BenQ MX550',
        category: 'Proyektor',
        owner: 'Aditya Pratama',
        ownerRating: 4.9,
        ownerTrustScore: 96,
        facultyLocation: 'Fasilkom',
        specificLocation: 'Ruang Seminar Fasilkom Lt.3',
        status: 'Tersedia',
        description: 'Proyektor BenQ MX550, 3600 lumens, XGA 1024×768. Lengkap dengan kabel HDMI & VGA, remote, dan tas bawaan. Cocok untuk presentasi & seminar. Maks pinjam 1 hari.',
        imageUrl: 'https://images.unsplash.com/photo-1478416272538-5f7e51dc5400?w=300',
      ),
      StudentItem(
        id: 11,
        name: 'Tripod Profesional 170cm',
        category: 'Proyektor',
        owner: 'Budi Raharjo',
        ownerRating: 4.6,
        ownerTrustScore: 92,
        facultyLocation: 'Fakultas Teknik',
        specificLocation: 'Lab Multimedia FT Lt.2',
        status: 'Tersedia',
        description: 'Tripod aluminium alloy tinggi 170cm. Cocok untuk kamera DSLR, mirrorless, maupun HP. Head ball bisa putar 360°. Kembalikan dalam kondisi terlipat rapi.',
        imageUrl: 'https://images.unsplash.com/photo-1617137968427-85924c800a22?w=300',
      ),
      StudentItem(
        id: 12,
        name: 'Kamera DSLR Canon EOS 3000D',
        category: 'Proyektor',
        owner: 'Budi Raharjo',
        ownerRating: 4.6,
        ownerTrustScore: 92,
        facultyLocation: 'Fakultas Teknik',
        specificLocation: 'Lab Multimedia FT Lt.2',
        status: 'Tersedia',
        description: 'Kamera DSLR Canon EOS 3000D, lensa kit 18-55mm. Baterai cadangan sudah disertakan. Hati-hati dalam penggunaan, kembalikan dengan lensa terpasang kembali.',
        imageUrl: 'https://images.unsplash.com/photo-1510127034890-ba27508e9f1c?w=300',
      ),
      StudentItem(
        id: 13,
        name: 'Proyektor Mini Portabel XGIMI',
        category: 'Proyektor',
        owner: 'Novita Sari',
        ownerRating: 4.8,
        ownerTrustScore: 97,
        facultyLocation: 'FEB',
        specificLocation: 'Ruang BEM FEB Lt.1',
        status: 'Tersedia',
        description: 'Proyektor mini XGIMI MoGo 2, resolusi Full HD, bisa connect WiFi & Bluetooth. Ringan hanya 900gr, cocok untuk presentasi kelas maupun nonton bareng. Maks pinjam 1 hari.',
        imageUrl: 'https://images.unsplash.com/photo-1478416272538-5f7e51dc5400?w=300',
      ),

      // ── Kendaraan tambahan ────────────────────────────────────────────────
      StudentItem(
        id: 14,
        name: 'Yamaha Mio M3 2020',
        category: 'Kendaraan',
        owner: 'Aditya Pratama',
        ownerRating: 4.8,
        ownerTrustScore: 95,
        facultyLocation: 'Fasilkom',
        specificLocation: 'Parkir Fasilkom Blok B',
        status: 'Tersedia',
        description: 'Motor Yamaha Mio M3 2020. Irit bensin, cocok untuk perjalanan dalam kota. SIM C wajib aktif. Kembalikan dengan bensin minimal setengah tangki.',
        imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=300',
      ),

      // ── Jas Lab tambahan ─────────────────────────────────────────────────
      StudentItem(
        id: 15,
        name: 'Jas Lab Fisika Ukuran M',
        category: 'Jas Laboratorium',
        owner: 'Novita Sari',
        ownerRating: 4.8,
        ownerTrustScore: 97,
        facultyLocation: 'FMIPA',
        specificLocation: 'Lab Fisika Dasar FMIPA',
        status: 'Tersedia',
        description: 'Jas laboratorium putih ukuran M, kondisi bersih dan sudah dicuci. Cocok untuk praktikum Fisika Dasar. Harap kembalikan setelah dicuci.',
        imageUrl: 'https://images.unsplash.com/photo-1564325724739-bae0bd08762c?w=300',
      ),

      // ── Kabel HDMI tambahan ───────────────────────────────────────────────
      StudentItem(
        id: 16,
        name: 'Power Bank Xiaomi 20000mAh',
        category: 'Kabel HDMI',
        owner: 'Novita Sari',
        ownerRating: 4.8,
        ownerTrustScore: 97,
        facultyLocation: 'Fasilkom',
        specificLocation: 'Fasilkom Lab A',
        status: 'Tersedia',
        description: 'Power Bank Xiaomi 20000mAh fast charging 33W. Ada 2 port USB-A + 1 USB-C. Sangat berguna saat baterai laptop/HP habis di kampus. Kembalikan sudah terisi penuh.',
        imageUrl: 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=300',
      ),
    ]);

    // Initial chats
    chats.addAll([
      ChatRoom(
        id: 1,
        peerName: 'Siti Aminah',
        peerAvatar: 'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=100',
        itemName: 'Buku Kalkulus Purcell Edisi 9',
        messages: [
          ChatMessage(sender: 'Siti Aminah', text: 'Halo Novita, bukunya ready silakan ambil di Kost Lavender.', time: '09:00', isMe: false),
          ChatMessage(sender: 'Novita Sari', text: 'Baik Siti, siang nanti saya ke sana ya setelah kelas Kalkulus.', time: '09:15', isMe: true),
        ],
      ),
      ChatRoom(
        id: 2,
        peerName: 'Budi Raharjo',
        peerAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
        itemName: 'Laptop Asus Core i5 Slim',
        messages: [
          ChatMessage(sender: currentUser!.name, text: 'Halo Budi, apakah laptopnya masih bisa dipinjam hari ini?', time: 'Kemarin', isMe: true),
          ChatMessage(sender: 'Budi Raharjo', text: 'Masih ready ${currentUser!.name.split(' ').first}, silakan ketemuan di Kantin Teknik.', time: 'Kemarin', isMe: false),
        ],
      ),
    ]);

    // Initial rental history
    rentHistory.addAll([
      {
        'id': 'TR-0091',
        'itemName': 'Proyektor Epson EB-X06',
        'owner': 'Aditya Pratama',
        'date': '15 Jun 2026',
        'status': 'Selesai',
        'role': 'Peminjam',
      },
      {
        'id': 'TR-0092',
        'itemName': 'Kabel HDMI Vention 5 Meter',
        'owner': 'Aditya Pratama',
        'date': '18 Jun 2026',
        'status': 'Selesai',
        'role': 'Peminjam',
      },
    ]);
  }

  // Get avatar URL for known peer names
  String _getPeerAvatar(String peerName) {
    switch (peerName) {
      case 'Siti Aminah':
        return 'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=100';
      case 'Budi Raharjo':
        return 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100';
      case 'Aditya Pratama':
        return 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100';
      case 'Rani Wijaya':
        return 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100';
      default:
        return 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100';
    }
  }
  void loginStudent(String name, String nim, String email, String faculty) {
    // Gunakan NIM dari parameter; jika kosong (login tanpa input NIM), pakai nim dummy agar tetap tampil
    final resolvedNim = nim.isNotEmpty ? nim : '-';
    currentUser = StudentUser(
      id: stateUsersCount + 1,
      name: name,
      nim: resolvedNim,
      email: email,
      faculty: faculty,
      rating: 5.0,
      trustScore: 100,
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
    );
    notifyListeners();
  }

  int get stateUsersCount => 5;

  // Add new item to share library
  void uploadItem(String name, String category, String loc, String desc) {
    int newId = items.length + 1;
    final ownerName = currentUser?.name ?? 'Novita Sari';
    final imageUrl = _getCategoryDefaultImage(category);
    items.add(StudentItem(
      id: newId,
      name: name,
      category: category,
      owner: ownerName,
      ownerRating: currentUser?.rating ?? 4.9,
      ownerTrustScore: currentUser?.trustScore ?? 98,
      facultyLocation: currentUser?.faculty.split(' ').last.replaceAll('(', '').replaceAll(')', '') ?? 'Fasilkom',
      specificLocation: loc,
      status: 'Tersedia',
      description: desc,
      imageUrl: imageUrl,
      isAsset: true,
    ));

    // Hubungkan ke Admin State supaya barang baru langsung muncul
    // di Manajemen Inventaris admin secara realtime.
    AdminState.instance.addItem(
      name: name,
      category: category,
      owner: ownerName,
      location: loc,
      imageUrl: imageUrl,
    );
    AdminState.instance.addNotification(
      'Barang Baru Ditambahkan',
      '$ownerName menambahkan $name ke kategori $category.',
      'item',
    );

    notifyListeners();
    AdminState.instance.notifyListeners();
  }

  String _getCategoryDefaultImage(String category) {
    switch (category) {
      case 'Buku':
        return 'assets/images/items/buku_kalkulus.jpg';
      case 'Laptop':
        return 'assets/images/items/laptop_asus.jpg';
      case 'Proyektor':
        return 'assets/images/items/proyektor_epson.jpg';
      case 'Kendaraan':
        return 'assets/images/items/honda_beat.jpg';
      case 'Jas Laboratorium':
        return 'assets/images/items/jas_lab.jpg';
      case 'Kabel HDMI':
        return 'assets/images/items/kabel_hdmi.jpg';
      default:
        return 'assets/images/items/kabel_hdmi.jpg';
    }
  }

  // Request loan borrow of item
  void borrowItem(int itemId, String duration, String reason) {
    final idx = items.indexWhere((item) => item.id == itemId);
    if (idx != -1) {
      final item = items[idx];
      items[idx] = item.copyWith(status: 'Menunggu Persetujuan');
      
      final String txId = 'TX-${10047 + rentHistory.length}';

      // Add to notifications / history
      rentHistory.insert(0, {
        'id': txId,
        'itemName': item.name,
        'owner': item.owner,
        'date': 'Hari ini',
        'status': 'Menunggu Persetujuan',
        'role': 'Peminjam',
      });

      // Insert mock chat room automatically to arrange collection
      int chatRoomId = chats.length + 1;
      chats.add(ChatRoom(
        id: chatRoomId,
        peerName: item.owner,
        peerAvatar: _getPeerAvatar(item.owner),
        itemName: item.name,
        messages: [
          ChatMessage(sender: currentUser?.name ?? 'Novita Sari', text: 'Halo ${item.owner}, saya mengajukan peminjaman ${item.name} selama $duration dengan alasan: $reason.', time: 'Baru saja', isMe: true),
        ],
      ));

      // Hubungkan ke Admin State!
      final now = DateTime.now();
      final returnDt = now.add(Duration(days: _parseDurationToDays(duration)));
      AdminState.instance.transactions.insert(
        0,
        AdminTransaction(
          id: txId,
          itemName: item.name,
          borrower: currentUser?.name ?? 'Novita Sari',
          owner: item.owner,
          borrowDate: _formatDateYmd(now),
          returnDate: _formatDateYmd(returnDt),
          status: 'Menunggu Persetujuan',
        ),
      );

      // Tambahkan notifikasi ke Admin
      AdminState.instance.addNotification(
        'Pengajuan Pinjam Baru',
        '${currentUser?.name ?? "Novita Sari"} mengajukan peminjaman ${item.name}.',
        'transaction',
      );

      // Update status barang di Admin State jadi 'Dipinjam' segera saat
      // pengajuan dibuat, supaya stok ketersediaan di "Kategori Terpopuler"
      // langsung berkurang secara realtime (tidak menunggu admin approve).
      // Kalau nanti admin menolak pengajuan ini, statusnya otomatis
      // dikembalikan ke 'Tersedia' oleh updateTransactionStatus().
      final adminItemIdx = AdminState.instance.items.indexWhere((i) => i.name == item.name);
      if (adminItemIdx != -1) {
        AdminState.instance.items[adminItemIdx].status = 'Dipinjam';
      }

      notifyListeners();
      // Pastikan dashboard admin (statistik, daftar transaksi, grafik tren,
      // dan ketersediaan stok kategori) langsung ter-refresh saat ada
      // peminjaman baru.
      AdminState.instance.notifyListeners();
    }
  }

  // Send message in chat room
  void sendMessage(int chatRoomId, String text) {
    final idx = chats.indexWhere((c) => c.id == chatRoomId);
    if (idx != -1) {
      chats[idx].messages.add(ChatMessage(
        sender: currentUser?.name ?? 'Novita Sari',
        text: text,
        time: 'Baru saja',
        isMe: true,
      ));
      
      // Simulate answer from lender after a few seconds
      final peer = chats[idx].peerName;
      final myFirstName = currentUser?.name.split(' ').first ?? 'Kak';
      Future.delayed(const Duration(seconds: 2), () {
        final chatIdx = chats.indexWhere((c) => c.id == chatRoomId);
        if (chatIdx != -1) {
          chats[chatIdx].messages.add(ChatMessage(
            sender: peer,
            text: 'Baik $myFirstName, silakan kabari saya kalau sudah mau ke lokasi.',
            time: 'Baru saja',
            isMe: false,
          ));
          notifyListeners();
        }
      });

      notifyListeners();
    }
  }

  // Return a borrowed item and sync with Admin State
  void returnItem(String transactionId) {
    final idx = rentHistory.indexWhere((h) => h['id'] == transactionId);
    if (idx != -1) {
      final txData = rentHistory[idx];
      rentHistory[idx]['status'] = 'Selesai';
      
      // Update item status in student items list
      final itemIdx = items.indexWhere((item) => item.name == txData['itemName']);
      if (itemIdx != -1) {
        items[itemIdx] = items[itemIdx].copyWith(status: 'Tersedia');
      }

      // Sync dengan Admin State!
      final adminTxIdx = AdminState.instance.transactions.indexWhere((tx) => tx.id == transactionId);
      if (adminTxIdx != -1) {
        AdminState.instance.transactions[adminTxIdx].status = 'Selesai';
        
        // Update status barang di Admin list
        final adminItemIdx = AdminState.instance.items.indexWhere((item) => item.name == txData['itemName']);
        if (adminItemIdx != -1) {
          AdminState.instance.items[adminItemIdx].status = 'Tersedia';
        }

        // Tambahkan notifikasi di Admin dashboard
        AdminState.instance.addNotification(
          'Transaksi Selesai',
          '${currentUser?.name ?? "Novita Sari"} telah mengembalikan "${txData['itemName']}". Transaksi dinyatakan selesai.',
          'transaction',
        );
      }

      // Tambahkan notifikasi di sisi Mahasiswa
      addNotification(
        'Transaksi Selesai 🎉',
        'Anda telah mengembalikan "${txData['itemName']}". Transaksi ini kini berstatus Selesai.',
      );

      notifyListeners();
      AdminState.instance.notifyListeners();
    }
  }
}
