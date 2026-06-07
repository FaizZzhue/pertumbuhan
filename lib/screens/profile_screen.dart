import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post.dart';
import '../services/post_service.dart';
import 'sign_in_screen.dart';

const _kCat = [
  {'key': 'Hias',    'color': Color(0xFF3D5A3E), 'emoji': '🪴'},
  {'key': 'Buah',    'color': Color(0xFFC07C30), 'emoji': '🍊'},
  {'key': 'Herbal',  'color': Color(0xFF5A8A5A), 'emoji': '🌿'},
  {'key': 'Bunga',   'color': Color(0xFFC46A8A), 'emoji': '🌸'},
  {'key': 'Outdoor', 'color': Color(0xFF6A8AC4), 'emoji': '🌳'},
  {'key': 'Indoor',  'color': Color(0xFF6B4F3A), 'emoji': '🪴'},
];

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? get _user => FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final userName = _user?.displayName ?? 'Pengguna';
    final email    = _user?.email ?? '';
    final initial  = userName.isNotEmpty ? userName[0].toUpperCase() : 'P';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: StreamBuilder<List<Post>>(
        stream: PostService.getPostList(),
        builder: (context, snapshot) {
          final allPosts  = snapshot.data ?? [];
          final favCount = 0;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildHeader(
                  initial:  initial,
                  userName: userName,
                  email:    email,
                  allPosts: allPosts,
                  favCount: favCount,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([

                    _sectionLabel('AKUN'),
                    const SizedBox(height: 8),
                    _buildMenuCard([
                      _MenuTile(
                        iconBg: const Color(0xFF3D5A3E),
                        icon:   Icons.person_outline,
                        title:  'Edit Profil',
                        sub:    'Ubah nama tampilan',
                        onTap:  () => _showEditNameDialog(context),
                      ),
                      _MenuTile(
                        iconBg: const Color(0xFF5A7A9E),
                        icon:   Icons.notifications_outlined,
                        title:  'Notifikasi',
                        sub:    'Pengingat siram tanaman',
                        onTap:  () => _snack(context, 'Fitur segera hadir 🌿'),
                      ),
                    ]),

                    const SizedBox(height: 20),

                    _sectionLabel('TANAMAN'),
                    const SizedBox(height: 8),
                    _buildMenuCard([
                      _MenuTile(
                        iconBg:   const Color(0xFF3D5A3E),
                        icon:     Icons.local_florist_outlined,
                        title:    'Semua Tanamanku',
                        sub:      '${allPosts.length} tanaman terdaftar',
                        onTap:    () {},
                        trailing: _countBadge(
                          '${allPosts.length}', const Color(0xFF3D5A3E)),
                      ),
                      _MenuTile(
                        iconBg:   const Color(0xFFB05070),
                        icon:     Icons.favorite_outline,
                        title:    'Tanaman Favorit',
                        sub:      '$favCount tanaman difavoritkan',
                        onTap:    () {},
                        trailing: _countBadge(
                          '$favCount', const Color(0xFFB05070)),
                      ),
                    ]),

                    const SizedBox(height: 20),

                    _sectionLabel('STATISTIK KATEGORI'),
                    const SizedBox(height: 8),
                    _buildCategoryStats(allPosts),

                    const SizedBox(height: 20),

                    _sectionLabel('LAINNYA'),
                    const SizedBox(height: 8),
                    _buildMenuCard([
                      _MenuTile(
                        iconBg: const Color(0xFF6B4F3A),
                        icon:   Icons.info_outline,
                        title:  'Tentang Aplikasi',
                        sub:    'Pertumbuhan v1.0.0',
                        onTap:  () => _showAboutDialog(context),
                      ),
                    ]),

                    const SizedBox(height: 20),

                    GestureDetector(
                      onTap: () => _showLogoutDialog(context),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.07),
                          border: Border.all(
                              color: Colors.red.withOpacity(0.2)),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout,
                                color: Color(0xFFCC4444), size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Keluar dari Akun',
                              style: TextStyle(
                                color: Color(0xFFCC4444),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Center(
                      child: Text(
                        '🌿 Pertumbuhan v1.0.0',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFFAAAAAA),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader({
    required String     initial,
    required String     userName,
    required String     email,
    required List<Post> allPosts,
    required int        favCount,
  }) {
    return Container(
      color: const Color(0xFF1A2418),
      padding: EdgeInsets.only(
        top:    MediaQuery.of(context).padding.top + 20,
        left:   20,
        right:  20,
        bottom: 24,
      ),
      child: Column(
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E4A30), Color(0xFF7B9E80)],
                begin:  Alignment.topLeft,
                end:    Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(36),
              border: Border.all(
                  color: Colors.white.withOpacity(0.12), width: 3),
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            userName,
            style: const TextStyle(
              color: Color(0xFFF5F0E8),
              fontSize: 18,
              fontStyle: FontStyle.italic,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),

          Text(
            email,
            style: const TextStyle(color: Color(0xFF7B9E80), fontSize: 12),
          ),

          const SizedBox(height: 20),

          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.08))),
            ),
            padding: const EdgeInsets.only(top: 16),
            child: FutureBuilder<int>(
              future: PostService.getTotalLogs(_user?.uid ?? ''),
              builder: (context, snap) {
                final totalLogs = snap.data ?? 0;
                return Row(
                  children: [
                    _statItem('${allPosts.length}', 'Tanaman'),
                    _statDivider(),
                    _statItem('$favCount',           'Favorit'),
                    _statDivider(),
                    _statItem('$totalLogs',          'Log'),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String val, String label) => Expanded(
        child: Column(
          children: [
            Text(
              val,
              style: const TextStyle(
                color: Color(0xFFF5F0E8),
                fontSize: 22,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF7B9E80),
                fontSize: 9,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );

  Widget _statDivider() => Container(
        width: 1, height: 32,
        color: Colors.white.withOpacity(0.08),
      );

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          letterSpacing: 2,
          color: Color(0xFF6B4F3A),
          fontWeight: FontWeight.w700,
        ),
      );

  Widget _buildMenuCard(List<_MenuTile> tiles) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:  Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(tiles.length, (i) {
          final t      = tiles[i];
          final isLast = i == tiles.length - 1;
          return Column(
            children: [
              InkWell(
                onTap: t.onTap,
                borderRadius: BorderRadius.vertical(
                  top:    i == 0    ? const Radius.circular(16) : Radius.zero,
                  bottom: isLast    ? const Radius.circular(16) : Radius.zero,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 13),
                  child: Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: t.iconBg.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(t.icon, color: t.iconBg, size: 18),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.title,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF1A2418),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (t.sub.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                t.sub,
                                style: const TextStyle(
                                    fontSize: 11, color: Color(0xFFAAAAAA)),
                              ),
                            ],
                          ],
                        ),
                      ),
                      t.trailing ??
                          const Icon(Icons.chevron_right,
                              color: Color(0xFFCCCCCC), size: 20),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                const Divider(
                    height: 1, indent: 66, color: Color(0xFFF5F5F5)),
            ],
          );
        }),
      ),
    );
  }

  Widget _countBadge(String val, Color color) => Text(
        val,
        style: TextStyle(
          fontSize: 14,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      );

  Widget _buildCategoryStats(List<Post> posts) {
    final total = posts.isEmpty ? 1 : posts.length;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10, offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: _kCat.map((cat) {
          final key   = cat['key']   as String;
          final color = cat['color'] as Color;
          final emoji = cat['emoji'] as String;
          final count = posts
              .where((p) =>
                  (p.category ?? '').toLowerCase() == key.toLowerCase())
              .length;
          final ratio = (count / total).clamp(0.0, 1.0);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 22,
                  child: Text(emoji, style: const TextStyle(fontSize: 15)),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 52,
                  child: Text(
                    key,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF555555),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 7,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: ratio,
                        child: Container(
                          height: 7,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 18,
                  child: Text(
                    '$count',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 12,
                      color: count > 0 ? color : const Color(0xFFCCCCCC),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  void _snack(BuildContext ctx, String msg) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: const Color(0xFF3D5A3E),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _showEditNameDialog(BuildContext context) {
    final ctrl = TextEditingController(text: _user?.displayName ?? '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFF5F0E8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Nama',
            style: TextStyle(fontStyle: FontStyle.italic)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(fontSize: 14, color: Color(0xFF1A2418)),
          decoration: InputDecoration(
            hintText: 'Nama baru kamu',
            hintStyle: const TextStyle(color: Color(0xFFAAAAAA)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal',
                style: TextStyle(color: Color(0xFF7B9E80))),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = ctrl.text.trim();
              if (name.isNotEmpty) {
                await _user?.updateDisplayName(name);
                if (context.mounted) {
                  Navigator.pop(context);
                  setState(() {});
                  _snack(context, 'Nama berhasil diubah ✅');
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3D5A3E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFF5F0E8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar?',
            style: TextStyle(fontStyle: FontStyle.italic)),
        content: const Text('Kamu akan keluar dari akunmu.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal',
                style: TextStyle(color: Color(0xFF7B9E80))),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await PostService.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const SignInScreen()),
                  (_) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCC4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFF5F0E8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('🌿', style: TextStyle(fontSize: 48)),
            SizedBox(height: 12),
            Text(
              'Pertumbuhan',
              style: TextStyle(
                fontSize: 20,
                fontStyle: FontStyle.italic,
                color: Color(0xFF1A2418),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Jurnal Tanaman Pribadi',
              style: TextStyle(fontSize: 12, color: Color(0xFF7B9E80)),
            ),
            SizedBox(height: 12),
            Text('Versi 1.0.0',
                style: TextStyle(fontSize: 11, color: Color(0xFFAAAAAA))),
            SizedBox(height: 4),
            Text(
              'Tugas Pemrograman Aplikasi Bergerak 2',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Color(0xFFAAAAAA)),
            ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup',
                  style: TextStyle(color: Color(0xFF3D5A3E))),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile {
  final Color      iconBg;
  final IconData   icon;
  final String     title;
  final String     sub;
  final VoidCallback onTap;
  final Widget?    trailing;

  const _MenuTile({
    required this.iconBg,
    required this.icon,
    required this.title,
    required this.sub,
    required this.onTap,
    this.trailing,
  });
}
