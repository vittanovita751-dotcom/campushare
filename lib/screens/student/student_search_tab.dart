import 'package:flutter/material.dart';
import '../../student_data.dart';
import '../../widgets/item_image.dart';
import 'student_item_detail_screen.dart';

class StudentSearchTab extends StatefulWidget {
  // ── Parameter baru: bisa diisi dari beranda saat user ketik di search bar ──
  final String initialQuery;
  final String initialCategory;

  const StudentSearchTab({
    super.key,
    this.initialQuery = '',
    this.initialCategory = 'Semua',
  });

  @override
  State<StudentSearchTab> createState() => _StudentSearchTabState();
}

class _StudentSearchTabState extends State<StudentSearchTab> {
  late TextEditingController _searchCtrl;
  late String _query;
  late String _activeCategory;

  final List<String> _filters = [
    'Semua', 'Buku', 'Laptop', 'Proyektor',
    'Kabel HDMI', 'Jas Laboratorium', 'Kendaraan'
  ];

  @override
  void initState() {
    super.initState();
    // Isi dari beranda kalau ada
    _query = widget.initialQuery;
    _activeCategory = widget.initialCategory;
    _searchCtrl = TextEditingController(text: _query);

    // Auto-fokus ke field jika ada query dari beranda
    if (_query.isNotEmpty || _activeCategory != 'Semua') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Scroll chip kategori ke posisi aktif jika perlu
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = StudentState.instance;

    final results = state.items.where((i) {
      final matchesSearch = _query.isEmpty ||
          i.name.toLowerCase().contains(_query.toLowerCase()) ||
          i.description.toLowerCase().contains(_query.toLowerCase()) ||
          i.category.toLowerCase().contains(_query.toLowerCase());
      final matchesFilter =
          _activeCategory == 'Semua' || i.category == _activeCategory;
      return matchesSearch && matchesFilter;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: const Text('Cari Barang',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          // ── Search Input ──────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded,
                          color: Color(0xFF64B5F6), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          autofocus: widget.initialQuery.isNotEmpty,
                          decoration: const InputDecoration(
                            hintText: 'Ketik nama barang yang dicari...',
                            hintStyle:
                                TextStyle(fontSize: 13, color: Colors.grey),
                            border: InputBorder.none,
                          ),
                          onChanged: (val) {
                            setState(() {
                              _query = val;
                              // Reset filter kategori saat user ketik manual
                              if (_activeCategory != 'Semua' && val.isEmpty) {
                                _activeCategory = 'Semua';
                              }
                            });
                          },
                        ),
                      ),
                      if (_query.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            setState(() {
                              _searchCtrl.clear();
                              _query = '';
                              _activeCategory = 'Semua';
                            });
                          },
                        )
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // ── Category Chips ──────────────────────────────────────
                SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    itemBuilder: (context, index) {
                      final filter = _filters[index];
                      final isSelected = _activeCategory == filter;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(
                            filter,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey.shade700,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: const Color(0xFF64B5F6),
                          backgroundColor: Colors.grey.shade100,
                          onSelected: (val) {
                            setState(() {
                              _activeCategory = filter;
                              // Kalau pilih kategori, kosongkan query teks
                              if (filter != 'Semua') {
                                _searchCtrl.clear();
                                _query = '';
                              }
                            });
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                                color: isSelected
                                    ? Colors.transparent
                                    : Colors.grey.shade200),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ── Info jumlah hasil ─────────────────────────────────────────
          if (_query.isNotEmpty || _activeCategory != 'Semua')
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                      fontSize: 13, color: Colors.black54),
                  children: [
                    if (_activeCategory != 'Semua') ...[
                      const TextSpan(text: 'Kategori: '),
                      TextSpan(
                        text: _activeCategory,
                        style: const TextStyle(
                            color: Color(0xFF1E88E5),
                            fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: '  '),
                    ],
                    if (_query.isNotEmpty) ...[
                      const TextSpan(text: '"'),
                      TextSpan(
                        text: _query,
                        style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: '"  '),
                    ],
                    TextSpan(text: '→ ${results.length} barang ditemukan'),
                  ],
                ),
              ),
            ),

          // ── Results ───────────────────────────────────────────────────
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          _query.isNotEmpty
                              ? 'Tidak ada barang "$_query" ditemukan.'
                              : 'Tidak ada barang di kategori $_activeCategory.',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    itemCount: results.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildResultCard(results[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(StudentItem item) {
    final statusColor = item.status == 'Tersedia' ? Colors.green : Colors.blue;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => StudentItemDetailScreen(item: item)),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.01),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            ItemImage(
              item: item,
              width: 90,
              height: 90,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.circular(12),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF64B5F6)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.category,
                          style: const TextStyle(
                              color: Color(0xFF1E88E5),
                              fontSize: 9,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.status,
                          style: TextStyle(
                              color: statusColor,
                              fontSize: 9,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          color: Colors.grey, size: 12),
                      const SizedBox(width: 2),
                      Text(item.facultyLocation,
                          style: const TextStyle(
                              fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Colors.amber, size: 14),
                      const SizedBox(width: 2),
                      Text('${item.ownerRating}',
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Text('Trust Index: ${item.ownerTrustScore}',
                          style: const TextStyle(
                              fontSize: 11,
                              color: Colors.green,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
