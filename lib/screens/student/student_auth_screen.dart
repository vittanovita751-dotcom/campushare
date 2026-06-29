import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../student_data.dart';
import '../../admin_data.dart';
import 'student_shell.dart';

class StudentAuthScreen extends StatefulWidget {
  const StudentAuthScreen({super.key});

  @override
  State<StudentAuthScreen> createState() => _StudentAuthScreenState();
}

class _StudentAuthScreenState extends State<StudentAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoginMode = true;
  bool _isPasswordVisible = false;
  bool _isLoading = false; // ← state loading untuk Firebase

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nimController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedFaculty = 'Fasilkom';

  final List<String> _faculties = [
    'Fasilkom', 'FT', 'FEB', 'FK', 'FMIPA', 'FH', 'FIB'
  ];

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _formKey.currentState?.reset();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    AuthResult result;

    if (_isLoginMode) {
      // ── Login via Firebase Auth ─────────────────────────────────────────
      result = await AuthService.instance.loginStudent(
        email: email,
        password: password,
      );
    } else {
      // ── Register via Firebase Auth ──────────────────────────────────────
      result = await AuthService.instance.registerStudent(
        name: _nameController.text.trim(),
        nim: _nimController.text.trim(),
        email: email,
        password: password,
        faculty: _selectedFaculty,
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      // Sinkronisasi ke state lokal (StudentState & AdminState) agar
      // data tetap muncul di UI yang sudah ada
      final name = result.name;
      final nim = _isLoginMode ? '' : _nimController.text.trim();
      final faculty = _selectedFaculty;

      StudentState.instance.loginStudent(name, nim, email, faculty);
      AdminState.instance.registerOrAddUser(
        name: name,
        nim: nim,
        email: email,
        faculty: faculty,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StudentShell()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isLoginMode
                  ? '✅ Selamat datang kembali, $name!'
                  : '🎉 Registrasi berhasil! Selamat datang $name!',
            ),
            backgroundColor: const Color(0xFF64B5F6),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } else {
      // Tampilkan pesan error dari Firebase (sudah diterjemahkan ke Bahasa Indonesia)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(child: Text(result.errorMessage ?? 'Terjadi kesalahan')),
              ],
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nimController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 4,
                shadowColor: Colors.blue.withValues(alpha: 0.15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF64B5F6).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.share_location_rounded,
                            size: 40,
                            color: Color(0xFF1E88E5),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isLoginMode
                              ? 'Masuk ke CampuShare'
                              : 'Buat Akun CampuShare',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D47A1),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isLoginMode
                              ? 'Mulai berbagi dan meminjam barang kampus'
                              : 'Lengkapi formulir pendaftaran di bawah ini',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 32),

                        // ── Field khusus Register ─────────────────────────
                        if (!_isLoginMode) ...[
                          TextFormField(
                            controller: _nameController,
                            decoration: _inputDecoration(
                                'Nama Lengkap', Icons.person_outline_rounded),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Nama wajib diisi'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nimController,
                            decoration: _inputDecoration(
                                'NIM (Nomor Induk Mahasiswa)',
                                Icons.badge_outlined),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'NIM wajib diisi'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedFaculty,
                            decoration: _inputDecoration(
                                'Fakultas', Icons.school_outlined),
                            items: _faculties
                                .map((f) => DropdownMenuItem(
                                    value: f, child: Text(f)))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedFaculty = v!),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // ── Email ─────────────────────────────────────────
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration:
                              _inputDecoration('Email', Icons.email_outlined),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Email wajib diisi';
                            }
                            if (!v.contains('@')) {
                              return 'Format email tidak valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // ── Password ──────────────────────────────────────
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: _inputDecoration(
                            'Kata Sandi',
                            Icons.lock_outline_rounded,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () => setState(
                                  () => _isPasswordVisible = !_isPasswordVisible),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Kata sandi wajib diisi';
                            }
                            if (v.length < 6) {
                              return 'Kata sandi minimal 6 karakter';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 28),

                        // ── Tombol Submit ─────────────────────────────────
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E88E5),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  const Color(0xFF90CAF9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    _isLoginMode
                                        ? 'Masuk Sekarang'
                                        : 'Daftar Akun',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        TextButton(
                          onPressed: _isLoading ? null : _toggleMode,
                          child: Text(
                            _isLoginMode
                                ? 'Belum punya akun? Daftar di sini'
                                : 'Sudah punya akun? Masuk di sini',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E88E5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon,
      {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF64B5F6), size: 20),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Color(0xFF64B5F6), width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
    );
  }
}
