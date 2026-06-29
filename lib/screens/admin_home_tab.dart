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
                Expanded(flex: 3, child: _buildLineChartCard(state)),
                const SizedBox(width: 24),
                Expanded(flex: 2, child: _buildCategoriesCard(state)),
              ],
            )
          else ...[
            _buildLineChartCard(state),
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
            color: Colors.grey.withValues(alpha: 0.03),
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
                  color: softColor.withValues(alpha: 0.15),
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

  // Hitung jumlah peminjaman per bulan (6 bulan terakhir) langsung dari data transaksi asli,
  // supaya label, grafik, dan badge persentase selalu sesuai dengan field yang benar-benar ada.
  static const List<String> _bulanSingkat = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];

  Map<String, dynamic> _hitungTrenBulanan(AdminState state) {
    final now = DateTime.now();
    final bulanList = List.generate(6, (i) {
      final offset = 5 - i;
      return DateTime(now.year, now.month - offset, 1);
    });

    final hitung = <String, int>{};
    for (final bulan in bulanList) {
      hitung['${bulan.year}-${bulan.month}'] = 0;
    }

    for (final tx in state.transactions) {
      final tanggal = DateTime.tryParse(tx.borrowDate);
      if (tanggal == null) continue;
      final key = '${tanggal.year}-${tanggal.month}';
      if (hitung.containsKey(key)) {
        hitung[key] = hitung[key]! + 1;
      }
    }

    final dataPoints = bulanList.map((b) => (hitung['${b.year}-${b.month}'] ?? 0).toDouble()).toList();
    final labels = bulanList.map((b) => _bulanSingkat[b.month - 1]).toList();

    double? persenPerubahan;
    final bulanIni = dataPoints.last;
    final bulanLalu = dataPoints[dataPoints.length - 2];
    if (bulanLalu > 0) {
      persenPerubahan = ((bulanIni - bulanLalu) / bulanLalu) * 100;
    }

    return {
      'dataPoints': dataPoints,
      'labels': labels,
      'persenPerubahan': persenPerubahan,
      'labelAwal': labels.first,
      'labelAkhir': labels.last,
      'tahunAwal': bulanList.first.year,
      'tahunAkhir': bulanList.last.year,
    };
  }

  Widget _buildLineChartCard(AdminState state) {
    final tren = _hitungTrenBulanan(state);
    final List<double> dataPoints = tren['dataPoints'];
    final List<String> labels = tren['labels'];
    final double? persenPerubahan = tren['persenPerubahan'];
    final int tahunAwal = tren['tahunAwal'];
    final int tahunAkhir = tren['tahunAkhir'];

    final periodeLabel = tahunAwal == tahunAkhir
        ? '${tren['labelAwal']} - ${tren['labelAkhir']} $tahunAkhir'
        : '${tren['labelAwal']} $tahunAwal - ${tren['labelAkhir']} $tahunAkhir';

    final nilaiMaks = dataPoints.isEmpty
        ? 1.0
        : (dataPoints.reduce((a, b) => a > b ? a : b) <= 0
            ? 1.0
            : dataPoints.reduce((a, b) => a > b ? a : b) * 1.25);

    return Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tren Peminjaman Bulanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(
                      'Aktivitas peminjaman barang mahasiswa ($periodeLabel)',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: (persenPerubahan == null ? Colors.grey : const Color(0xFF64B5F6)).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  persenPerubahan == null
                      ? 'Belum ada data'
                      : '${persenPerubahan >= 0 ? '+' : ''}${persenPerubahan.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: persenPerubahan == null ? Colors.grey.shade600 : const Color(0xFF1E88E5),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Custom Drawn Bezier Chart Canvas
          SizedBox(
            height: 240,
            width: double.infinity,
            child: ClipRect(
              child: AnimatedBuilder(
                animation: _chartAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: BezierChartPainter(
                      animationValue: _chartAnimation.value,
                      dataPoints: dataPoints,
                      maxVal: nilaiMaks,
                      labels: labels,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesCard(AdminState state) {
    // Hitung stok yang BENAR-BENAR tersedia per kategori (realtime),
    // bukan total seluruh inventaris — supaya jumlahnya otomatis berkurang
    // saat barang dipinjam/disetujui dan bertambah saat dikembalikan atau
    // ada stok baru yang ditambahkan.
    final Map<String, int> catCounts = {};
    for (var cat in state.categories) {
      catCounts[cat] = state.items.where((i) => i.category == cat && i.status == 'Tersedia').length;
    }
    // Total stok yang tersedia saat ini (lintas kategori), dipakai sebagai
    // pembagi persentase supaya persentasenya juga ikut realtime.
    final totalAvailable = state.items.where((i) => i.status == 'Tersedia').length;

    return Container(
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
          const Text('Kategori Terpopuler', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          const Text('Ketersediaan stok per kategori (realtime)', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 20),
          ...catCounts.entries.map((entry) {
            final categoryName = entry.key;
            final count = entry.value;
            final pct = totalAvailable > 0 ? (count / totalAvailable) : 0.0;

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
                      Text('$count Tersedia (${(pct * 100).toStringAsFixed(0)}%)', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
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
          BoxShadow(color: Colors.grey.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Aktivitas Sistem Terbaru',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis),
              ),
              TextButton(
                onPressed: () => setState(() => state.notifications.clear()),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Bersihkan', style: TextStyle(fontSize: 12, color: Color(0xFF1E88E5))),
              ),
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
            Column(
              children: List.generate(
                state.notifications.length.clamp(0, 5),
                (index) {
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

                  return Column(
                    children: [
                      if (index > 0) const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: statusColor.withValues(alpha: 0.1),
                              child: Icon(icon, color: statusColor, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(note.title,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  const SizedBox(height: 2),
                                  Text(note.message,
                                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(note.time,
                                style: const TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
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
  final double maxVal;
  final List<String> labels;

  BezierChartPainter({
    required this.animationValue,
    required this.dataPoints,
    this.maxVal = 90.0,
    this.labels = const ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun'],
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    // Reserve bottom space for month labels and top space for value labels
    const double bottomPadding = 28.0; // ruang untuk label bulan
    const double topPadding = 20.0;    // ruang untuk label nilai di atas titik
    final double chartHeight = size.height - bottomPadding - topPadding;
    final double chartTop = topPadding;

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

    // Helper: hitung Y dalam area grafik (bukan full size.height)
    double calcY(double val) {
      return chartTop + chartHeight - ((val * animationValue) / maxVal) * chartHeight;
    }

    // Build paths
    final path = Path();
    final fillPath = Path();

    double startX = 0;
    double startY = calcY(dataPoints[0]);

    path.moveTo(startX, startY);
    fillPath.moveTo(0, chartTop + chartHeight);
    fillPath.lineTo(startX, startY);

    for (int i = 0; i < dataPoints.length - 1; i++) {
      double nextX = (i + 1) * widthBetweenPoints;
      double nextY = calcY(dataPoints[i + 1]);

      double cx1 = i * widthBetweenPoints + widthBetweenPoints / 2;
      double cy1 = calcY(dataPoints[i]);
      double cx2 = i * widthBetweenPoints + widthBetweenPoints / 2;
      double cy2 = nextY;

      path.cubicTo(cx1, cy1, cx2, cy2, nextX, nextY);
      fillPath.cubicTo(cx1, cy1, cx2, cy2, nextX, nextY);

      if (i == dataPoints.length - 2) {
        fillPath.lineTo(nextX, chartTop + chartHeight);
      }
    }

    fillPath.lineTo(0, chartTop + chartHeight);
    fillPath.close();

    // Gradient fill
    final fillGradient = LinearGradient(
      colors: [
        const Color(0xFF64B5F6).withValues(alpha: 0.35),
        const Color(0xFFBBDEFB).withValues(alpha: 0.0),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    paintFill.shader = fillGradient.createShader(
      Rect.fromLTWH(0, chartTop, size.width, chartHeight),
    );

    // Grid lines (hanya dalam area grafik)
    final paintGrid = Paint()
      ..color = Colors.grey.shade100
      ..strokeWidth = 1.0;

    for (int k = 0; k <= 4; k++) {
      double h = chartTop + (chartHeight / 4) * k;
      canvas.drawLine(Offset(0, h), Offset(size.width, h), paintGrid);
    }

    // Draw chart
    canvas.drawPath(fillPath, paintFill);
    canvas.drawPath(path, paintLine);

    // Draw dots, value labels, and month labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < dataPoints.length; i++) {
      double x = i * widthBetweenPoints;
      double y = calcY(dataPoints[i]);

      // Dot
      canvas.drawCircle(Offset(x, y), 5.5, paintCircle);
      canvas.drawCircle(Offset(x, y), 3, Paint()..color = Colors.white);

      // Value label — di atas titik, dalam area topPadding
      textPainter.text = TextSpan(
        text: '${dataPoints[i].toInt()}',
        style: const TextStyle(fontSize: 10, color: Color(0xFF0D47A1), fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      // Clamp agar tidak keluar canvas kiri/kanan
      double valueX = (x - textPainter.width / 2).clamp(0.0, size.width - textPainter.width);
      // Posisikan 4px di atas titik, tapi minimal di y=2
      double valueY = (y - textPainter.height - 4).clamp(2.0, chartTop - 2);
      textPainter.paint(canvas, Offset(valueX, valueY));

      // Month label — di bawah garis grafik, dalam area bottomPadding
      textPainter.text = TextSpan(
        text: i < labels.length ? labels[i] : '',
        style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      double labelX = (x - textPainter.width / 2).clamp(0.0, size.width - textPainter.width);
      double labelY = chartTop + chartHeight + 8; // 8px di bawah garis baseline
      textPainter.paint(canvas, Offset(labelX, labelY));
    }
  }

  @override
  bool shouldRepaint(covariant BezierChartPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.dataPoints != dataPoints ||
        oldDelegate.maxVal != maxVal;
  }
}
