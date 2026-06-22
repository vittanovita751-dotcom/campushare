import 'package:flutter/material.dart';
import '../admin_data.dart';

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

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Kategori Baru'),
          content: TextField(
            controller: _categoryCtrl,
            decoration: const InputDecoration(labelText: 'Nama Kategori', border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                if (_categoryCtrl.text.trim().isNotEmpty) {
                  AdminState.instance.addCategory(_categoryCtrl.text.trim());
                  _categoryCtrl.clear();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kategori baru ditambahkan.')));
                }
              },
              child: const Text('Simpan'),
            )
          ],
        );
      },
    );
  }

  void _showAddFacultyDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Fakultas Baru'),
          content: TextField(
            controller: _facultyCtrl,
            decoration: const InputDecoration(labelText: 'Nama Fakultas', border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                if (_facultyCtrl.text.trim().isNotEmpty) {
                  AdminState.instance.addFaculty(_facultyCtrl.text.trim());
                  _facultyCtrl.clear();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fakultas baru ditambahkan.')));
                }
              },
              child: const Text('Simpan'),
            )
          ],
        );
      },
    );
  }

  void _showAddBannerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Unggah Banner Baru'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _bannerTitleCtrl,
                decoration: const InputDecoration(labelText: 'Judul Banner / Event', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _bannerUrlCtrl,
                decoration: const InputDecoration(labelText: 'URL Gambar Banner', border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                if (_bannerTitleCtrl.text.trim().isNotEmpty && _bannerUrlCtrl.text.trim().isNotEmpty) {
                  AdminState.instance.addBanner(_bannerTitleCtrl.text.trim(), _bannerUrlCtrl.text.trim());
                  _bannerTitleCtrl.clear();
                  _bannerUrlCtrl.clear();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Banner baru diunggah.')));
                }
              },
              child: const Text('Unggah'),
            )
          ],
        );
      },
    );
  }

  void _showAddFaqDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah FAQ Bantuan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _faqQCtrl,
                decoration: const InputDecoration(labelText: 'Pertanyaan', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _faqACtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Jawaban Lengkap', border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                if (_faqQCtrl.text.trim().isNotEmpty && _faqACtrl.text.trim().isNotEmpty) {
                  AdminState.instance.addFaq(_faqQCtrl.text.trim(), _faqACtrl.text.trim());
                  _faqQCtrl.clear();
                  _faqACtrl.clear();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('FAQ baru berhasil disimpan.')));
                }
              },
              child: const Text('Simpan'),
            )
          ],
        );
      },
    );
  }

  void _showAddPolicyDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Kebijakan Aplikasi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _policyTitleCtrl,
                decoration: const InputDecoration(labelText: 'Judul Kebijakan', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _policyContentCtrl,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Konten / Isi Kebijakan', border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                if (_policyTitleCtrl.text.trim().isNotEmpty && _policyContentCtrl.text.trim().isNotEmpty) {
                  AdminState.instance.addPolicy(_policyTitleCtrl.text.trim(), _policyContentCtrl.text.trim());
                  _policyTitleCtrl.clear();
                  _policyContentCtrl.clear();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kebijakan baru berhasil disimpan.')));
                }
              },
              child: const Text('Simpan'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AdminState.instance;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: DefaultTabController(
        length: 4,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100, width: 1),
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            children: [
              // Tab Header selection
              TabBar(
                labelColor: const Color(0xFF1E88E5),
                unselectedLabelColor: Colors.grey.shade600,
                indicatorColor: const Color(0xFF1E88E5),
                indicatorWeight: 3,
                tabs: const [
                  Tab(icon: Icon(Icons.category_outlined), text: 'Kategori & Fakultas'),
                  Tab(icon: Icon(Icons.view_carousel_outlined), text: 'Banner Promo'),
                  Tab(icon: Icon(Icons.question_answer_outlined), text: 'FAQ Bantuan'),
                  Tab(icon: Icon(Icons.gavel_outlined), text: 'Kebijakan Hukum'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    // Tab 1: Categories and Faculties lists
                    _buildCategoriesAndFaculties(state),
                    // Tab 2: Application promotion banners
                    _buildBannersTab(state),
                    // Tab 3: FAQs Manager
                    _buildFaqsTab(state),
                    // Tab 4: App Policies editor
                    _buildPoliciesTab(state),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesAndFaculties(AdminState state) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Categories list card
          Expanded(
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade100),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Daftar Kategori Barang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ElevatedButton.icon(
                          onPressed: _showAddCategoryDialog,
                          icon: const Icon(Icons.add, size: 14),
                          label: const Text('Tambah', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E88E5),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.separated(
                        itemCount: state.categories.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final category = state.categories[index];
                          return ListTile(
                            title: Text(category, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                              onPressed: () {
                                state.deleteCategory(category);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kategori dihapus.')));
                              },
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          // Faculties list card
          Expanded(
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade100),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Daftar Fakultas Kampus', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ElevatedButton.icon(
                          onPressed: _showAddFacultyDialog,
                          icon: const Icon(Icons.add, size: 14),
                          label: const Text('Tambah', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E88E5),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.separated(
                        itemCount: state.faculties.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final faculty = state.faculties[index];
                          return ListTile(
                            title: Text(faculty, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                              onPressed: () {
                                state.deleteFaculty(faculty);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fakultas dihapus.')));
                              },
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannersTab(AdminState state) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kelola Banner Aplikasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  SizedBox(height: 4),
                  Text('Kelola poster promosi dan pengumuman yang muncul di aplikasi mahasiswa', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _showAddBannerDialog,
                icon: const Icon(Icons.upload_rounded, size: 14),
                label: const Text('Unggah Banner', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: state.banners.isEmpty
                ? const Center(child: Text('Tidak ada banner yang terunggah.', style: TextStyle(color: Colors.grey)))
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 350,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.4,
                    ),
                    itemCount: state.banners.length,
                    itemBuilder: (context, index) {
                      final banner = state.banners[index];
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade100),
                        ),
                        child: Stack(
                          children: [
                            // Banner image
                            Image.network(
                              banner.imageUrl,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.grey.shade100,
                                child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                              ),
                            ),
                            // Gradient Overlay
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                            // Text contents & controls
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    banner.title,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Toggle Switch Active Status
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Transform.scale(
                                            scale: 0.7,
                                            child: Switch(
                                              value: banner.isActive,
                                              activeColor: Colors.greenAccent,
                                              onChanged: (val) {
                                                state.toggleBannerActive(banner.id);
                                              },
                                            ),
                                          ),
                                          Text(
                                            banner.isActive ? 'Aktif' : 'Nonaktif',
                                            style: TextStyle(
                                              color: banner.isActive ? Colors.greenAccent : Colors.grey,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Delete button
                                      IconButton(
                                        icon: const Icon(Icons.delete_forever, color: Colors.redAccent, size: 20),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () {
                                          state.deleteBanner(banner.id);
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Banner dihapus.')));
                                        },
                                      ),
                                    ],
                                  ),
                                ],
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

  Widget _buildFaqsTab(AdminState state) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kelola FAQ Bantuan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  SizedBox(height: 4),
                  Text('Pertanyaan yang paling sering diajukan oleh peminjam & pemilik barang', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _showAddFaqDialog,
                icon: const Icon(Icons.add_comment_rounded, size: 14),
                label: const Text('Tambah FAQ', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: state.faqs.isEmpty
                ? const Center(child: Text('Belum ada FAQ bantuan.', style: TextStyle(color: Colors.grey)))
                : ListView.separated(
                    itemCount: state.faqs.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final faq = state.faqs[index];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.help_outline_rounded, color: Color(0xFF1E88E5), size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(faq.question, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                                  const SizedBox(height: 8),
                                  Text(faq.answer, style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.4)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                              onPressed: () {
                                state.deleteFaq(faq.id);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('FAQ dihapus.')));
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

  Widget _buildPoliciesTab(AdminState state) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kebijakan & Syarat Ketentuan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  SizedBox(height: 4),
                  Text('Dokumen hukum untuk mengatur hak dan kewajiban peminjam/pemilik barang', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _showAddPolicyDialog,
                icon: const Icon(Icons.policy_rounded, size: 14),
                label: const Text('Tambah Regulasi', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: state.policies.isEmpty
                ? const Center(child: Text('Belum ada kebijakan hukum.', style: TextStyle(color: Colors.grey)))
                : ListView.separated(
                    itemCount: state.policies.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final policy = state.policies[index];
                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade100),
                          boxShadow: [
                            BoxShadow(color: Colors.grey.withOpacity(0.01), blurRadius: 4, offset: const Offset(0, 2))
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.gavel_rounded, color: Color(0xFF1E88E5), size: 20),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(policy.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                                  const SizedBox(height: 8),
                                  Text(policy.content, style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.5)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                              onPressed: () {
                                state.deletePolicy(policy.id);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kebijakan dihapus.')));
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
}
