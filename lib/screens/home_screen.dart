import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/post.dart';
import '../services/post_service.dart';
import 'add_post_screen.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat pagi ☀️';
    if (hour < 15) return 'Selamat siang 🌤';
    if (hour < 18) return 'Selamat sore 🌇';
    return 'Selamat malam 🌙';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? 'Pengguna';
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'P';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: StreamBuilder<List<Post>>(
        stream: PostService.getPostList(),
        builder: (context, snapshot) {
          final posts = snapshot.data ?? [];

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  color: const Color(0xFF1E2B1F),
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 20,
                    left: 20, right: 20, bottom: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _greeting(),
                                style: const TextStyle(
                                  color: Color(0xFF7B9E80),
                                  fontSize: 12,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Faiz Gardener',
                                style: TextStyle(
                                  color: Color(0xFFF5F0E8),
                                  fontSize: 22,
                                  fontStyle: FontStyle.italic,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => _showLogoutDialog(context),
                            child: Container(
                              width: 42, height: 42,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF3D5A3E), Color(0xFF7B9E80)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(21),
                              ),
                              child: Center(
                                child: Text(
                                  initial,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _statPill('🪴', '${posts.length} Tanaman'),
                          const SizedBox(width: 10),
                          _statPill('📅', DateFormat('d MMM y').format(DateTime.now())),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              if (snapshot.connectionState == ConnectionState.waiting)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF3D5A3E)),
                  ),
                )
              else if (posts.isEmpty)
                SliverFillRemaining(child: _emptyState())
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        if (i == 0) {
                          return const Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: Text(
                              'TANAMAN TERBARU',
                              style: TextStyle(
                                fontSize: 10,
                                letterSpacing: 2,
                                color: Color(0xFF6B4F3A),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }
                        final post = posts[i - 1];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _PlantCard(
                            post: post,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailScreen(post: post),
                              ),
                            ),
                            onDelete: () => _confirmDelete(context, post),
                            onFavorite: () async {
                              await PostService.toggleFavorite(post);
                            },
                          )
                        );
                      },
                      childCount: posts.length + 1,
                    ),
                  ),
                ),
            ],
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddPostScreen()),
        ),
        backgroundColor: const Color(0xFF3D5A3E),
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _statPill(String emoji, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFA8C5A0),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🌱', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          const Text(
            'Kebunmu masih kosong',
            style: TextStyle(
              color: Color(0xFF3D5A3E),
              fontSize: 16,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tambah tanaman pertamamu!',
            style: TextStyle(color: Color(0xFF7B9E80), fontSize: 13),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddPostScreen()),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Tambah Tanaman'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3D5A3E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Post post) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFF5F0E8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Tanaman?',
          style: TextStyle(fontStyle: FontStyle.italic)),
        content: Text('${post.plantName} akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal',
              style: TextStyle(color: Color(0xFF7B9E80))),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await PostService.deletePost(post);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
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
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3D5A3E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            ),
            child:
              const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _PlantCard extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onFavorite;

  const _PlantCard({
    required this.post,
    required this.onTap,
    required this.onDelete,
    required this.onFavorite,
  });

  int get _daysSince =>
    post.createdAt == null
      ? 0
      : DateTime.now().difference(post.createdAt!.toDate()).inDays;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: post.imageBase64 != null && post.imageBase64!.isNotEmpty
                    ? Image.memory(
                        base64Decode(
                          post.imageBase64!
                            .replaceAll('\n', '')
                            .replaceAll('data:image/jpeg;base64,', '')
                            .trim(),
                        ),
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imagePlaceholder(),
                      )
                    : _imagePlaceholder(),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: onFavorite,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        post.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: post.isFavorite
                            ? Colors.red
                            : Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10, 
                  left: 10,
                  child: GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      width: 30, 
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(Icons.delete_outline,
                        color: Colors.white, size: 15),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.plantName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF1E2B1F),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (post.scientificName.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      post.scientificName,
                      style: const TextStyle(
                        fontSize: 11, color: Color(0xFF7B9E80)),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                        size: 12, color: Color(0xFF7B9E80)),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          '${post.latitude?.toStringAsFixed(4) ?? '-'}, ${post.longitude?.toStringAsFixed(4) ?? '-'}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11, color: Color(0xFF7B9E80)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    post.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12, color: Color(0xFF888888), height: 1.5),
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1, color: Color(0xFFF0F0F0)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3D5A3E).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '🌱 Hari ke-$_daysSince',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF3D5A3E),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        post.createdAt != null
                          ? DateFormat('d MMM y').format(post.createdAt!.toDate())
                          : '-',
                        style: const TextStyle(
                          fontSize: 10, color: Color(0xFFAAAAAA)),
                      ),
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

  Widget _imagePlaceholder() {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2D4A2E), Color(0xFF4A7A4D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Text('🌿', style: TextStyle(fontSize: 48)),
      ),
    );
  }
}
