import 'package:flutter/material.dart';
import '../admin_data.dart';

class AdminReportsTab extends StatefulWidget {
  const AdminReportsTab({super.key});

  @override
  State<AdminReportsTab> createState() => _AdminReportsTabState();
}

class _AdminReportsTabState extends State<AdminReportsTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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

  void _showReportDetail(AdminReport report) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.gavel_rounded, color: Colors.redAccent),
              const SizedBox(width: 8),
              Text('Laporan #${report.id}'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Pelapor', report.reporter),
              _buildDetailRow('Dilaporkan', report.reportedUser),
              _buildDetailRow('Jenis Pelanggaran', report.type),
              _buildDetailRow('Tanggal Pengaduan', report.date),
              const SizedBox(height: 12),
              const Text('Deskripsi Pelanggaran:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54)),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Text(
                  report.description,
                  style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Status Saat Ini:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      // Perbaikan: Menggunakan withValues untuk menghindari deprecation warning
                      color: _getStatusColor(report.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      report.status,
                      style: TextStyle(color: _getStatusColor(report.status), fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AdminState.instance;

    // Filter reports
    final filteredReports = state.reports.where((rep) {
      return rep.reporter.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          rep.reportedUser.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          rep.type.toLowerCase().contains(_searchQuery.toLowerCase());
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
            // Controls header (Search)
            Row(
              children: [
                Expanded(
                  child: Container(
                    // Perbaikan: maxWidth harus dibungkus dengan BoxConstraints
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
                              hintText: 'Cari pelapor / terlapor / jenis...',
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
                  'Menampilkan ${filteredReports.length} Laporan',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                )
              ],
            ),
            const SizedBox(height: 24),
            // Data Table with Scroll Protection
            Expanded(
              child: filteredReports.isEmpty
                  ? const Center(
                      child: Text('Tidak ada laporan pengaduan saat ini.', style: TextStyle(color: Colors.grey)),
                    )
                  : Scrollbar(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.grey.shade100),
                            child: DataTable(
                              // Perbaikan: Menggunakan WidgetStateProperty menggantikan MaterialStateProperty
                              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8F9FB)),
                              dataRowMinHeight: 70,
                              dataRowMaxHeight: 70,
                              columns: const [
                                DataColumn(label: Text('Pelapor', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Dilaporkan', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Jenis Pelanggaran', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Deskripsi Pengaduan', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Tanggal', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Aksi Moderasi', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: filteredReports.map((report) {
                                final color = _getStatusColor(report.status);

                                return DataRow(
                                  cells: [
                                    DataCell(Text(report.reporter, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                                    DataCell(Text(report.reportedUser, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.redAccent))),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade50,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          report.type,
                                          style: const TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
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
                                    DataCell(Text(report.date, style: const TextStyle(fontSize: 13))),
                                    // Status Badge Cell
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: color.withValues(alpha: 0.2)),
                                        ),
                                        child: Text(
                                          report.status,
                                          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    // Actions cell (Warn, Suspend, Resolve, Detail)
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove_red_eye_outlined, color: Colors.blueAccent),
                                            iconSize: 18,
                                            tooltip: 'Detail Pengaduan',
                                            onPressed: () => _showReportDetail(report),
                                          ),
                                          // Warn button
                                          IconButton(
                                            icon: const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
                                            iconSize: 18,
                                            tooltip: 'Kirim Peringatan (-10 Trust Score)',
                                            onPressed: () {
                                              // Perbaikan: Memanfaatkan setState() lokal untuk memicu UI update setelah mutasi data global
                                              setState(() {
                                                state.updateReportStatus(report.id, 'Peringatan Dikirim');
                                                final userIdx = state.users.indexWhere((u) => u.name == report.reportedUser);
                                                if (userIdx != -1) {
                                                  state.users[userIdx].trustScore = (state.users[userIdx].trustScore - 10).clamp(0, 100);
                                                }
                                              });
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Peringatan dikirim ke ${report.reportedUser}. Trust Score berkurang 10 poin.'),
                                                  backgroundColor: Colors.orange,
                                                ),
                                              );
                                            },
                                          ),
                                          // Suspend button
                                          IconButton(
                                            icon: const Icon(Icons.block_flipped, color: Colors.redAccent),
                                            iconSize: 18,
                                            tooltip: 'Suspend Akun Terlapor',
                                            onPressed: () {
                                              setState(() {
                                                state.updateReportStatus(report.id, 'User Ditangguhkan');
                                                final userIdx = state.users.indexWhere((u) => u.name == report.reportedUser);
                                                if (userIdx != -1) {
                                                  state.users[userIdx].status = 'Ditangguhkan';
                                                }
                                              });
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Akun ${report.reportedUser} ditangguhkan.'),
                                                  backgroundColor: Colors.redAccent,
                                                ),
                                              );
                                            },
                                          ),
                                          // Resolve button
                                          IconButton(
                                            icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.green),
                                            iconSize: 18,
                                            tooltip: 'Tandai Selesai',
                                            onPressed: () {
                                              setState(() {
                                                state.updateReportStatus(report.id, 'Selesai');
                                              });
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Laporan pengaduan diselesaikan.'),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            },
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