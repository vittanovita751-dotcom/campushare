import 'package:flutter/material.dart';
import '../admin_data.dart';

class AdminItemsTab extends StatefulWidget {
  const AdminItemsTab({super.key});

  @override
  State<AdminItemsTab> createState() => _AdminItemsTabState();
}

class _AdminItemsTabState extends State<AdminItemsTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategoryFilter = 'Semua Kategori';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showItemDetail(AdminItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: Stack(
                  children: [
                    Image.network(
                      item.imageUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        color: Colors.grey.shade100,
                        child: const Icon(Icons.broken_image_rounded, size: 64, color: Colors.grey),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(item.status).withValues(alpha: 0.9),
                        ),
                        child: Text(
                          item.status,
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                // ... Sisa kode detail row tidak ada yang error, tetap dipertahankan
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF64B5F6).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.category,
                        style: const TextStyle(color: Color(0xFF1E88E5), fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    _buildDetailRow('Pemilik Barang', item.owner, Icons.person_outline_rounded),
                    _buildDetailRow('Lokasi Barang', item.location, Icons.location_on_outlined),
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Icon(Icons.info_outline_rounded, size: 18, color: Colors.grey),
                        SizedBox(width: 8),
                        Text(
                          'Catatan Admin:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Pemeriksaan kelayakan aset dilakukan secara berkala. Pastikan status barang selalu akurat agar tidak mengganggu transaksi mahasiswa.',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Tutup'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade500),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Tersedia':
        return Colors.green;
      case 'Dipinjam':
        return Colors.blue;
      case 'Bermasalah':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showEditItem(AdminItem item) {
    final nameCtrl = TextEditingController(text: item.name);
    final locCtrl = TextEditingController(text: item.location);
    String selectedCategory = item.category;
    String selectedStatus = item.status;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  const Icon(Icons.edit_note_rounded, color: Color(0xFF1E88E5)),
                  const SizedBox(width: 8),
                  Text('Edit Barang ${item.name.split(' ').first}'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Nama Barang', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(labelText: 'Kategori', border: OutlineInputBorder()),
                      items: AdminState.instance.categories
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            selectedCategory = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: locCtrl,
                      decoration: const InputDecoration(labelText: 'Lokasi / Fakultas', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: const InputDecoration(labelText: 'Status Aset', border: OutlineInputBorder()),
                      items: ['Tersedia', 'Dipinjam', 'Bermasalah']
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            selectedStatus = val;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    AdminState.instance.editItem(
                      item.id,
                      nameCtrl.text.trim(),
                      selectedCategory,
                      locCtrl.text.trim(),
                      selectedStatus,
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Detail barang berhasil diubah.')),
                    );
                  },
                  child: const Text('Simpan'),
                )
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteItem(AdminItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.redAccent),
              SizedBox(width: 8),
              Text('Hapus Barang?'),
            ],
          ),
          content: Text('Apakah Anda yakin ingin menghapus barang "${item.name}" dari inventaris kampus?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
              onPressed: () {
                AdminState.instance.deleteItem(item.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Barang berhasil dihapus dari inventaris.')),
                );
              },
              child: const Text('Hapus'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AdminState.instance;

    final filteredItems = state.items.where((item) {
      final matchesSearch = item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.owner.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategoryFilter == 'Semua Kategori' || item.category == _selectedCategoryFilter;
      return matchesSearch && matchesCategory;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100, width: 1),
          boxShadow: [
            BoxShadow(color: Colors.grey.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    // PERBAIKAN: Menggunakan BoxConstraints untuk maxWidth
                    constraints: const BoxConstraints(maxWidth: 350),
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(Icons.search_rounded, color: Colors.grey.shade500, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Cari nama barang / pemilik...',
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val;
                              });
                            },
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategoryFilter,
                      icon: const Icon(Icons.arrow_drop_down_rounded, color: Colors.grey),
                      items: ['Semua Kategori', ...state.categories]
                          .map((cat) => DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(fontSize: 13))))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedCategoryFilter = val;
                          });
                        }
                      },
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Menampilkan ${filteredItems.length} Barang',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                )
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: filteredItems.isEmpty
                  ? const Center(
                      child: Text('Tidak ada barang di inventaris yang cocok.', style: TextStyle(color: Colors.grey)),
                    )
                  : Scrollbar(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.grey.shade100),
                            child: DataTable(
                              // PERBAIKAN: Menggunakan WidgetStateProperty sebagai ganti MaterialStateProperty
                              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8F9FB)),
                              dataRowMinHeight: 64,
                              dataRowMaxHeight: 64,
                              columns: const [
                                DataColumn(label: Text('Foto / Nama Barang', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Kategori', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Pemilik', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Lokasi / Fakultas', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: filteredItems.map((item) {
                                final color = _getStatusColor(item.status);
                                final isProblematic = item.status == 'Bermasalah';

                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              item.imageUrl,
                                              width: 44,
                                              height: 44,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => Container(
                                                width: 44,
                                                height: 44,
                                                color: Colors.grey.shade100,
                                                child: const Icon(Icons.image, size: 20, color: Colors.grey),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                        ],
                                      ),
                                    ),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF64B5F6).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          item.category,
                                          style: const TextStyle(color: Color(0xFF1E88E5), fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    DataCell(Text(item.owner, style: const TextStyle(fontSize: 13))),
                                    DataCell(Text(item.location, style: const TextStyle(fontSize: 13))),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: color.withValues(alpha: 0.2)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 6,
                                              height: 6,
                                              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              item.status,
                                              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove_red_eye_outlined, color: Colors.blueAccent),
                                            iconSize: 18,
                                            tooltip: 'Detail Barang',
                                            onPressed: () => _showItemDetail(item),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit_outlined, color: Colors.orangeAccent),
                                            iconSize: 18,
                                            tooltip: 'Edit Barang',
                                            onPressed: () => _showEditItem(item),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              isProblematic ? Icons.check_circle_outline : Icons.warning_amber_outlined,
                                              color: isProblematic ? Colors.green : Colors.redAccent,
                                            ),
                                            iconSize: 18,
                                            tooltip: isProblematic ? 'Tandai Tersedia' : 'Tandai Bermasalah',
                                            onPressed: () {
                                              state.toggleItemProblematic(item.id);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Barang "${item.name}" berhasil ditandai sebagai ${isProblematic ? "Tersedia" : "Bermasalah"}.',
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.grey),
                                            iconSize: 18,
                                            tooltip: 'Hapus Barang',
                                            onPressed: () => _confirmDeleteItem(item),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}