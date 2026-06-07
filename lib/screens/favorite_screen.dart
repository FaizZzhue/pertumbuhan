import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/post.dart';
import '../services/post_service.dart';
import 'detail_screen.dart';

const Map<String, Color> _catColors = {
  'Hias':    Color(0xFF3D5A3E),
  'Buah':    Color(0xFFC07C30),
  'Herbal':  Color(0xFF5A8A5A),
  'Bunga':   Color(0xFFC46A8A),
  'Outdoor': Color(0xFF6A8AC4),
  'Indoor':  Color(0xFF6B4F3A),
};

const List<Map<String, dynamic>> _kFavCat = [
  {'key': 'Semua',   'emoji': '🌿', 'color': Color(0xFF3D5A3E)},
  {'key': 'Hias',    'emoji': '🪴', 'color': Color(0xFF3D5A3E)},
  {'key': 'Buah',    'emoji': '🍊', 'color': Color(0xFFC07C30)},
  {'key': 'Herbal',  'emoji': '🌿', 'color': Color(0xFF5A8A5A)},
  {'key': 'Bunga',   'emoji': '🌸', 'color': Color(0xFFC46A8A)},
  {'key': 'Outdoor', 'emoji': '🌳', 'color': Color(0xFF6A8AC4)},
  {'key': 'Indoor',  'emoji': '🪴', 'color': Color(0xFF6B4F3A)},
];

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  String _selectedCategory = 'Semua';
  String? locationName;

  List<Post> _filter(List<Post> posts) {
    if (_selectedCategory == 'Semua') return posts;
    return posts
      .where((p) => (p.category ?? '').toLowerCase() == _selectedCategory.toLowerCase())
      .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: StreamBuilder<List<Post>>(
        stream: PostService.getFavoritePosts(),
        builder: (context, snapshot) {
          final allFavs      = snapshot.data ?? [];
          final filteredFavs = _filter(allFavs);
          final isLoading    = snapshot.connectionState == ConnectionState.waiting;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  color: const Color(0xFF1A2418),
                  padding: EdgeInsets.only(
                    top:    MediaQuery.of(context).padding.top + 20,
                    left:   20,
                    right:  20,
                    bottom: 18,
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
                              const Text(
                                'KOLEKSI FAVORITKU',
                                style: TextStyle(
                                  color: Color(0xFF7B9E80),
                                  fontSize: 10,
                                  letterSpacing: 2.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.08)
                              ),
                            ),
                            child: Row(
                              children: [
                                const Text('❤️',
                                  style: TextStyle(fontSize: 12)),
                                const SizedBox(width: 5),
                                Text(
                                  '${allFavs.length} Tanaman',
                                  style: const TextStyle(
                                    color: Color(0xFFA8C5A0),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tanaman yang kamu tandai sebagai favorit',
                        style: TextStyle(
                          color: const Color(0xFF7B9E80).withOpacity(0.7),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Container(
                  color: const Color(0xFF243226),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: _kFavCat.map((cat) {
                        final key      = cat['key']   as String;
                        final emoji    = cat['emoji'] as String;
                        final color    = cat['color'] as Color;
                        final isActive = _selectedCategory == key;
                        final count = key == 'Semua'
                            ? allFavs.length
                            : allFavs.where((p) => (p.category).toLowerCase() == key.toLowerCase()).length;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedCategory = key),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 13, vertical: 7),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? color
                                    : color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isActive
                                      ? color
                                      : color.withOpacity(0.35),
                                  width: 1.5,
                                ),
                                boxShadow: isActive
                                    ? [
                                        BoxShadow(
                                          color: color.withOpacity(0.4),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        )
                                      ]
                                    : [],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(emoji,
                                      style: const TextStyle(fontSize: 12)),
                                  const SizedBox(width: 5),
                                  Text(
                                    key,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isActive
                                          ? Colors.white
                                          : color,
                                    ),
                                  ),
                                  if (count > 0) ...[
                                    const SizedBox(width: 5),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: isActive
                                            ? Colors.white.withOpacity(0.25)
                                            : color.withOpacity(0.2),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '$count',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: isActive
                                              ? Colors.white
                                              : color,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              if (!isLoading && filteredFavs.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedCategory == 'Semua'
                              ? 'DAFTAR FAVORIT'
                              : _selectedCategory.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            letterSpacing: 2,
                            color: Color(0xFF6B4F3A),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${filteredFavs.length} tanaman',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFFAAAAAA),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              if (isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF3D5A3E)),
                  ),
                )
              else if (allFavs.isEmpty)
                SliverFillRemaining(child: _emptyStateNoFav())
              else if (filteredFavs.isEmpty)
                SliverFillRemaining(
                    child: _emptyStateNoCategory(_selectedCategory))
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final post = filteredFavs[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _FavCard(
                            post:       post,
                            onTap:      () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => DetailScreen(post: post)),
                            ),
                            onUnfav: () =>
                                _confirmUnfavorite(context, post),
                          ),
                        );
                      },
                      childCount: filteredFavs.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _emptyStateNoFav() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🤍', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            const Text(
              'Belum ada tanaman favorit',
              style: TextStyle(
                color: Color(0xFF3D5A3E),
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Buka detail tanaman dan ketuk ikon ❤️\nuntuk menambahkan ke favorit',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color(0xFF7B9E80), fontSize: 12, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyStateNoCategory(String category) {
    final cat = _kFavCat.firstWhere(
      (c) => c['key'] == category,
      orElse: () => _kFavCat.first,
    );
    final emoji = cat['emoji'] as String;
    final color = cat['color'] as Color;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 52)),
            const SizedBox(height: 16),
            Text(
              'Tidak ada favorit\nkategori $category',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF3D5A3E),
                fontSize: 15,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coba pilih kategori lain\natau tandai tanaman $category sebagai favorit',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Color(0xFF7B9E80), fontSize: 12, height: 1.5),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => setState(() => _selectedCategory = 'Semua'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  border: Border.all(color: color.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Lihat Semua Favorit',
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmUnfavorite(BuildContext context, Post post) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFF5F0E8),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus dari Favorit?',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
        content: Text(
          '${post.plantName} akan dihapus dari daftar favorit.',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal',
                style: TextStyle(color: Color(0xFF7B9E80))),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await PostService.toggleFavorite(post);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '${post.plantName} dihapus dari favorit'),
                    backgroundColor: const Color(0xFF3D5A3E),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCC4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

class _FavCard extends StatelessWidget {
  final Post         post;
  final VoidCallback onTap;
  final VoidCallback onUnfav;

  const _FavCard({
    required this.post,
    required this.onTap,
    required this.onUnfav,
  });

  int get _daysSince => post.createdAt == null
      ? 0
      : DateTime.now().difference(post.createdAt!.toDate()).inDays;

  Color get _catColor =>
      _catColors[post.category ?? 'Hias'] ?? const Color(0xFF3D5A3E);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
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
        child: Row(
          children: [

            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16)),
              child: SizedBox(
                width: 100,
                height: 110,
                child: _buildImage(),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            post.plantName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF1A2418),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: onUnfav,
                          child: const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Text('❤️',
                                style: TextStyle(fontSize: 17)),
                          ),
                        ),
                      ],
                    ),

                    if (post.scientificName.isNotEmpty) ...[
                      const SizedBox(height: 1),
                      Text(
                        post.scientificName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 10, color: Color(0xFF7B9E80)),
                      ),
                    ],

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 11, color: Color(0xFF7B9E80)),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            '${post.latitude?.toStringAsFixed(3) ?? '-'}, ${post.longitude?.toStringAsFixed(3) ?? '-'}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 10, color: Color(0xFF7B9E80)),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3D5A3E).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '🌱 Hari ke-$_daysSince',
                            style: const TextStyle(
                              fontSize: 9,
                              color: Color(0xFF3D5A3E),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (post.category.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _catColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              post.category,
                              style: TextStyle(
                                fontSize: 9,
                                color: _catColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        const Spacer(),
                        Text(
                          post.createdAt != null
                              ? DateFormat('d MMM y')
                                  .format(post.createdAt!.toDate())
                              : '-',
                          style: const TextStyle(
                              fontSize: 9, color: Color(0xFFBBBBBB)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (post.imageBase64 != null && post.imageBase64!.isNotEmpty) {
      try {
        final bytes = base64Decode(
          post.imageBase64!
              .replaceAll('\n', '')
              .replaceAll('data:image/jpeg;base64,', '')
              .trim(),
        );
        return Image.memory(
          bytes,
          width: 100, height: 110,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(),
        );
      } catch (_) {
        return _placeholder();
      }
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      width: 100, height: 110,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _catColor.withOpacity(0.7),
            _catColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Text('🌿', style: TextStyle(fontSize: 32)),
      ),
    );
  }
}