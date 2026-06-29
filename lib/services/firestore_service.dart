import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FirestoreService — semua operasi baca/tulis ke Firestore
// Koleksi: users, items, transactions
// ─────────────────────────────────────────────────────────────────────────────

class FirestoreService {
  static final FirestoreService instance = FirestoreService._();
  FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ════════════════════════════════════════════════════════════════════════════
  // ITEMS
  // ════════════════════════════════════════════════════════════════════════════

  // Stream daftar semua barang yang tersedia (real-time)
  Stream<List<Map<String, dynamic>>> streamAvailableItems() {
    return _db
        .collection('items')
        .where('status', isEqualTo: 'Tersedia')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  // Stream semua barang (untuk admin)
  Stream<List<Map<String, dynamic>>> streamAllItems() {
    return _db
        .collection('items')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  // Tambah barang baru
  Future<bool> addItem({
    required String ownerUid,
    required String ownerName,
    required String name,
    required String category,
    required String description,
    required String location,
    required String imageUrl,
  }) async {
    try {
      await _db.collection('items').add({
        'ownerUid': ownerUid,
        'ownerName': ownerName,
        'name': name,
        'category': category,
        'description': description,
        'location': location,
        'imageUrl': imageUrl,
        'status': 'Tersedia',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  // Update status barang
  Future<void> updateItemStatus(String itemId, String status) async {
    await _db.collection('items').doc(itemId).update({'status': status});
  }

  // ════════════════════════════════════════════════════════════════════════════
  // TRANSACTIONS (PEMINJAMAN)
  // ════════════════════════════════════════════════════════════════════════════

  // Stream semua transaksi (admin)
  Stream<List<Map<String, dynamic>>> streamAllTransactions() {
    return _db
        .collection('transactions')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  // Stream transaksi milik user tertentu (mahasiswa — sebagai peminjam)
  Stream<List<Map<String, dynamic>>> streamMyTransactions(String userUid) {
    return _db
        .collection('transactions')
        .where('borrowerUid', isEqualTo: userUid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  // Buat permintaan peminjaman baru
  Future<bool> createBorrowRequest({
    required String borrowerUid,
    required String borrowerName,
    required String itemId,
    required String itemName,
    required String ownerUid,
    required String ownerName,
    required String returnDate,
  }) async {
    try {
      // Cek barang masih tersedia
      final itemDoc = await _db.collection('items').doc(itemId).get();
      if (!itemDoc.exists || itemDoc.data()?['status'] != 'Tersedia') {
        return false;
      }

      // Buat transaksi
      await _db.collection('transactions').add({
        'borrowerUid': borrowerUid,
        'borrowerName': borrowerName,
        'itemId': itemId,
        'itemName': itemName,
        'ownerUid': ownerUid,
        'ownerName': ownerName,
        'returnDate': returnDate,
        'status': 'Menunggu Persetujuan',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update status barang jadi 'Menunggu'
      await updateItemStatus(itemId, 'Menunggu Persetujuan');
      return true;
    } catch (_) {
      return false;
    }
  }

  // Admin: setujui / tolak / konfirmasi kembali transaksi
  Future<void> updateTransactionStatus(
    String transactionId,
    String newStatus, {
    String? itemId,
  }) async {
    await _db.collection('transactions').doc(transactionId).update({
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Update status barang terkait
    if (itemId != null) {
      String itemStatus;
      switch (newStatus) {
        case 'Dipinjam':
          itemStatus = 'Dipinjam';
          break;
        case 'Dikembalikan':
          itemStatus = 'Tersedia';
          break;
        case 'Ditolak':
          itemStatus = 'Tersedia';
          break;
        default:
          itemStatus = 'Tersedia';
      }
      await updateItemStatus(itemId, itemStatus);
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // USERS
  // ════════════════════════════════════════════════════════════════════════════

  // Stream semua user (admin)
  Stream<List<Map<String, dynamic>>> streamAllUsers() {
    return _db
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  // Ambil profil user sekali (one-time read)
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      return doc.exists ? {'id': doc.id, ...doc.data()!} : null;
    } catch (_) {
      return null;
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SEED DATA — panggil sekali untuk mengisi Firestore dengan data awal
  // Jalankan hanya saat database kosong!
  // ════════════════════════════════════════════════════════════════════════════

  Future<void> seedInitialData(String adminUid) async {
    // Cek apakah data sudah ada
    final existingItems = await _db.collection('items').limit(1).get();
    if (existingItems.docs.isNotEmpty) return; // Sudah ada data, skip

    final batch = _db.batch();

    // ── Seed Items ────────────────────────────────────────────────────────
    final itemsData = [
      {
        'ownerUid': adminUid,
        'ownerName': 'Admin CampuShare',
        'name': 'Proyektor Epson EB-X06',
        'category': 'Proyektor',
        'description': 'Proyektor 3600 lumens, resolusi XGA. Lengkap dengan kabel HDMI & remote.',
        'location': 'Fasilkom Lab A',
        'imageUrl': 'https://images.unsplash.com/photo-1478416272538-5f7e51dc5400?w=300',
        'status': 'Tersedia',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'ownerUid': adminUid,
        'ownerName': 'Admin CampuShare',
        'name': 'Laptop Dell Inspiron 15',
        'category': 'Laptop',
        'description': 'Laptop Dell Core i5, RAM 8GB. Cocok untuk tugas mendadak.',
        'location': 'Lab Komputer FT',
        'imageUrl': 'https://images.unsplash.com/photo-1593642632559-0c6d3fc62b89?w=300',
        'status': 'Tersedia',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'ownerUid': adminUid,
        'ownerName': 'Admin CampuShare',
        'name': 'Kabel HDMI Vention 5 Meter',
        'category': 'Kabel HDMI',
        'description': 'Kabel HDMI Vention 5m, support 4K. Kembalikan dalam kondisi rapi.',
        'location': 'Ruang BEM Fasilkom',
        'imageUrl': 'https://images.unsplash.com/photo-1598622389527-edb57b04d63c?w=300',
        'status': 'Tersedia',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'ownerUid': adminUid,
        'ownerName': 'Admin CampuShare',
        'name': 'Jas Laboratorium Kimia Ukuran L',
        'category': 'Jas Laboratorium',
        'description': 'Jas lab putih, bahan katun tebal ukuran L. Sudah dicuci.',
        'location': 'Lab Kimia Dasar',
        'imageUrl': 'https://images.unsplash.com/photo-1564325724739-bae0bd08762c?w=300',
        'status': 'Tersedia',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'ownerUid': adminUid,
        'ownerName': 'Admin CampuShare',
        'name': 'Tripod Kamera Universal',
        'category': 'Kamera',
        'description': 'Tripod aluminium 150cm, cocok untuk kamera DSLR maupun HP.',
        'location': 'Ruang BEM Fasilkom',
        'imageUrl': 'https://images.unsplash.com/photo-1617137968427-85924c800a22?w=300',
        'status': 'Tersedia',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'ownerUid': adminUid,
        'ownerName': 'Admin CampuShare',
        'name': 'Headset Sony WH-1000XM4',
        'category': 'Elektronik',
        'description': 'Headset noise-cancelling Sony. Baterai 30 jam. Cocok untuk belajar.',
        'location': 'Perpustakaan Pusat',
        'imageUrl': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=300',
        'status': 'Tersedia',
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (final item in itemsData) {
      final ref = _db.collection('items').doc();
      batch.set(ref, item);
    }

    await batch.commit();
  }
}
