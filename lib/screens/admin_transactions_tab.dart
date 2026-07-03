import 'package:flutter/material.dart';
import '../admin_data.dart';

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
      case 'Ditolak':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AdminState.instance;

     
    final filteredTx = state.transactions.where((tx) {
      final matchesSearch = tx.itemName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          tx.borrower.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          tx.owner.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _statusFilter == 'Semua Status' || tx.status == _statusFilter;
      return matchesSearch && matchesStatus;
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
            // PERBAIKAN: Menggunakan 'withValues' menggantikan 'withOpacity' yang deprecated
            BoxShadow(color: Colors.grey.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          children: [
            // Controls header (Search & Filter)
            Row(
              children: [
                Expanded(
                  child: Container(
                    // PERBAIKAN: Menggunakan properti constraints BoxConstraints untuk menggantikan maxWidth yang tidak valid
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
                              hintText: 'Cari barang, peminjam, pemilik...',
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
                // Status Filter Dropdown
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
                      value: _statusFilter,
                      icon: const Icon(Icons.arrow_drop_down_rounded, color: Colors.grey),
                      items: ['Semua Status', 'Menunggu Persetujuan', 'Dipinjam', 'Dikembalikan', 'Ditolak']
                          .map((st) => DropdownMenuItem(value: st, child: Text(st, style: const TextStyle(fontSize: 13))))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _statusFilter = val;
                          });
                        }
                      },
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Menampilkan ${filteredTx.length} Transaksi',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                )
              ],
            ),
            const SizedBox(height: 24),
            // Data Table with scroll protection
            Expanded(
              child: filteredTx.isEmpty
                  ? const Center(
                      child: Text('Tidak ada transaksi peminjaman yang cocok.', style: TextStyle(color: Colors.grey)),
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
                                                  'Tidak ada aksi',
                                                  style: TextStyle(color: Colors.grey.shade400, fontSize: 11, fontStyle: FontStyle.italic),
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
