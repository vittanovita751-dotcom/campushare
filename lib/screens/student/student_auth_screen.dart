import 'package:flutter/material.dart';
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

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nimController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedFaculty = 'Fasilkom';

  final List<String> _faculties = ['Fasilkom', 'FT', 'FEB', 'FK', 'FMIPA', 'FH', 'FIB'];

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _formKey.currentState?.reset();
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // Login logic using state manager
    final state = StudentState.instance;
    final name = _isLoginMode ? _emailController.text.split('@').first : _nameController.text.trim();
    final nim = _isLoginMode ? '21.11.4589' : _nimController.text.trim();
    final email = _emailController.text.trim();
    final faculty = _selectedFaculty;
    
    state.loginStudent(
      name,
      nim,
      email,
      faculty,
    );

    // Hubungkan ke Admin State! Tambahkan user ke dashboard admin jika belum terdaftar.
    AdminState.instance.registerOrAddUser(
      name: name,
      nim: nim,
      email: email,
      faculty: faculty,
    );

    // Navigate to student main shell
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const StudentShell()),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isLoginMode ? 'Selamat datang kembali, $name!' : 'Registrasi Berhasil! Selamat datang $name!'),
        backgroundColor: const Color(0xFF64B5F6),
      ),
    );
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
            colors: [
              Color(0xFFE3F2FD),
              Color(0xFFBBDEFB),
            ],
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
                shadowColor: Colors.blue.withOpacity(0.15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon Branding
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF64B5F6).withOpacity(0.15),
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
                          _isLoginMode ? 'Masuk ke CampuShare' : 'Buat Akun CampuShare',
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
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 32),

                        // Name field (Register only)
                        if (!_isLoginMode) ...[
                          TextFormField(
                            controller: _nameController,
                            decoration: _buildInputDecoration(
                              label: 'Nama Lengkap',
                              icon: Icons.person_outline_rounded,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) return 'Nama wajib diisi';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nimController,
                            decoration: _buildInputDecoration(
                              label: 'Nomor Induk Mahasiswa (NIM)',
                              icon: Icons.badge_outlined,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) return 'NIM wajib diisi';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedFaculty,
                            decoration: _buildInputDecoration(
                              label: 'Fakultas',
                              icon: Icons.school_outlined,
                            ),
                            items: _faculties
                                .map((fac) => DropdownMenuItem(value: fac, child: Text(fac)))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedFaculty = val;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Email field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _buildInputDecoration(
                            label: 'Email Kampus (@std.ac.id)',
                            icon: Icons.email_outlined,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'Email wajib diisi';
                            if (!value.contains('@')) return 'Format email tidak valid';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: _buildInputDecoration(
                            label: 'Kata Sandi',
                            icon: Icons.lock_outline_rounded,
                            suffixIcon: IconButton(
                              icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Kata sandi wajib diisi';
                            if (value.length < 5) return 'Kata sandi minimal 5 karakter';
                            return null;
                          },
                        ),
                        const SizedBox(height: 28),

                        // Submit Button with WidgetStateProperty configuration
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _submit,
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                                if (states.contains(WidgetState.pressed)) {
                                  return const Color(0xFF1E88E5);
                                }
                                return const Color(0xFF64B5F6); // primary color
                              }),
                              foregroundColor: const WidgetStatePropertyAll<Color>(Colors.white),
                              shape: WidgetStatePropertyAll<OutlinedBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                              elevation: WidgetStateProperty.resolveWith<double>((states) {
                                if (states.contains(WidgetState.hovered) || states.contains(WidgetState.pressed)) {
                                  return 4.0;
                                }
                                return 1.0;
                              }),
                            ),
                            child: Text(
                              _isLoginMode ? 'Masuk Sekarang' : 'Daftar Akun',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Swap Toggle Link
                        TextButton(
                          onPressed: _toggleMode,
                          style: const ButtonStyle(
                            foregroundColor: WidgetStatePropertyAll<Color>(Color(0xFF1E88E5)),
                          ),
                          child: Text(
                            _isLoginMode
                                ? 'Belum punya akun? Daftar di sini'
                                : 'Sudah memiliki akun? Masuk di sini',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
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

  InputDecoration _buildInputDecoration({required String label, required IconData icon, Widget? suffixIcon}) {
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
      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
    );
  }
}
