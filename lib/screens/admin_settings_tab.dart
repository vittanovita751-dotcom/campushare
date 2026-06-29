import 'package:flutter/material.dart';
import '../admin_data.dart';
import '../widgets/admin_ui.dart';

class AdminSettingsTab extends StatefulWidget {
  const AdminSettingsTab({super.key});

  @override
  State<AdminSettingsTab> createState() => _AdminSettingsTabState();
}

class _AdminSettingsTabState extends State<AdminSettingsTab> {
  final TextEditingController _categoryCtrl = TextEditingController();
  final TextEditingController _facultyCtrl = TextEditingController();
  final TextEditingController _bannerTitleCtrl = TextEditingController();
  final TextEditingController _bannerUrlCtrl = TextEditingController();
  final TextEditingController _faqQCtrl = TextEditingController();
  final TextEditingController _faqACtrl = TextEditingController();
  final TextEditingController _policyTitleCtrl = TextEditingController();
  final TextEditingController _policyContentCtrl = TextEditingController();

  @override
  void dispose() {
    _categoryCtrl.dispose();
    _facultyCtrl.dispose();
    _bannerTitleCtrl.dispose();
    _bannerUrlCtrl.dispose();
    _faqQCtrl.dispose();
    _faqACtrl.dispose();
    _policyTitleCtrl.dispose();
    _policyContentCtrl.dispose();
    super.dispose();
  }

  // ─── HELPERS ──────────────────────────────────────────────────────────────

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  InputDecoration _inputDeco(String label, IconData icon) => InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon, size: 18),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        isDense: true,
      );

  // ─── DIALOGS ──────────────────────────────────────────────────────────────

  void _showAddCategoryDialog({String? existing}) {
    _categoryCtrl.text = existing ?? '';
    showDialog(
      context: context,
      builder: (ctx) => _SimpleDialog(
        title: existing == null ? 'Tambah Kategori' : 'Edit Kategori',
        saveLabel: existing == null ? 'Simpan' : 'Perbarui',
        onSave: () {
          final val = _categoryCtrl.text.trim();
          if (val.isEmpty) return false;
          if (existing != null) AdminState.instance.deleteCategory(existing);
          AdminState.instance.addCategory(val);
          _categoryCtrl.clear();
          _snack(existing == null ? 'Kategori ditambahkan.' : 'Kategori diperbarui.');
          return true;
        },
        child: TextField(
          controller: _categoryCtrl,
          autofocus: true,
          decoration: _inputDeco('Nama Kategori', Icons.category_outlined),
        ),
      ),
    );
  }

  void _showAddFacultyDialog({String? existing}) {
    _facultyCtrl.text = existing ?? '';
    showDialog(
      context: context,
      builder: (ctx) => _SimpleDialog(
        title: existing == null ? 'Tambah Fakultas' : 'Edit Fakultas',
        saveLabel: existing == null ? 'Simpan' : 'Perbarui',
        onSave: () {
          final val = _facultyCtrl.text.trim();
          if (val.isEmpty) return false;
          if (existing != null) AdminState.instance.deleteFaculty(existing);
          AdminState.instance.addFaculty(val);
          _facultyCtrl.clear();
          _snack(existing == null ? 'Fakultas ditambahkan.' : 'Fakultas diperbarui.');
          return true;
        },
        child: TextField(
          controller: _facultyCtrl,
          autofocus: true,
          decoration: _inputDeco('Nama Fakultas', Icons.school_outlined),
        ),
      ),
    );
  }

  void _showAddBannerDialog() {
    _bannerTitleCtrl.clear();
    _bannerUrlCtrl.clear();
    showDialog(
      context: context,
      builder: (ctx) => _SimpleDialog(
        title: 'Unggah Banner',
        saveLabel: 'Unggah',
        onSave: () {
          final t = _bannerTitleCtrl.text.trim();
          final u = _bannerUrlCtrl.text.trim();
          if (t.isEmpty || u.isEmpty) return false;
          AdminState.instance.addBanner(t, u);
          _snack('Banner diunggah.');
          return true;
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _bannerTitleCtrl,
              autofocus: true,
              decoration: _inputDeco('Judul Banner', Icons.title_rounded),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _bannerUrlCtrl,
              decoration: _inputDeco('URL Gambar', Icons.link_rounded),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddFaqDialog({AppFaq? existing}) {
    _faqQCtrl.text = existing?.question ?? '';
    _faqACtrl.text = existing?.answer ?? '';
    showDialog(
      context: context,
      builder: (ctx) => _SimpleDialog(
        title: existing == null ? 'Tambah FAQ' : 'Edit FAQ',
        saveLabel: existing == null ? 'Simpan' : 'Perbarui',
        onSave: () {
          final q = _faqQCtrl.text.trim();
          final a = _faqACtrl.text.trim();
          if (q.isEmpty || a.isEmpty) return false;
          if (existing != null) AdminState.instance.deleteFaq(existing.id);
          AdminState.instance.addFaq(q, a);
          _snack(existing == null ? 'FAQ ditambahkan.' : 'FAQ diperbarui.');
          return true;
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _faqQCtrl,
              autofocus: true,
              decoration: _inputDeco('Pertanyaan', Icons.help_outline_rounded),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _faqACtrl,
              maxLines: 3,
              decoration: _inputDeco('Jawaban', Icons.chat_bubble_outline_rounded),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPolicyDialog({AppPolicy? existing}) {
    _policyTitleCtrl.text = existing?.title ?? '';
    _policyContentCtrl.text = existing?.content ?? '';
    showDialog(
      context: context,
      builder: (ctx) => _SimpleDialog(
        title: existing == null ? 'Tambah Kebijakan' : 'Edit Kebijakan',
        saveLabel: existing == null ? 'Simpan' : 'Perbarui',
        onSave: () {
          final t = _policyTitleCtrl.text.trim();
          final c = _policyContentCtrl.text.trim();
          if (t.isEmpty || c.isEmpty) return false;
          if (existing != null) AdminState.instance.deletePolicy(existing.id);
          AdminState.instance.addPolicy(t, c);
          _snack(existing == null ? 'Kebijakan disimpan.' : 'Kebijakan diperbarui.');
          return true;
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _policyTitleCtrl,
              autofocus: true,
              decoration: _inputDeco('Judul Kebijakan', Icons.gavel_outlined),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _policyContentCtrl,
              maxLines: 4,
              decoration: _inputDeco('Isi Kebijakan', Icons.description_outlined),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(String label, VoidCallback onDelete) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Hapus', style: TextStyle(fontSize: 15)),
        content: Text('Hapus "$label"?', style: const TextStyle(fontSize: 13)),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              onDelete();
            },
            child: const Text('Hapus', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // ─── BUILD ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdminState.instance,
      builder: (context, _) {
        final state = AdminState.instance;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: DefaultTabController(
            length: 4,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  // ── Tab bar ──
                  Container(
                    color: const Color(0xFFFAFBFD),
                    child: TabBar(
                      labelColor: const Color(0xFF1E88E5),
                      unselectedLabelColor: Colors.grey.shade500,
                      indicatorColor: const Color(0xFF1E88E5),
                      indicatorWeight: 2.5,
                      labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      unselectedLabelStyle: const TextStyle(fontSize: 10),
                      tabs: const [
                        Tab(icon: Icon(Icons.category_outlined, size: 18), text: 'Kategori'),
                        Tab(icon: Icon(Icons.view_carousel_outlined, size: 18), text: 'Banner'),
                        Tab(icon: Icon(Icons.question_answer_outlined, size: 18), text: 'FAQ'),
                        Tab(icon: Icon(Icons.gavel_outlined, size: 18), text: 'Kebijakan'),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey.shade200),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildCategoriesAndFaculties(state),
                        _buildBannersTab(state),
                        _buildFaqsTab(state),
                        _buildPoliciesTab(state),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ─── TAB 1: KATEGORI & FAKULTAS ──────────────────────────────────────────

  Widget _buildCategoriesAndFaculties(AdminState state) {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminSectionHeader(
            icon: Icons.tune_rounded,
            title: 'Manajemen Kategori & Fakultas',
            subtitle: 'Kelola daftar kategori barang dan fakultas platform',
            countLabel: '${state.categories.length + state.faculties.length} total',
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              AdminStatChip(
                icon: Icons.category_rounded,
                label: 'Kategori',
                value: state.categories.length,
                color: const Color(0xFF1E88E5),
              ),
              AdminStatChip(
                icon: Icons.school_rounded,
                label: 'Fakultas',
                value: state.faculties.length,
                color: Colors.teal,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildListCard(
                    title: 'Kategori Barang',
                    accentColor: const Color(0xFF1E88E5),
                    icon: Icons.category_rounded,
                    items: state.categories,
                    onAdd: () => _showAddCategoryDialog(),
                    onEdit: (item) => _showAddCategoryDialog(existing: item),
                    onDelete: (item) => _confirmDelete(item, () {
                      AdminState.instance.deleteCategory(item);
                      _snack('Kategori dihapus.');
                    }),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildListCard(
                    title: 'Fakultas Kampus',
                    accentColor: Colors.teal,
                    icon: Icons.school_rounded,
                    items: state.faculties,
                    onAdd: () => _showAddFacultyDialog(),
                    onEdit: (item) => _showAddFacultyDialog(existing: item),
                    onDelete: (item) => _confirmDelete(item, () {
                      AdminState.instance.deleteFaculty(item);
                      _snack('Fakultas dihapus.');
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListCard({
    required String title,
    required Color accentColor,
    required IconData icon,
    required List<String> items,
    required VoidCallback onAdd,
    required void Function(String) onEdit,
    required void Function(String) onDelete,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        children: [
          // Card header
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Row(
              children: [
                Icon(icon, color: accentColor, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: accentColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                InkWell(
                  onTap: onAdd,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add_rounded, size: 12, color: Colors.white),
                        const SizedBox(width: 3),
                        const Text('Tambah', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // List body
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 28, color: Colors.grey.shade300),
                        const SizedBox(height: 6),
                        Text('Belum ada data', style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => Divider(height: 1, indent: 10, endIndent: 10, color: Colors.grey.shade100),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        child: Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: accentColor),
                              ),
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                item,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Titik tiga — CENTER aligned
                            PopupMenuButton<String>(
                              icon: Icon(Icons.more_vert_rounded, size: 16, color: Colors.grey.shade500),
                              padding: EdgeInsets.zero,
                              offset: const Offset(0, 28),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              itemBuilder: (_) => [
                                PopupMenuItem(
                                  value: 'edit',
                                  height: 36,
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit_outlined, size: 14, color: accentColor),
                                      const SizedBox(width: 8),
                                      const Text('Edit', style: TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  height: 36,
                                  child: const Row(
                                    children: [
                                      Icon(Icons.delete_outline, size: 14, color: Colors.redAccent),
                                      SizedBox(width: 8),
                                      Text('Hapus', style: TextStyle(fontSize: 12, color: Colors.redAccent)),
                                    ],
                                  ),
                                ),
                              ],
                              onSelected: (val) {
                                if (val == 'edit') onEdit(item);
                                if (val == 'delete') onDelete(item);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ─── TAB 2: BANNER ───────────────────────────────────────────────────────

  Widget _buildBannersTab(AdminState state) {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Column(
        children: [
          // Header row
          Row(
            children: [
              Expanded(
                child: AdminSectionHeader(
                  icon: Icons.view_carousel_rounded,
                  title: 'Kelola Banner Aplikasi',
                  subtitle: 'Poster promosi yang ditampilkan ke mahasiswa',
                  countLabel: '${state.banners.length} banner',
                ),
              ),
              const SizedBox(width: 8),
              _ActionButton(
                label: 'Unggah',
                icon: Icons.upload_rounded,
                color: const Color(0xFF1E88E5),
                onTap: _showAddBannerDialog,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              AdminStatChip(
                icon: Icons.check_circle_rounded,
                label: 'Aktif',
                value: state.banners.where((b) => b.isActive).length,
                color: Colors.green,
              ),
              AdminStatChip(
                icon: Icons.pause_circle_rounded,
                label: 'Nonaktif',
                value: state.banners.where((b) => !b.isActive).length,
                color: Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: state.banners.isEmpty
                ? const AdminEmptyState(
                    icon: Icons.view_carousel_outlined,
                    title: 'Belum ada banner',
                    message: 'Unggah banner promosi atau pengumuman.',
                  )
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.3,
                    ),
                    itemCount: state.banners.length,
                    itemBuilder: (context, index) {
                      final banner = state.banners[index];
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: banner.isActive
                                ? Colors.green.withValues(alpha: 0.35)
                                : Colors.grey.shade200,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Image.network(
                              banner.imageUrl,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey.shade100,
                                child: Center(child: Icon(Icons.broken_image, size: 32, color: Colors.grey.shade400)),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                            // Status badge
                            Positioned(
                              top: 6,
                              left: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: banner.isActive
                                      ? Colors.green.withValues(alpha: 0.9)
                                      : Colors.grey.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  banner.isActive ? '● Aktif' : '● Off',
                                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            // Bottom controls
                            Positioned(
                              left: 0, right: 0, bottom: 0,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(8, 0, 4, 6),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        banner.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    // Toggle
                                    SizedBox(
                                      width: 32,
                                      height: 20,
                                      child: Transform.scale(
                                        scale: 0.6,
                                        child: Switch(
                                          value: banner.isActive,
                                          activeTrackColor: Colors.greenAccent,
                                          activeThumbColor: Colors.white,
                                          onChanged: (_) => state.toggleBannerActive(banner.id),
                                        ),
                                      ),
                                    ),
                                    // Hapus
                                    InkWell(
                                      onTap: () {
                                        state.deleteBanner(banner.id);
                                        _snack('Banner dihapus.');
                                      },
                                      child: const Icon(Icons.delete_rounded, color: Colors.redAccent, size: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ─── TAB 3: FAQ ──────────────────────────────────────────────────────────

  Widget _buildFaqsTab(AdminState state) {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: AdminSectionHeader(
                  icon: Icons.question_answer_rounded,
                  title: 'Kelola FAQ Bantuan',
                  subtitle: 'Pertanyaan sering diajukan pengguna',
                  countLabel: '${state.faqs.length} FAQ',
                ),
              ),
              const SizedBox(width: 8),
              _ActionButton(
                label: 'Tambah',
                icon: Icons.add_comment_rounded,
                color: const Color(0xFF1E88E5),
                onTap: () => _showAddFaqDialog(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: state.faqs.isEmpty
                ? const AdminEmptyState(
                    icon: Icons.question_answer_outlined,
                    title: 'Belum ada FAQ',
                    message: 'Tambahkan pertanyaan yang sering diajukan.',
                  )
                : ListView.separated(
                    itemCount: state.faqs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final faq = state.faqs[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E88E5).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(faq.question, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87)),
                                  const SizedBox(height: 4),
                                  Text(faq.answer, style: TextStyle(fontSize: 11, color: Colors.grey.shade700, height: 1.4)),
                                ],
                              ),
                            ),
                            // Titik tiga CENTER
                            Center(
                              child: PopupMenuButton<String>(
                                icon: Icon(Icons.more_vert_rounded, size: 16, color: Colors.grey.shade500),
                                padding: EdgeInsets.zero,
                                offset: const Offset(0, 28),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                itemBuilder: (_) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    height: 36,
                                    child: Row(
                                      children: [
                                        const Icon(Icons.edit_outlined, size: 14, color: Color(0xFF1E88E5)),
                                        const SizedBox(width: 8),
                                        const Text('Edit', style: TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    height: 36,
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete_outline, size: 14, color: Colors.redAccent),
                                        SizedBox(width: 8),
                                        Text('Hapus', style: TextStyle(fontSize: 12, color: Colors.redAccent)),
                                      ],
                                    ),
                                  ),
                                ],
                                onSelected: (val) {
                                  if (val == 'edit') _showAddFaqDialog(existing: faq);
                                  if (val == 'delete') _confirmDelete(faq.question, () {
                                    state.deleteFaq(faq.id);
                                    _snack('FAQ dihapus.');
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ─── TAB 4: KEBIJAKAN ────────────────────────────────────────────────────

  Widget _buildPoliciesTab(AdminState state) {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: AdminSectionHeader(
                  icon: Icons.gavel_rounded,
                  title: 'Kebijakan & Syarat Ketentuan',
                  subtitle: 'Atur hak dan kewajiban pengguna platform',
                  countLabel: '${state.policies.length} regulasi',
                ),
              ),
              const SizedBox(width: 8),
              _ActionButton(
                label: 'Tambah',
                icon: Icons.policy_rounded,
                color: const Color(0xFF1E88E5),
                onTap: () => _showAddPolicyDialog(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: state.policies.isEmpty
                ? const AdminEmptyState(
                    icon: Icons.gavel_outlined,
                    title: 'Belum ada kebijakan',
                    message: 'Tambahkan regulasi atau syarat & ketentuan.',
                  )
                : ListView.separated(
                    itemCount: state.policies.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final policy = state.policies[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.04),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E88E5).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.gavel_rounded, color: Color(0xFF1E88E5), size: 16),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(policy.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87)),
                                  const SizedBox(height: 4),
                                  Text(policy.content, style: TextStyle(fontSize: 11, color: Colors.grey.shade700, height: 1.5)),
                                ],
                              ),
                            ),
                            // Titik tiga CENTER
                            Center(
                              child: PopupMenuButton<String>(
                                icon: Icon(Icons.more_vert_rounded, size: 16, color: Colors.grey.shade500),
                                padding: EdgeInsets.zero,
                                offset: const Offset(0, 28),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                itemBuilder: (_) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    height: 36,
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit_outlined, size: 14, color: Color(0xFF1E88E5)),
                                        SizedBox(width: 8),
                                        Text('Edit', style: TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    height: 36,
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete_outline, size: 14, color: Colors.redAccent),
                                        SizedBox(width: 8),
                                        Text('Hapus', style: TextStyle(fontSize: 12, color: Colors.redAccent)),
                                      ],
                                    ),
                                  ),
                                ],
                                onSelected: (val) {
                                  if (val == 'edit') _showAddPolicyDialog(existing: policy);
                                  if (val == 'delete') _confirmDelete(policy.title, () {
                                    state.deletePolicy(policy.id);
                                    _snack('Kebijakan dihapus.');
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── REUSABLE WIDGETS ─────────────────────────────────────────────────────────

/// Tombol aksi kecil yang konsisten (Tambah, Unggah, dll.)
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 13),
      label: Text(label, style: const TextStyle(fontSize: 11)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

/// Dialog simpel yang reusable — batal + simpan di pojok BAWAH (tidak ada gap)
class _SimpleDialog extends StatelessWidget {
  final String title;
  final String saveLabel;
  final Widget child;
  final bool Function() onSave; // return true = tutup dialog

  const _SimpleDialog({
    required this.title,
    required this.saveLabel,
    required this.child,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      content: child,
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            minimumSize: Size.zero,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal', style: TextStyle(fontSize: 12)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E88E5),
            foregroundColor: Colors.white,
            minimumSize: Size.zero,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: () {
            if (onSave()) Navigator.pop(context);
          },
          child: Text(saveLabel, style: const TextStyle(fontSize: 12)),
        ),
      ],
    );
  }
}
