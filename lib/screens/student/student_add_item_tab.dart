import 'package:flutter/material.dart';
import '../../student_data.dart';

class StudentAddItemTab extends StatefulWidget {
  const StudentAddItemTab({super.key});

  @override
  State<StudentAddItemTab> createState() => _StudentAddItemTabState();
}

class _StudentAddItemTabState extends State<StudentAddItemTab> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _locationCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();
  String _selectedCategory = 'Buku';

  final List<String> _categories = ['Buku', 'Laptop', 'Proyektor', 'Kabel HDMI', 'Jas Laboratorium', 'Kendaraan'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // Call state manager to add item
    StudentState.instance.uploadItem(
      _nameCtrl.text.trim(),
      _selectedCategory,
      _locationCtrl.text.trim(),
      _descriptionCtrl.text.trim(),
    );

    // Reset fields
    setState(() {
      _nameCtrl.clear();
      _locationCtrl.clear();
      _descriptionCtrl.clear();
      _selectedCategory = 'Buku';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Barang berhasil dibagikan ke inventaris kampus!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: const Text('Bagikan Barang Baru', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.04),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Barang',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bantu teman kampus dengan meminjamkan barang yang tidak sedang kamu pakai.',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),

                  // Name Field
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: _buildInputDecoration('Nama Barang', Icons.shopping_bag_outlined),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Nama barang tidak boleh kosong';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Category Selector
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: _buildInputDecoration('Kategori', Icons.category_outlined),
                    items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedCategory = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Location Field
                  TextFormField(
                    controller: _locationCtrl,
                    decoration: _buildInputDecoration('Lokasi Ambil (contoh: Kost Pondok Hijau / Lab A)', Icons.location_on_outlined),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Lokasi tidak boleh kosong';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Description Field
                  TextFormField(
                    controller: _descriptionCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Deskripsi Kondisi & Ketentuan Pinjam',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF64B5F6), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Deskripsi wajib diisi';
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: const Text('Bagikan Sekarang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF64B5F6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF64B5F6), size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF64B5F6), width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
    );
  }
}
