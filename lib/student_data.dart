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

class StudentState extends ChangeNotifier {
  static final StudentState instance = StudentState._internal();
  StudentState._internal() {
    _initMockData();
  }

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
        imageUrl: 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=300',
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
        imageUrl: 'https://images.unsplash.com/photo-1496181130204-755241524eab?w=300',
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
        imageUrl: 'https://images.unsplash.com/photo-1535016120720-40c646be5580?w=300',
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
        imageUrl: 'https://images.unsplash.com/photo-1557672172-298e090bd0f1?w=300',
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
        imageUrl: 'https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?w=300',
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
        imageUrl: 'https://images.unsplash.com/photo-1558981806-ec527fa84c39?w=300',
      ),
    ]);

    // Initial chats
    chats.addAll([
      ChatRoom(
        id: 1,
        peerName: 'Siti Aminah',
        peerAvatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100',
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
          ChatMessage(sender: 'Novita Sari', text: 'Halo Budi, apakah laptopnya masih bisa dipinjam hari ini?', time: 'Kemarin', isMe: true),
          ChatMessage(sender: 'Budi Raharjo', text: 'Masih ready Nov, silakan ketemuan di Kantin Teknik.', time: 'Kemarin', isMe: false),
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

  // Log in student session user
  void loginStudent(String name, String nim, String email, String faculty) {
    currentUser = StudentUser(
      id: stateUsersCount + 1,
      name: name,
      nim: nim,
      email: email,
      faculty: faculty,
      rating: 5.0,
      trustScore: 100,
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
    );
    notifyListeners();
  }

  int get stateUsersCount => 5;

  // Add new item to share library
  void uploadItem(String name, String category, String loc, String desc) {
    int newId = items.length + 1;
    items.add(StudentItem(
      id: newId,
      name: name,
      category: category,
      owner: currentUser?.name ?? 'Novita Sari',
      ownerRating: currentUser?.rating ?? 4.9,
      ownerTrustScore: currentUser?.trustScore ?? 98,
      facultyLocation: currentUser?.faculty.split(' ').last.replaceAll('(', '').replaceAll(')', '') ?? 'Fasilkom',
      specificLocation: loc,
      status: 'Tersedia',
      description: desc,
      imageUrl: _getCategoryDefaultImage(category),
    ));
    notifyListeners();
  }

  String _getCategoryDefaultImage(String category) {
    switch (category) {
      case 'Buku':
        return 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=300';
      case 'Laptop':
        return 'https://images.unsplash.com/photo-1496181130204-755241524eab?w=300';
      case 'Proyektor':
        return 'https://images.unsplash.com/photo-1535016120720-40c646be5580?w=300';
      case 'Kendaraan':
        return 'https://images.unsplash.com/photo-1558981806-ec527fa84c39?w=300';
      case 'Jas Laboratorium':
        return 'https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?w=300';
      default:
        return 'https://images.unsplash.com/photo-1557672172-298e090bd0f1?w=300';
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
        peerAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
        itemName: item.name,
        messages: [
          ChatMessage(sender: currentUser?.name ?? 'Novita Sari', text: 'Halo ${item.owner}, saya mengajukan peminjaman ${item.name} selama $duration dengan alasan: $reason.', time: 'Baru saja', isMe: true),
        ],
      ));

      // Hubungkan ke Admin State!
      AdminState.instance.transactions.insert(
        0,
        AdminTransaction(
          id: txId,
          itemName: item.name,
          borrower: currentUser?.name ?? 'Novita Sari',
          owner: item.owner,
          borrowDate: '2026-06-21',
          returnDate: '2026-06-24', // mock 3 days return
          status: 'Menunggu Persetujuan',
        ),
      );

      // Tambahkan notifikasi ke Admin
      AdminState.instance.addNotification(
        'Pengajuan Pinjam Baru',
        '${currentUser?.name ?? "Novita Sari"} mengajukan peminjaman ${item.name}.',
        'transaction',
      );

      notifyListeners();
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
      Future.delayed(const Duration(seconds: 2), () {
        final chatIdx = chats.indexWhere((c) => c.id == chatRoomId);
        if (chatIdx != -1) {
          chats[chatIdx].messages.add(ChatMessage(
            sender: peer,
            text: 'Baik, silakan kabari saya kalau sudah mau ke lokasi.',
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
      rentHistory[idx]['status'] = 'Dikembalikan';
      
      // Update item status in student items list
      final itemIdx = items.indexWhere((item) => item.name == txData['itemName']);
      if (itemIdx != -1) {
        items[itemIdx] = items[itemIdx].copyWith(status: 'Tersedia');
      }

      // Sync dengan Admin State!
      final adminTxIdx = AdminState.instance.transactions.indexWhere((tx) => tx.id == transactionId);
      if (adminTxIdx != -1) {
        AdminState.instance.transactions[adminTxIdx].status = 'Dikembalikan';
        
        // Update status barang di Admin list
        final adminItemIdx = AdminState.instance.items.indexWhere((item) => item.name == txData['itemName']);
        if (adminItemIdx != -1) {
          AdminState.instance.items[adminItemIdx].status = 'Tersedia';
        }

        // Tambahkan notifikasi di Admin dashboard
        AdminState.instance.addNotification(
          'Barang Dikembalikan',
          '${currentUser?.name ?? "Novita Sari"} telah mengembalikan "${txData['itemName']}".',
          'transaction',
        );
      }

      // Tambahkan notifikasi di sisi Mahasiswa
      addNotification(
        'Barang Dikembalikan 📦',
        'Anda telah mengembalikan "${txData['itemName']}". Menunggu verifikasi akhir dari admin.',
      );

      notifyListeners();
      AdminState.instance.notifyListeners();
    }
  }
}
