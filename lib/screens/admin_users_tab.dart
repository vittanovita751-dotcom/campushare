import 'package:flutter/material.dart';
import '../admin_data.dart';

class AdminUsersTab extends StatefulWidget {
  const AdminUsersTab({super.key});

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showUserDetail(AdminUser user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF64B5F6), Color(0xFF1E88E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        )
                      ],
                    ),
                    // PERBAIKAN 1: Membungkus CircleAvatar dengan Container untuk membuat Border luar
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: CircleAvatar(
                        radius: 45,
                        backgroundImage: NetworkImage(user.avatarUrl),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user.name,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'NIM: ${user.nim}',
                      // PERBAIKAN 3: Menggunakan 'withValues' untuk menggantikan 'withOpacity' yang deprecated
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                    ),
                  ],
                ),
              ),
              // Body Info
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    _buildDetailRow('Email', user.email, Icons.email_outlined),
                    _buildDetailRow('Fakultas', user.faculty, Icons.school_outlined),
                    _buildDetailRow('Rating Pengguna', '⭐ ${user.rating.toString()} / 5.0', Icons.star_border_rounded),
                    _buildDetailRow('Status Akun', user.status, Icons.shield_outlined,
                        valueColor: user.status == 'Aktif' ? Colors.green : Colors.red),
                    const SizedBox(height: 16),
                    // Trust score section
                    const Row(
                      children: [
                        Icon(Icons.health_and_safety_outlined, size: 18, color: Colors.grey),
                        SizedBox(width: 8),
                        Text('Trust Score (Skor Kepercayaan)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: user.trustScore / 100,
                              minHeight: 10,
                              backgroundColor: Colors.grey.shade200,
                              color: user.trustScore >= 80
                                  ? Colors.green
                                  : (user.trustScore >= 60 ? Colors.orange : Colors.red),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${user.trustScore} Poin',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: user.trustScore >= 80
                                ? Colors.green
                                : (user.trustScore >= 60 ? Colors.orange : Colors.red),
                          ),
                        ),
                      ],
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

  Widget _buildDetailRow(String label, String value, IconData icon, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade500),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditUser(AdminUser user) {
    final nameCtrl = TextEditingController(text: user.name);
    final nimCtrl = TextEditingController(text: user.nim);
    final emailCtrl = TextEditingController(text: user.email);
    String selectedFaculty = user.faculty;
    double currentTrustScore = user.trustScore.toDouble();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  const Icon(Icons.edit_rounded, color: Color(0xFF1E88E5)),
                  const SizedBox(width: 8),
                  Text('Edit Profil ${user.name.split(' ').first}'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Nama Lengkap', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nimCtrl,
                      decoration: const InputDecoration(labelText: 'NIM', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailCtrl,
                      decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedFaculty,
                      decoration: const InputDecoration(labelText: 'Fakultas', border: OutlineInputBorder()),
                      items: ['Fasilkom', 'FT', 'FEB', 'FK', 'FMIPA', 'FH', 'FIB']
                          .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            selectedFaculty = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Trust Score:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('${currentTrustScore.toInt()} Poin',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E88E5))),
                      ],
                    ),
                    Slider(
                      value: currentTrustScore,
                      min: 0,
                      max: 100,
                      divisions: 100,
                      label: currentTrustScore.round().toString(),
                      onChanged: (double val) {
                        setDialogState(() {
                          currentTrustScore = val;
                        });
                      },
                    )
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
                    AdminState.instance.editUser(
                      user.id,
                      nameCtrl.text.trim(),
                      nimCtrl.text.trim(),
                      emailCtrl.text.trim(),
                      selectedFaculty,
                      currentTrustScore.toInt(),
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profil berhasil diperbarui.')),
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

  void _confirmDelete(AdminUser user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
              SizedBox(width: 8),
              Text('Hapus Akun?'),
            ],
          ),
          content: Text('Apakah Anda yakin ingin menghapus akun ${user.name}? Tindakan ini tidak dapat dibatalkan.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
              onPressed: () {
                AdminState.instance.deleteUser(user.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Akun pengguna berhasil dihapus.')),
                );
              },
              child: const Text('Hapus Permanen'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AdminState.instance;

    // Filter list berdasarkan query pencarian
    final filteredUsers = state.users.where((user) {
      final nameMatches = user.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final nimMatches = user.nim.toLowerCase().contains(_searchQuery.toLowerCase());
      return nameMatches || nimMatches;
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
            BoxShadow(color: Colors.grey.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          children: [
            // Controls header (Search Bar)
            Row(
              children: [
                Expanded(
                  child: Container(
                    // PERBAIKAN 2: Menggunakan properti constraints BoxConstraints untuk membongkar maxWidth
                    constraints: const BoxConstraints(maxWidth: 400),
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
                              hintText: 'Cari berdasarkan nama atau NIM...',
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
                const Spacer(),
                Text(
                  'Menampilkan ${filteredUsers.length} Mahasiswa',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                )
              ],
            ),
            const SizedBox(height: 24),
            // Data Table dengan pengamanan Horizontal Scrollbar
            Expanded(
              child: filteredUsers.isEmpty
                  ? const Center(
                      child: Text('Tidak ada mahasiswa yang cocok dengan pencarian.', style: TextStyle(color: Colors.grey)),
                    )
                  : Scrollbar(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              dividerColor: Colors.grey.shade100,
                            ),
                            child: DataTable(
                              headingRowColor: MaterialStateProperty.all(const Color(0xFFF8F9FB)),
                              dataRowMinHeight: 64,
                              dataRowMaxHeight: 64,
                              columns: const [
                                DataColumn(label: Text('Nama / NIM', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Fakultas', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Rating', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Trust Score', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: filteredUsers.map((user) {
                                final isSuspended = user.status == 'Ditangguhkan';

                                return DataRow(
                                  cells: [
                                    // Profile / NIM cell
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircleAvatar(
                                            radius: 18,
                                            backgroundImage: NetworkImage(user.avatarUrl),
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                              Text(user.nim, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    DataCell(Text(user.email, style: const TextStyle(fontSize: 13))),
                                    DataCell(Text(user.faculty, style: const TextStyle(fontSize: 13))),
                                    // Rating Star Cell
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                                          const SizedBox(width: 4),
                                          Text(user.rating.toString(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                    // Trust progress badge
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 6,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              borderRadius: BorderRadius.circular(3),
                                            ),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Container(
                                                width: 40 * (user.trustScore / 100),
                                                decoration: BoxDecoration(
                                                  color: user.trustScore >= 80 ? Colors.green : Colors.orange,
                                                  borderRadius: BorderRadius.circular(3),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text('${user.trustScore}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    // Status Badge Cell
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isSuspended ? Colors.red.shade50 : Colors.green.shade50,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: isSuspended ? Colors.red.shade100 : Colors.green.shade100),
                                        ),
                                        child: Text(
                                          user.status,
                                          style: TextStyle(
                                            color: isSuspended ? Colors.red : Colors.green,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Actions cell
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove_red_eye_outlined, color: Colors.blueAccent),
                                            iconSize: 18,
                                            tooltip: 'Detail Pengguna',
                                            onPressed: () => _showUserDetail(user),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit_outlined, color: Colors.orangeAccent),
                                            iconSize: 18,
                                            tooltip: 'Edit Profil',
                                            onPressed: () => _showEditUser(user),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              isSuspended ? Icons.play_circle_outline_rounded : Icons.block_flipped,
                                              color: isSuspended ? Colors.green : Colors.redAccent,
                                            ),
                                            iconSize: 18,
                                            tooltip: isSuspended ? 'Aktifkan Akun' : 'Tangguhkan Akun',
                                            onPressed: () {
                                              state.suspendUser(user.id);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Akun ${user.name} berhasil ${isSuspended ? "diaktifkan" : "ditangguhkan"}.',
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.grey),
                                            iconSize: 18,
                                            tooltip: 'Hapus Akun',
                                            onPressed: () => _confirmDelete(user),
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