import 'package:flutter/material.dart';
import '../admin_data.dart';

class AdminHomeTab extends StatefulWidget {
  const AdminHomeTab({super.key});

  @override
  State<AdminHomeTab> createState() => _AdminHomeTabState();
}

class _AdminHomeTabState extends State<AdminHomeTab> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _chartAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _chartAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AdminState.instance;

    // Computed Stats
    final totalUsers = state.users.length;
    final totalItems = state.items.length;
    final itemsAvailable = state.items.where((i) => i.status == 'Tersedia').length;
    final itemsBorrowed = state.items.where((i) => i.status == 'Dipinjam').length;
    final totalTx = state.transactions.length;
    final totalReports = state.reports.where((r) => r.status != 'Selesai').length;

    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1100;
    final isTablet = screenSize.width > 700 && screenSize.width <= 1100;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row of Cards
          _buildStatsGrid(
            isDesktop: isDesktop,
            isTablet: isTablet,
            totalUsers: totalUsers,
            totalItems: totalItems,
            itemsAvailable: itemsAvailable,
            itemsBorrowed: itemsBorrowed,
            totalTx: totalTx,
            totalReports: totalReports,
          ),
          const SizedBox(height: 24),
          // Charts Section
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildLineChartCard()),
                const SizedBox(width: 24),
                Expanded(flex: 2, child: _buildCategoriesCard(state)),
              ],
            )
          else ...[
            _buildLineChartCard(),
            const SizedBox(height: 24),
            _buildCategoriesCard(state),
          ],
          const SizedBox(height: 24),
          // Recent Activities / Notifications log
          _buildRecentActivitySection(state),
        ],
      ),
    );
  }

  Widget _buildStatsGrid({
    required bool isDesktop,
    required bool isTablet,
    required int totalUsers,
    required int totalItems,
    required int itemsAvailable,
    required int itemsBorrowed,
    required int totalTx,
    required int totalReports,
  }) {
    int crossAxisCount = 1;
    if (isDesktop) {
      crossAxisCount = 6;
    } else if (isTablet) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 2;
    }

    final double width = MediaQuery.of(context).size.width;
    // Calculate aspect ratio dynamically to prevent overflow
    double childAspectRatio = 1.3;
    if (width < 600) {
      childAspectRatio = 1.2;
    }

    return GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: childAspectRatio,
      children: [
        _buildStatCard('Total Pengguna', '$totalUsers', Icons.group_rounded, const Color(0xFF64B5F6), const Color(0xFF1976D2)),
        _buildStatCard('Total Barang', '$totalItems', Icons.inventory_rounded, const Color(0xFF81C784), const Color(0xFF388E3C)),
        _buildStatCard('Barang Tersedia', '$itemsAvailable', Icons.check_circle_rounded, const Color(0xFF4DB6AC), const Color(0xFF00796B)),
        _buildStatCard('Sedang Dipinjam', '$itemsBorrowed', Icons.lock_clock_rounded, const Color(0xFFFFB74D), const Color(0xFFF57C00)),
        _buildStatCard('Total Transaksi', '$totalTx', Icons.swap_horizontal_circle_rounded, const Color(0xFFBA68C8), const Color(0xFF7B1FA2)),
        _buildStatCard('Laporan Aktif', '$totalReports', Icons.gavel_rounded, const Color(0xFFE57373), const Color(0xFFD32F2F)),
      ],
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color softColor, Color darkColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: softColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: darkColor, size: 20),
              ),
              Icon(Icons.trending_up_rounded, color: Colors.green.shade400, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              count,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChartCard() {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tren Peminjaman Bulanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 4),
                  Text('Aktivitas peminjaman barang mahasiswa (Jan - Jun 2026)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF64B5F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '+12.5% vs Bulan Lalu',
                  style: TextStyle(color: Color(0xFF1E88E5), fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Custom Drawn Bezier Chart Canvas
          SizedBox(
            height: 220,
            width: double.infinity,
            child: AnimatedBuilder(
              animation: _chartAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: BezierChartPainter(
                    animationValue: _chartAnimation.value,
                    dataPoints: [28, 45, 32, 60, 52, 75], // Mock transaction counts per month
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesCard(AdminState state) {
    // Count items per category
    final Map<String, int> catCounts = {};
    for (var cat in state.categories) {
      catCounts[cat] = state.items.where((i) => i.category == cat).length;
    }
    // Total catalog items
    final totalItems = state.items.length;

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kategori Terpopuler', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          const Text('Distribusi inventaris berdasarkan kategori', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 20),
          ...catCounts.entries.map((entry) {
            final categoryName = entry.key;
            final count = entry.value;
            final pct = totalItems > 0 ? (count / totalItems) : 0.0;

            Color barColor = const Color(0xFF64B5F6);
            if (categoryName == 'Kendaraan') barColor = Colors.purple.shade300;
            if (categoryName == 'Proyektor') barColor = Colors.orange.shade300;
            if (categoryName == 'Jas Laboratorium') barColor = Colors.teal.shade300;
            if (categoryName == 'Laptop') barColor = Colors.green.shade300;

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(categoryName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                      Text('$count Unit (${(pct * 100).toStringAsFixed(0)}%)', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Stack(
                    children: [
                      Container(
                        height: 8,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 800),
                        height: 8,
                        width: (pct * 250).clamp(0, 400).toDouble(), // responsive width limit
                        decoration: BoxDecoration(
                          color: barColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection(AdminState state) {
    return Container(
      width: double.infinity,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Aktivitas Sistem Terbaru', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              TextButton(
                onPressed: () {
                  // Simply clear notifications for demo
                  setState(() {
                    state.notifications.clear();
                  });
                },
                child: const Text('Bersihkan Log', style: TextStyle(fontSize: 13, color: Color(0xFF1E88E5))),
              )
            ],
          ),
          const SizedBox(height: 16),
          if (state.notifications.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32.0),
              child: Center(
                child: Text('Tidak ada log aktivitas saat ini.', style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.notifications.length.clamp(0, 5),
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final note = state.notifications[index];
                IconData icon = Icons.info_outline_rounded;
                Color statusColor = Colors.blue;

                if (note.type == 'user') {
                  icon = Icons.person_add_rounded;
                  statusColor = Colors.green;
                } else if (note.type == 'item') {
                  icon = Icons.add_photo_alternate_rounded;
                  statusColor = Colors.orange;
                } else if (note.type == 'transaction') {
                  icon = Icons.swap_horiz_rounded;
                  statusColor = Colors.blue;
                } else if (note.type == 'report') {
                  icon = Icons.gavel_rounded;
                  statusColor = Colors.red;
                }

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  leading: CircleAvatar(
                    backgroundColor: statusColor.withOpacity(0.1),
                    child: Icon(icon, color: statusColor, size: 20),
                  ),
                  title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text(note.message, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  trailing: Text(note.time, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                );
              },
            ),
        ],
      ),
    );
  }
}

// Vector Custom Painter to render a beautiful smooth bezier trend line.
class BezierChartPainter extends CustomPainter {
  final double animationValue;
  final List<double> dataPoints;

  BezierChartPainter({required this.animationValue, required this.dataPoints});

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final paintLine = Paint()
      ..color = const Color(0xFF1E88E5)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintCircle = Paint()
      ..color = const Color(0xFF0D47A1)
      ..strokeWidth = 3
      ..style = PaintingStyle.fill;

    final paintFill = Paint()
      ..style = PaintingStyle.fill;

    final double widthBetweenPoints = size.width / (dataPoints.length - 1);
    final double maxVal = 90.0; // Max vertical scale

    // Build the curve path
    final path = Path();
    final fillPath = Path();

    // Start coordinates
    double startX = 0;
    double startY = size.height - (dataPoints[0] / maxVal) * size.height;

    // Apply animation interpolation
    startY = size.height - ((dataPoints[0] * animationValue) / maxVal) * size.height;

    path.moveTo(startX, startY);
    fillPath.moveTo(0, size.height);
    fillPath.lineTo(startX, startY);

    for (int i = 0; i < dataPoints.length - 1; i++) {
      double nextX = (i + 1) * widthBetweenPoints;
      double nextY = size.height - ((dataPoints[i + 1] * animationValue) / maxVal) * size.height;

      // Control points for smooth bezier cubic curve
      double cx1 = i * widthBetweenPoints + widthBetweenPoints / 2;
      double cy1 = size.height - ((dataPoints[i] * animationValue) / maxVal) * size.height;
      double cx2 = i * widthBetweenPoints + widthBetweenPoints / 2;
      double cy2 = nextY;

      path.cubicTo(cx1, cy1, cx2, cy2, nextX, nextY);
      fillPath.cubicTo(cx1, cy1, cx2, cy2, nextX, nextY);

      if (i == dataPoints.length - 2) {
        fillPath.lineTo(nextX, size.height);
      }
    }

    // Close fill path
    fillPath.lineTo(0, size.height);
    fillPath.close();

    // Set linear shader for fill gradient
    final fillGradient = LinearGradient(
      colors: [
        const Color(0xFF64B5F6).withOpacity(0.35),
        const Color(0xFFBBDEFB).withOpacity(0.0),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    paintFill.shader = fillGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Draw grid lines
    final paintGrid = Paint()
      ..color = Colors.grey.shade100
      ..strokeWidth = 1.0;

    for (int k = 0; k < 5; k++) {
      double h = (size.height / 4) * k;
      canvas.drawLine(Offset(0, h), Offset(size.width, h), paintGrid);
    }

    // Render paths
    canvas.drawPath(fillPath, paintFill);
    canvas.drawPath(path, paintLine);

    // Draw dots and tooltip data indices
    final List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun'];
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < dataPoints.length; i++) {
      double x = i * widthBetweenPoints;
      double y = size.height - ((dataPoints[i] * animationValue) / maxVal) * size.height;

      // Draw point circle
      canvas.drawCircle(Offset(x, y), 5.5, paintCircle);
      canvas.drawCircle(Offset(x, y), 3, Paint()..color = Colors.white);

      // Label month at bottom
      textPainter.text = TextSpan(
        text: months[i],
        style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      // Adjust offset for spacing
      textPainter.paint(canvas, Offset(x - (textPainter.width / 2), size.height - 18));

      // Label value tag on hover / point peak
      textPainter.text = TextSpan(
        text: '${dataPoints[i].toInt()}',
        style: const TextStyle(fontSize: 10, color: Color(0xFF0D47A1), fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - (textPainter.width / 2), y - 20));
    }
  }

  @override
  bool shouldRepaint(covariant BezierChartPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || oldDelegate.dataPoints != dataPoints;
  }
}
