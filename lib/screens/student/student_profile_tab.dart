import 'package:flutter/material.dart';
import '../../student_data.dart';
import '../../portal_selection_screen.dart';

class StudentProfileTab extends StatelessWidget {
  const StudentProfileTab({super.key});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Selesai':
        return Colors.green;
      case 'Menunggu Persetujuan':
        return Colors.orange;
      case 'Dipinjam':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = StudentState.instance;
    final user = state.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: const Text('Profil Saya', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const PortalSelectionScreen()),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 1. User Info Card
            _buildProfileCard(user),
            const SizedBox(height: 20),
            // 2. Trust Score Card
            _buildTrustScoreCard(user),
            const SizedBox(height: 20),
            // 3. Rental History Section
            _buildHistorySection(state),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(StudentUser? user) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.03),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundImage: NetworkImage(user?.avatarUrl ?? 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? 'Novita Sari',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  // Tampilkan NIM hanya jika tersedia dan bukan placeholder '-'
                  if ((user?.nim ?? '').isNotEmpty && user?.nim != '-') ...[
                    Text(
                      'NIM: ${user!.nim}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    user?.faculty ?? 'Fasilkom',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrustScoreCard(StudentUser? user) {
    final score = user?.trustScore ?? 98;
    Color scoreColor = Colors.green;
    if (score < 60) {
      scoreColor = Colors.red;
    } else if (score < 85) {
      scoreColor = Colors.orange;
    }

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.03),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.shield_outlined, color: Color(0xFF64B5F6), size: 20),
                SizedBox(width: 8),
                Text('Skor Kepercayaan (Trust Score)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: score / 100,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade100,
                      color: scoreColor,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  '$score Poin',
                  style: TextStyle(fontWeight: FontWeight.bold, color: scoreColor, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Jaga skor kepercayaanmu di atas 80 agar tetap dapat meminjam dengan bebas. Skor dihitung berdasarkan ketepatan waktu pengembalian barang.',
              style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorySection(StudentState state) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.03),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Riwayat Transaksi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 16),
            state.rentHistory.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Text('Belum ada riwayat transaksi.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.rentHistory.length,
                    separatorBuilder: (context, index) => const Divider(height: 24),
                    itemBuilder: (context, index) {
                      final item = state.rentHistory[index];
                      final statusColor = _getStatusColor(item['status']);

                      return Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF64B5F6).withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.swap_horiz_rounded, color: Color(0xFF1E88E5), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['itemName'],
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Pemilik: ${item['owner']} • ${item['date']}',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (item['status'] == 'Dipinjam') ...[
                            ElevatedButton(
                              onPressed: () {
                                state.returnItem(item['id']);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Proses pengembalian "${item['itemName']}" berhasil dikirim.'),
                                    backgroundColor: const Color(0xFF64B5F6),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF64B5F6),
                                foregroundColor: Colors.white,
                                elevation: 0.5,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Kembalikan', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item['status'],
                              style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
