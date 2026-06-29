import 'package:flutter/material.dart';
import '../admin_data.dart';
import '../widgets/admin_ui.dart';

class AdminReportsTab extends StatefulWidget {
  const AdminReportsTab({super.key});

  @override
  State<AdminReportsTab> createState() => _AdminReportsTabState();
}

class _AdminReportsTabState extends State<AdminReportsTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'Semua Status';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Menunggu Tinjauan':
        return Colors.orange;
      case 'Peringatan Dikirim':
        return Colors.amber.shade700;
      case 'Selesai':
        return Colors.green;
      case 'User Ditangguhkan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Menunggu Tinjauan':
        return Icons.hourglass_empty_rounded;
      case 'Peringatan Dikirim':
        return Icons.warning_amber_rounded;
      case 'Selesai':
        return Icons.check_circle_outline_rounded;
      case 'User Ditangguhkan':
        return Icons.block_rounded;
      default:
        return Icons.info_outline;
    }
  }

  // ── Dialog detail laporan ──────────────────────────────────────────────────
  void _showReportDetail(AdminReport report) {
    showDialog(
      context: context,
      builder: (context) {
        final color = _getStatusColor(report.status);
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.gavel_rounded, color: Colors.redAccent, size: 24),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Laporan #${report.id}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(report.type,
                            style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Body
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Pelapor', report.reporter, Icons.person_outline),
                    _buildDetailRow('Dilaporkan', report.reportedUser, Icons.person_off_outlined,
                        valueColor: Colors.redAccent),
                    _buildDetailRow('Tanggal', report.date, Icons.calendar_today_outlined),
                    const SizedBox(height: 12),
                    const Text('Deskripsi Pelanggaran:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54)),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(report.description,
                          style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4)),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Status saat ini:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: color.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_getStatusIcon(report.status), color: color, size: 14),
                              const SizedBox(width: 5),
                              Text(report.status,
                                  style: TextStyle(
                                      color: color, fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade500),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: valueColor ?? Colors.black87)),
        ],
      ),
    );
  }

  // ── Konfirmasi kirim peringatan ───────────────────────────────────────────
  void _confirmWarn(AdminReport report) {
    final state = AdminState.instance;
    final userIdx = state.users.indexWhere((u) => u.name == report.reportedUser);
    final currentScore = userIdx != -1 ? state.users[userIdx].trustScore : 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Kirim Peringatan?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Peringatan akan dikirimkan ke ${report.reportedUser}.'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.shade100),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, color: Colors.orange, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Trust Score: $currentScore → ${(currentScore - 10).clamp(0, 100)} poin',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.warning_amber_rounded, size: 16),
            label: const Text('Kirim Peringatan'),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange, foregroundColor: Colors.white),
            onPressed: () {
              state.warnUser(report.id);
              Navigator.pop(context);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Peringatan dikirim ke ${report.reportedUser}. Trust Score berkurang 10 poin.'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Konfirmasi tangguhkan akun ────────────────────────────────────────────
  void _confirmSuspend(AdminReport report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.block_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Tangguhkan Akun?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Akun ${report.reportedUser} akan ditangguhkan dan tidak dapat menggunakan CampuShare hingga penangguhan dicabut.',
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.shade100),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.redAccent, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Akun dapat diaktifkan kembali dengan tombol "Cabut Penangguhan".',
                      style: TextStyle(fontSize: 12, color: Colors.redAccent),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.block_rounded, size: 16),
            label: const Text('Tangguhkan'),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () {
              AdminState.instance.suspendFromReport(report.id);
              Navigator.pop(context);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Akun ${report.reportedUser} berhasil ditangguhkan.'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Konfirmasi cabut penangguhan ──────────────────────────────────────────
  void _confirmLiftSuspension(AdminReport report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.play_circle_outline_rounded, color: Colors.green),
            SizedBox(width: 8),
            Text('Cabut Penangguhan?'),
          ],
        ),
        content: Text(
          'Akun ${report.reportedUser} akan diaktifkan kembali. Laporan akan ditandai sebagai Selesai.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.play_circle_outline_rounded, size: 16),
            label: const Text('Aktifkan Kembali'),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, foregroundColor: Colors.white),
            onPressed: () {
              AdminState.instance.liftSuspensionFromReport(report.id);
              Navigator.pop(context);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Penangguhan ${report.reportedUser} berhasil dicabut.'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Konfirmasi selesaikan laporan ─────────────────────────────────────────
  void _confirmResolve(AdminReport report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline_rounded, color: Colors.green),
            SizedBox(width: 8),
            Text('Tandai Selesai?'),
          ],
        ),
        content: Text(
          'Laporan #${report.id} tentang ${report.reportedUser} akan ditandai selesai tanpa tindakan tambahan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
            label: const Text('Selesaikan'),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, foregroundColor: Colors.white),
            onPressed: () {
              AdminState.instance.resolveReport(report.id);
              Navigator.pop(context);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Laporan berhasil diselesaikan.'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Tombol aksi berdasarkan status laporan ────────────────────────────────
  Widget _buildActionButtons(AdminReport report) {
    final isSuspended = report.status == 'User Ditangguhkan';
    final isResolved = report.status == 'Selesai';

    if (isResolved) {
      return Text(
        '✓ Selesai',
        style: TextStyle(
            color: Colors.green.shade600,
            fontSize: 11,
            fontWeight: FontWeight.bold),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Detail
        IconButton(
          icon: const Icon(Icons.remove_red_eye_outlined, color: Colors.blueAccent),
          iconSize: 18,
          tooltip: 'Detail Laporan',
          onPressed: () => _showReportDetail(report),
        ),
        // Peringatan — tersedia selama belum selesai dan belum suspended
        if (!isSuspended)
          IconButton(
            icon: Icon(
              Icons.warning_amber_rounded,
              color: report.status == 'Peringatan Dikirim'
                  ? Colors.orange.shade300
                  : Colors.orangeAccent,
            ),
            iconSize: 18,
            tooltip: report.status == 'Peringatan Dikirim'
                ? 'Peringatan sudah dikirim'
                : 'Kirim Peringatan (−10 Trust Score)',
            onPressed: report.status == 'Peringatan Dikirim'
                ? null
                : () => _confirmWarn(report),
          ),
        // Tangguhkan — muncul jika belum ditangguhkan
        if (!isSuspended)
          IconButton(
            icon: const Icon(Icons.block_flipped, color: Colors.redAccent),
            iconSize: 18,
            tooltip: 'Tangguhkan Akun Terlapor',
            onPressed: () => _confirmSuspend(report),
          ),
        // Cabut penangguhan — muncul HANYA jika status 'User Ditangguhkan'
        if (isSuspended)
          IconButton(
            icon: const Icon(Icons.play_circle_outline_rounded, color: Colors.green),
            iconSize: 18,
            tooltip: 'Cabut Penangguhan Akun',
            onPressed: () => _confirmLiftSuspension(report),
          ),
        // Selesai — tersedia selama laporan belum selesai
        IconButton(
          icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.green),
          iconSize: 18,
          tooltip: 'Tandai Selesai',
          onPressed: () => _confirmResolve(report),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AdminState.instance;

    // Filter dengan pencarian + status
    final filteredReports = state.reports.where((rep) {
      final matchSearch = rep.reporter.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          rep.reportedUser.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          rep.type.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          rep.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchStatus = _statusFilter == 'Semua Status' || rep.status == _statusFilter;
      return matchSearch && matchStatus;
    }).toList();

    final countWaiting = state.reports.where((r) => r.status == 'Menunggu Tinjauan').length;
    final countWarned = state.reports.where((r) => r.status == 'Peringatan Dikirim').length;
    final countSuspended = state.reports.where((r) => r.status == 'User Ditangguhkan').length;
    final countResolved = state.reports.where((r) => r.status == 'Selesai').length;

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
            const AdminSectionHeader(
              icon: Icons.gavel_rounded,
              title: 'Laporan & Pengaduan',
              subtitle: 'Tinjau dan tindak lanjuti pengaduan antar pengguna CampuShare',
              accentColor: Color(0xFFD32F2F),
            ),
            const SizedBox(height: 18),
            // Stats chips — tambah suspended
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                AdminStatChip(icon: Icons.hourglass_empty_rounded, label: 'Menunggu Tinjauan', value: countWaiting, color: const Color(0xFFF57C00)),
                AdminStatChip(icon: Icons.warning_amber_rounded, label: 'Peringatan Dikirim', value: countWarned, color: const Color(0xFFFFA000)),
                AdminStatChip(icon: Icons.block_rounded, label: 'User Ditangguhkan', value: countSuspended, color: const Color(0xFFD32F2F)),
                AdminStatChip(icon: Icons.check_circle_rounded, label: 'Selesai', value: countResolved, color: const Color(0xFF388E3C)),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 20),
            // ── Baris kontrol: search + filter status + label ────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Search bar — PERBAIKAN: gunakan TextField langsung dengan prefixIcon/suffixIcon
                // agar tidak overflow vertikal akibat Container + Row manual
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari pelapor, terlapor, jenis...',
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
                          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                        ),
                      ),
                      style: const TextStyle(fontSize: 13),
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Dropdown filter status
                SizedBox(
                  height: 44,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _statusFilter,
                        icon: const Icon(Icons.arrow_drop_down_rounded, color: Colors.grey, size: 18),
                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                        items: ['Semua Status', 'Menunggu Tinjauan', 'Peringatan Dikirim', 'User Ditangguhkan', 'Selesai']
                            .map((st) => DropdownMenuItem(value: st, child: Text(st, style: const TextStyle(fontSize: 12))))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _statusFilter = val);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Label jumlah laporan
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
                      '${filteredReports.length} laporan',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Data table
            Expanded(
              child: filteredReports.isEmpty
                  ? const AdminEmptyState(
                      icon: Icons.shield_outlined,
                      title: 'Tidak ada laporan ditemukan',
                      message: 'Belum ada pengaduan yang cocok dengan filter ini.',
                    )
                  : Scrollbar(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Theme(
                            data: Theme.of(context)
                                .copyWith(dividerColor: Colors.grey.shade100),
                            child: DataTable(
                              headingRowColor:
                                  WidgetStateProperty.all(const Color(0xFFF8F9FB)),
                              dataRowMinHeight: 70,
                              dataRowMaxHeight: 70,
                              columns: const [
                                DataColumn(label: Text('Pelapor', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Dilaporkan', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Jenis Pelanggaran', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Deskripsi', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Tanggal', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Aksi Moderasi', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: filteredReports.map((report) {
                                final color = _getStatusColor(report.status);
                                return DataRow(
                                  cells: [
                                    DataCell(Text(report.reporter,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold, fontSize: 13))),
                                    DataCell(Text(report.reportedUser,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: Colors.redAccent))),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade50,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(report.type,
                                            style: const TextStyle(
                                                color: Colors.red,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                    DataCell(
                                      SizedBox(
                                        width: 200,
                                        child: Text(
                                          report.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ),
                                    DataCell(Text(report.date,
                                        style: const TextStyle(fontSize: 13))),
                                    // Status badge
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                              color: color.withValues(alpha: 0.25)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(_getStatusIcon(report.status),
                                                color: color, size: 13),
                                            const SizedBox(width: 5),
                                            Text(report.status,
                                                style: TextStyle(
                                                    color: color,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Aksi moderasi — dinamis per status
                                    DataCell(_buildActionButtons(report)),
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
