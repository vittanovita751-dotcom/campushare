import 'package:flutter/material.dart';
import '../admin_data.dart';
import '../widgets/admin_ui.dart';

class AdminTransactionsTab extends StatefulWidget {
  const AdminTransactionsTab({super.key});

  @override
  State<AdminTransactionsTab> createState() => _AdminTransactionsTabState();
}

class _AdminTransactionsTabState extends State<AdminTransactionsTab> {
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
      case 'Menunggu Persetujuan':
        return Colors.orange;
      case 'Dipinjam':
        return Colors.blue;
      case 'Dikembalikan':
        return Colors.green;
      case 'Selesai':
        return Colors.green;
      case 'Ditolak':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Menunggu Persetujuan':
        return Icons.hourglass_empty_rounded;
      case 'Dipinjam':
        return Icons.swap_horiz_rounded;
      case 'Dikembalikan':
        return Icons.check_circle_outline_rounded;
      case 'Selesai':
        return Icons.check_circle_outline_rounded;
      case 'Ditolak':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AdminState.instance;

    // Filter transactions
    final filteredTx = state.transactions.where((tx) {
      final matchesSearch = tx.itemName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          tx.borrower.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          tx.owner.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _statusFilter == 'Semua Status' || tx.status == _statusFilter;
      return matchesSearch && matchesStatus;
    }).toList();

    final countPending = state.transactions.where((t) => t.status == 'Menunggu Persetujuan').length;
    final countBorrowed = state.transactions.where((t) => t.status == 'Dipinjam').length;
    final countDone = state.transactions.where((t) => t.status == 'Dikembalikan' || t.status == 'Selesai').length;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100, width: 1),
          boxShadow: [
            // PERBAIKAN: Menggunakan 'withValues' menggantikan 'withOpacity' yang deprecated
            BoxShadow(color: Colors.grey.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          children: [
            const AdminSectionHeader(
              icon: Icons.swap_horizontal_circle_rounded,
              title: 'Manajemen Transaksi',
              subtitle: 'Setujui, tolak, dan pantau seluruh transaksi peminjaman barang',
              accentColor: Color(0xFF7B1FA2),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                AdminStatChip(icon: Icons.hourglass_empty_rounded, label: 'Menunggu Persetujuan', value: countPending, color: const Color(0xFFF57C00)),
                AdminStatChip(icon: Icons.swap_horiz_rounded, label: 'Sedang Dipinjam', value: countBorrowed, color: const Color(0xFF1976D2)),
                AdminStatChip(icon: Icons.check_circle_rounded, label: 'Selesai / Dikembalikan', value: countDone, color: const Color(0xFF388E3C)),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 20),
            // ── Baris kontrol: search + filter status + label ────────────────
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
                        hintText: 'Cari barang, peminjam, pemilik...',
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
                          borderSide: const BorderSide(color: Color(0xFF1976D2), width: 1.5),
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
                        items: ['Semua Status', 'Menunggu Persetujuan', 'Dipinjam', 'Dikembalikan', 'Selesai', 'Ditolak']
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
                // Label jumlah transaksi
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
                      '${filteredTx.length} transaksi',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Data Table with scroll protection
            Expanded(
              child: filteredTx.isEmpty
                  ? const AdminEmptyState(
                      icon: Icons.receipt_long_rounded,
                      title: 'Tidak ada transaksi ditemukan',
                      message: 'Coba ubah kata kunci pencarian atau filter status yang dipilih.',
                    )
                  : Scrollbar(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.grey.shade100),
                            child: DataTable(
                              // PERBAIKAN: Menggunakan 'WidgetStateProperty' menggantikan 'MaterialStateProperty' yang deprecated
                              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8F9FB)),
                              dataRowMinHeight: 64,
                              dataRowMaxHeight: 64,
                              columns: const [
                                DataColumn(label: Text('ID Transaksi', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Barang', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Peminjam', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Pemilik', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Tgl Pinjam', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Tgl Kembali', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Aksi Persetujuan / Update', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: filteredTx.map((tx) {
                                final color = _getStatusColor(tx.status);
                                final icon = _getStatusIcon(tx.status);
                                final isPending = tx.status == 'Menunggu Persetujuan';
                                final isBorrowed = tx.status == 'Dipinjam';

                                return DataRow(
                                  cells: [
                                    DataCell(Text(tx.id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                                    DataCell(Text(tx.itemName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                                    DataCell(Text(tx.borrower, style: const TextStyle(fontSize: 13))),
                                    DataCell(Text(tx.owner, style: const TextStyle(fontSize: 13))),
                                    DataCell(Text(tx.borrowDate, style: const TextStyle(fontSize: 13))),
                                    DataCell(Text(tx.returnDate, style: const TextStyle(fontSize: 13))),
                                    // Status Badge Cell
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          // PERBAIKAN: Menggunakan 'withValues' untuk keaslian opacity warna modern
                                          color: color.withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: color.withValues(alpha: 0.2)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(icon, color: color, size: 14),
                                            const SizedBox(width: 6),
                                            Text(
                                              tx.status,
                                              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Action buttons for Transaction Updates
                                    DataCell(
                                      isPending
                                          ? Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                ElevatedButton.icon(
                                                  onPressed: () {
                                                    state.updateTransactionStatus(tx.id, 'Dipinjam');
                                                    setState(() {});
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text('Peminjaman untuk ${tx.itemName} disetujui.'),
                                                        backgroundColor: Colors.green,
                                                      ),
                                                    );
                                                  },
                                                  icon: const Icon(Icons.check, size: 14),
                                                  label: const Text('Setujui', style: TextStyle(fontSize: 11)),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.green,
                                                    foregroundColor: Colors.white,
                                                    elevation: 0,
                                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                OutlinedButton.icon(
                                                  onPressed: () {
                                                    state.updateTransactionStatus(tx.id, 'Ditolak');
                                                    setState(() {});
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text('Peminjaman untuk ${tx.itemName} ditolak.'),
                                                        backgroundColor: Colors.redAccent,
                                                      ),
                                                    );
                                                  },
                                                  icon: const Icon(Icons.close, size: 14),
                                                  label: const Text('Tolak', style: TextStyle(fontSize: 11)),
                                                  style: OutlinedButton.styleFrom(
                                                    foregroundColor: Colors.redAccent,
                                                    side: const BorderSide(color: Colors.redAccent),
                                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : (isBorrowed
                                              ? ElevatedButton.icon(
                                                  onPressed: () {
                                                    state.updateTransactionStatus(tx.id, 'Dikembalikan');
                                                    setState(() {});
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text('Barang ${tx.itemName} telah berhasil dikembalikan.'),
                                                        backgroundColor: Colors.blue,
                                                      ),
                                                    );
                                                  },
                                                  icon: const Icon(Icons.keyboard_return_rounded, size: 14),
                                                  label: const Text('Selesai / Kembali', style: TextStyle(fontSize: 11)),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color(0xFF1E88E5),
                                                    foregroundColor: Colors.white,
                                                    elevation: 0,
                                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                  ),
                                                )
                                              : Text(
                                                  tx.status == 'Dikembalikan' ? '✓ Dikembalikan' : 'Tidak ada aksi',
                                                  style: TextStyle(
                                                    color: tx.status == 'Dikembalikan' ? Colors.green : Colors.grey.shade400,
                                                    fontSize: 11,
                                                    fontStyle: tx.status == 'Dikembalikan' ? FontStyle.normal : FontStyle.italic,
                                                    fontWeight: tx.status == 'Dikembalikan' ? FontWeight.bold : FontWeight.normal,
                                                  ),
                                                )),
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