import 'package:flutter/material.dart';
import '../admin_data.dart';
import '../widgets/admin_ui.dart';

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
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                    ),
                  ],
                ),
              ),
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
                      initialValue: selectedFaculty,
                      decoration: const InputDecoration(labelText: 'Fakultas', border: OutlineInputBorder()),
                      items: ['Fasilkom', 'FT', 'FEB', 'FK', 'FMIPA', 'FH', 'FIB']
                          .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedFaculty = val);
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
                        setDialogState(() => currentTrustScore = val);
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
                    if (mounted) setState(() {});
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
                if (mounted) setState(() {});
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

    // Filter berdasarkan query pencarian — AKTIF
    final filteredUsers = state.users.where((user) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return user.name.toLowerCase().contains(q) ||
          user.nim.toLowerCase().contains(q) ||
          user.email.toLowerCase().contains(q);
    }).toList();

    final countActive = state.users.where((u) => u.status == 'Aktif').length;
    final countSuspended = state.users.where((u) => u.status == 'Ditangguhkan').length;
    final avgTrust = state.users.isEmpty
        ? 0
        : (state.users.map((u) => u.trustScore).reduce((a, b) => a + b) / state.users.length).round();

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AdminSectionHeader(
              icon: Icons.people_alt_rounded,
              title: 'Manajemen Pengguna',
              subtitle: 'Kelola data, status, dan reputasi mahasiswa pengguna CampuShare',
              accentColor: Color(0xFF1976D2),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                AdminStatChip(icon: Icons.verified_user_rounded, label: 'Aktif', value: countActive, color: const Color(0xFF388E3C)),
                AdminStatChip(icon: Icons.block_rounded, label: 'Ditangguhkan', value: countSuspended, color: const Color(0xFFD32F2F)),
                AdminStatChip(icon: Icons.shield_rounded, label: 'Rata-rata Trust Score', value: avgTrust, color: const Color(0xFF1E88E5)),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 16),
            // ── Baris kontrol: search + label jumlah ───────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Search bar — PERBAIKAN: TextField langsung dengan prefixIcon/suffixIcon
                // agar tidak overflow vertikal akibat Container + Row manual
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari nama, NIM, atau email...',
                        hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                        prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade500, size: 18),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? GestureDetector(
                                onTap: () => setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                }),
                                child: Icon(Icons.clear, size: 16, color: Colors.grey.shade500),
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 1.5),
                        ),
                      ),
                      style: const TextStyle(fontSize: 13),
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Label jumlah pengguna
                SizedBox(
                  height: 44,
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      '${filteredUsers.length} pengguna',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // ── Tabel data ──────────────────────────────────────────────────
            Expanded(
              child: filteredUsers.isEmpty
                  ? const AdminEmptyState(
                      icon: Icons.person_search_rounded,
                      title: 'Tidak ada pengguna ditemukan',
                      message: 'Coba kata kunci nama, NIM, atau email lain.',
                    )
                  : Scrollbar(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.grey.shade100),
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8F9FB)),
                              dataRowMinHeight: 60,
                              dataRowMaxHeight: 60,
                              horizontalMargin: 12,
                              columnSpacing: 20,
                              columns: const [
                                DataColumn(label: Text('Nama / NIM', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Fakultas', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Rating', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Trust', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: filteredUsers.map((user) {
                                final isSuspended = user.status == 'Ditangguhkan';
                                return DataRow(
                                  cells: [
                                    DataCell(Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircleAvatar(radius: 16, backgroundImage: NetworkImage(user.avatarUrl)),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                            Text(user.nim, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                                          ],
                                        ),
                                      ],
                                    )),
                                    DataCell(Text(user.email, style: const TextStyle(fontSize: 12))),
                                    DataCell(Text(user.faculty, style: const TextStyle(fontSize: 12))),
                                    DataCell(Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                                        const SizedBox(width: 4),
                                        Text(user.rating.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                      ],
                                    )),
                                    DataCell(Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 36,
                                          height: 5,
                                          decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(3)),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Container(
                                              width: 36 * (user.trustScore / 100),
                                              decoration: BoxDecoration(
                                                color: user.trustScore >= 80 ? Colors.green : Colors.orange,
                                                borderRadius: BorderRadius.circular(3),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text('${user.trustScore}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                      ],
                                    )),
                                    DataCell(Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isSuspended ? Colors.red.shade50 : Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: isSuspended ? Colors.red.shade100 : Colors.green.shade100),
                                      ),
                                      child: Text(
                                        user.status,
                                        style: TextStyle(color: isSuspended ? Colors.red : Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    )),
                                    DataCell(Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(icon: const Icon(Icons.remove_red_eye_outlined, color: Colors.blueAccent), iconSize: 17, tooltip: 'Detail', onPressed: () => _showUserDetail(user)),
                                        IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.orangeAccent), iconSize: 17, tooltip: 'Edit', onPressed: () => _showEditUser(user)),
                                        IconButton(
                                          icon: Icon(isSuspended ? Icons.play_circle_outline_rounded : Icons.block_flipped, color: isSuspended ? Colors.green : Colors.redAccent),
                                          iconSize: 17,
                                          tooltip: isSuspended ? 'Aktifkan' : 'Tangguhkan',
                                          onPressed: () {
                                            state.suspendUser(user.id);
                                            setState(() {});
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                              content: Text('Akun ${user.name} berhasil ${isSuspended ? "diaktifkan" : "ditangguhkan"}.'),
                                            ));
                                          },
                                        ),
                                        IconButton(icon: const Icon(Icons.delete_outline_rounded, color: Colors.grey), iconSize: 17, tooltip: 'Hapus', onPressed: () => _confirmDelete(user)),
                                      ],
                                    )),
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
