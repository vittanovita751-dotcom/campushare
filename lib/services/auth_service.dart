import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AuthService — menangani semua operasi Firebase Auth
// Dipakai oleh StudentAuthScreen dan AdminLoginScreen
// ─────────────────────────────────────────────────────────────────────────────

class AuthService {
  static final AuthService instance = AuthService._();
  AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Dengarkan perubahan status login secara real-time
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // User yang sedang login sekarang
  User? get currentUser => _auth.currentUser;

  // ── Daftar akun mahasiswa baru ──────────────────────────────────────────
  Future<AuthResult> registerStudent({
    required String name,
    required String nim,
    required String email,
    required String password,
    required String faculty,
  }) async {
    try {
      // 1. Buat akun di Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      // 2. Update display name
      await credential.user!.updateDisplayName(name);

      // 3. Simpan data lengkap ke Firestore koleksi 'users'
      await _db.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'nim': nim,
        'email': email,
        'faculty': faculty,
        'role': 'student',
        'trustScore': 100,
        'avatarUrl': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return AuthResult.success(uid: uid, name: name, role: 'student');
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_mapAuthError(e.code));
    } catch (e) {
      return AuthResult.error('Terjadi kesalahan: $e');
    }
  }

  // ── Login mahasiswa ──────────────────────────────────────────────────────
  Future<AuthResult> loginStudent({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      // Ambil data user dari Firestore
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) {
        return AuthResult.error('Data akun tidak ditemukan. Hubungi admin.');
      }

      final data = doc.data()!;
      if (data['role'] != 'student') {
        await _auth.signOut();
        return AuthResult.error('Akun ini adalah akun admin. Gunakan portal admin.');
      }

      return AuthResult.success(
        uid: uid,
        name: data['name'] ?? email.split('@').first,
        role: 'student',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_mapAuthError(e.code));
    } catch (e) {
      return AuthResult.error('Terjadi kesalahan: $e');
    }
  }

  // ── Login admin ──────────────────────────────────────────────────────────
  Future<AuthResult> loginAdmin({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      // Verifikasi role admin di Firestore
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) {
        await _auth.signOut();
        return AuthResult.error('Akun admin tidak ditemukan di sistem.');
      }

      final data = doc.data()!;
      if (data['role'] != 'admin') {
        await _auth.signOut();
        return AuthResult.error('Akun ini bukan akun admin. Gunakan portal mahasiswa.');
      }

      return AuthResult.success(
        uid: uid,
        name: data['name'] ?? 'Admin',
        role: 'admin',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_mapAuthError(e.code));
    } catch (e) {
      return AuthResult.error('Terjadi kesalahan: $e');
    }
  }

  // ── Logout ───────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ── Ambil data profil user dari Firestore ────────────────────────────────
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      return doc.exists ? doc.data() : null;
    } catch (_) {
      return null;
    }
  }

  // ── Reset password ───────────────────────────────────────────────────────
  Future<AuthResult> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return AuthResult.success(uid: '', name: '', role: '');
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_mapAuthError(e.code));
    }
  }

  // ── Terjemahkan kode error Firebase ke bahasa Indonesia ──────────────────
  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Akun dengan email ini tidak ditemukan.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email atau kata sandi salah.';
      case 'email-already-in-use':
        return 'Email ini sudah terdaftar. Gunakan email lain atau masuk.';
      case 'weak-password':
        return 'Kata sandi terlalu lemah. Minimal 6 karakter.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti.';
      case 'network-request-failed':
        return 'Tidak ada koneksi internet. Periksa jaringanmu.';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan. Hubungi admin.';
      default:
        return 'Terjadi kesalahan ($code). Coba lagi.';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AuthResult — wrapper hasil operasi auth (sukses / error)
// ─────────────────────────────────────────────────────────────────────────────
class AuthResult {
  final bool isSuccess;
  final String? errorMessage;
  final String uid;
  final String name;
  final String role;

  AuthResult._({
    required this.isSuccess,
    required this.uid,
    required this.name,
    required this.role,
    this.errorMessage,
  });

  factory AuthResult.success({
    required String uid,
    required String name,
    required String role,
  }) =>
      AuthResult._(isSuccess: true, uid: uid, name: name, role: role);

  factory AuthResult.error(String message) =>
      AuthResult._(isSuccess: false, uid: '', name: '', role: '', errorMessage: message);
}
