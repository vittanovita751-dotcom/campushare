import 'package:flutter/material.dart';
import '../admin_data.dart';
import '../widgets/admin_ui.dart';

class AdminRatingsTab extends StatelessWidget {
  const AdminRatingsTab({super.key});

  int _getTransactionCount(String name, AdminState state) {
    // Count transactions where user is owner or borrower
    return state.transactions.where((tx) => tx.owner == name || tx.borrower == name).length;
  }

  @override
  Widget build(BuildContext context) {
    final state = AdminState.instance;

    // Sort users by Trust Score descending for leaderboard
    final sortedUsers = List<AdminUser>.from(state.users)
      ..sort((a, b) => b.trustScore.compareTo(a.trustScore));

    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 900;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Leaderboard Podium Card Header
          AdminSectionHeader(
            icon: Icons.emoji_events_rounded,
            title: 'Reputasi Komunitas Teratas',
            subtitle: 'Peringkat mahasiswa berdasarkan Trust Score & keaktifan transaksi',
            accentColor: Colors.amber.shade800,
            countLabel: '${sortedUsers.length} Mahasiswa',
          ),
          const SizedBox(height: 18),
          // Top 3 Podium Grid
          if (sortedUsers.length >= 3)
            GridView.count(
              crossAxisCount: isDesktop ? 3 : 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: isDesktop ? 2.2 : 3.0,
              children: [
                _buildPodiumCard(
                  user: sortedUsers[0],
                  rank: 1,
                  medalColor: Colors.amber,
                  medalName: 'Emas',
                  txCount: _getTransactionCount(sortedUsers[0].name, state),
                ),
                _buildPodiumCard(
                  user: sortedUsers[1],
                  rank: 2,
                  medalColor: Colors.grey.shade400,
                  medalName: 'Perak',
                  txCount: _getTransactionCount(sortedUsers[1].name, state),
                ),
                _buildPodiumCard(
                  user: sortedUsers[2],
                  rank: 3,
                  medalColor: Colors.orange.shade300,
                  medalName: 'Perunggu',
                  txCount: _getTransactionCount(sortedUsers[2].name, state),
                ),
              ],
            ),
          const SizedBox(height: 32),
          // Complete Ratings Table
          Container(
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
                Row(
                  children: [
                    Icon(Icons.leaderboard_rounded, color: Colors.grey.shade400, size: 18),
                    const SizedBox(width: 8),
                    const Text('Data Reputasi Semua Pengguna', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 4),
                const Padding(
                  padding: EdgeInsets.only(left: 26),
                  child: Text('Pemantauan keaktifan transaksi dan keandalan mahasiswa', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ),
                const SizedBox(height: 24),
                // Table
                Scrollbar(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.grey.shade100),
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(const Color(0xFFF8F9FB)),
                        dataRowMinHeight: 64,
                        dataRowMaxHeight: 64,
                        columns: const [
                          DataColumn(label: Text('Peringkat', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Nama Mahasiswa', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Fakultas', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Total Transaksi', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Rating Ulasan', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Trust Score', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Status Keaktifan', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: sortedUsers.asMap().entries.map((entry) {
                          final rank = entry.key + 1;
                          final user = entry.value;
                          final txCount = _getTransactionCount(user.name, state);

                          Color trustColor = Colors.green;
                          if (user.trustScore < 60) {
                            trustColor = Colors.red;
                          } else if (user.trustScore < 85) {
                            trustColor = Colors.orange;
                          }

                          return DataRow(
                            cells: [
                              DataCell(
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: rank <= 3 ? const Color(0xFF64B5F6).withValues(alpha: 0.15) : Colors.grey.shade100,
                                  child: Text(
                                    '$rank',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: rank <= 3 ? const Color(0xFF0D47A1) : Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircleAvatar(radius: 16, backgroundImage: NetworkImage(user.avatarUrl)),
                                    const SizedBox(width: 10),
                                    Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  ],
                                ),
                              ),
                              DataCell(Text(user.faculty, style: const TextStyle(fontSize: 13))),
                              DataCell(Text('$txCount Selesai', style: const TextStyle(fontSize: 13))),
                              // Stars representation
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                                    const SizedBox(width: 4),
                                    Text('${user.rating}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  ],
                                ),
                              ),
                              // Trust Score Badge
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: trustColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${user.trustScore} Poin',
                                    style: TextStyle(color: trustColor, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                              ),
                              // Active / Non-active status
                              DataCell(
                                Text(
                                  user.status,
                                  style: TextStyle(
                                    color: user.status == 'Aktif' ? Colors.green : Colors.redAccent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPodiumCard({
    required AdminUser user,
    required int rank,
    required Color medalColor,
    required String medalName,
    required int txCount,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: medalColor.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          // Avatar + medal badge overlay
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(user.avatarUrl),
              ),
              Positioned(
                right: -6,
                bottom: -6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: medalColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Text(
                    '$rank',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // User Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  'Fakultas: ${user.faculty}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                    const SizedBox(width: 2),
                    Text('${user.rating}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Text('$txCount Trx', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          // Trust score metric
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${user.trustScore}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: medalColor == Colors.amber ? Colors.amber.shade800 : Colors.blue.shade700),
              ),
              const Text('Trust Score', style: TextStyle(fontSize: 9, color: Colors.grey)),
            ],
          )
        ],
      ),
    );
  }
}
