import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/post.dart';
import '../services/post_service.dart';
import 'package:image_picker/image_picker.dart';
import '../models/growth.dart';

class DetailScreen extends StatefulWidget {
  final Post post;
  const DetailScreen({super.key, required this.post});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Post post;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    post = widget.post;
  }

  int get _daysSince {
    if (post.createdAt == null) return 0;
    return DateTime.now().difference(post.createdAt!.toDate()).inDays;
  }

  Future<void> _showAddGrowthDialog() async {
    XFile? image;
    final noteCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Tambah Perkembangan',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final file = await PostService.pickImage(ImageSource.gallery);

                        if (file != null) {
                          setDialogState(() {
                            image = file;
                          });
                        }
                      },

                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: image == null
                          ? const Icon(Icons.add_a_photo) 
                          : FutureBuilder(
                              future: image!.readAsBytes(),
                              builder: (_, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(
                                    snapshot.data!,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              },
                            ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: noteCtrl,
                      maxLines: 4,
                      decoration:const InputDecoration(
                        hintText:'Catatan perkembangan...',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Batal'),
                ),

                ElevatedButton(
                  onPressed: () async {
                    if (image == null) return;
                    final image64 = await PostService.convertToBase64(image!);
                    await PostService.addGrowth(
                      Growth(
                        postId: post.id!,
                        imageBase64: image64,
                        note: noteCtrl.text,
                      ),
                    );

                    if (mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3D5A3E),
        foregroundColor: Colors.white,
        onPressed: _showAddGrowthDialog,
        child: const Icon(Icons.add, size: 28),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () async {
                    await PostService.toggleFavorite(post);
                    setState(() {
                      post.isFavorite = !post.isFavorite;
                    });
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            post.isFavorite
                              ? 'Ditambahkan ke favorit ❤️'
                              : 'Dihapus dari favorit 🤍',
                          ),
                        ),
                      );
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    width: 40,
                    child: Icon(
                      post.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                      color: post.isFavorite
                        ? Colors.red
                        : Colors.white,
                    ),
                  ),
                ),
              ),
            ],
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF1E2B1F),
            foregroundColor: Colors.white,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back_ios_new,
                    size: 16, color: Colors.white),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  post.imageBase64 != null && post.imageBase64!.isNotEmpty
                    ? StreamBuilder<List<Growth>>(
                      stream: PostService.getGrowth(post.id!),
                      builder: (context, snapshot) {
                        final logs = snapshot.data ?? [];
                        print("TOTAL LOG = ${logs.length}");
                        for (final log in logs) {
                          print("NOTE = ${log.note}");
                          print("IMAGE LENGTH = ${log.imageBase64.length}");
                        }

                        final images = [
                          post.imageBase64,
                          ...logs.map(
                            (e) => e.imageBase64,
                          ),
                        ];

                        print("TOTAL IMAGE = ${images.length}");
                        for (var img in images) {
                          print("IMAGE PREVIEW = ${img?.substring(0, 20)}");
                        }
                        return PageView.builder(
                          controller: _pageController,
                          itemCount: images.length,
                          itemBuilder: (_, index) {
                            return Image.memory(
                              base64Decode(
                                images[index]!
                                  .replaceAll('\n', '')
                                  .replaceAll('\r', '')
                                  .trim(),
                              ),
                              fit: BoxFit.cover,
                              gaplessPlayback: true,
                              errorBuilder: (context, error, stackTrace) {
                                print("IMAGE ERROR = $error");
                                return Container(
                                  color: Colors.red,
                                  child: const Center(
                                    child: Text(
                                      "ERROR IMAGE",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    )
                    : _heroPlaceholder(),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Color(0xCC1E2B1F),
                        ],
                        stops: [0.5, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20, left: 20, right: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post.plantName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (post.scientificName.isNotEmpty)
                                Text(
                                  post.scientificName,
                                  style: const TextStyle(
                                    color: Color(0xFFA8C5A0),
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3)),
                          ),
                          child: Text(
                            'Hari ke-$_daysSince',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                Row(
                  children: [
                    _infoChip(
                      emoji: '📅',
                      label: 'DITANAM',
                      value: post.createdAt != null
                        ? DateFormat('d MMM y').format(post.createdAt!.toDate())
                        : '-',
                    ),
                    const SizedBox(width: 10),
                    _infoChip(
                      emoji: '👤',
                      label: 'PEMILIK',
                      value: post.userFullName ?? 'Pengguna',
                    ),
                    const SizedBox(width: 10),
                    _infoChip(
                      emoji: '🌱',
                      label: 'HARI KE',
                      value: '$_daysSince',
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                _sectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionLabel('DESKRIPSI'),
                      const SizedBox(height: 10),
                      Text(
                        post.description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF555555),
                          height: 1.7,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                _sectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionLabel('LOKASI TANAM'),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () => PostService.openInMaps(post.latitude, post.longitude),
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFC8DFC8),
                                Color(0xFFA8C8A8)
                              ],
                            ),
                          ),
                          child: Stack(
                            children: [
                              CustomPaint(
                                size: const Size(double.infinity, 100),
                                painter: _GridPainter(),
                              ),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('📍',
                                        style: TextStyle(fontSize: 28)),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.85),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.open_in_new,
                                              size: 12,
                                              color: Color(0xFF3D5A3E)),
                                          const SizedBox(width: 4),
                                          const Text(
                                            'Buka di Maps',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF3D5A3E),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 14, color: Color(0xFF7B9E80)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Lat: ${post.latitude?.toStringAsFixed(4) ?? '-'}, Lng: ${post.longitude?.toStringAsFixed(4) ?? '-'}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF3D5A3E),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        post.latitude != null && post.longitude != null
                            ? '${post.latitude!.toStringAsFixed(6)}, ${post.longitude!.toStringAsFixed(6)}'
                            : '-',
                        style: const TextStyle(
                            fontSize: 10, color: Color(0xFFAAAAAA)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                _sectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _sectionLabel('JURNAL PERTUMBUHAN'),
                          Text(
                            post.createdAt != null
                              ? DateFormat('d MMM y').format(post.createdAt!.toDate())
                              : '-',
                            style: const TextStyle(
                                fontSize: 10, color: Color(0xFFAAAAAA)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      StreamBuilder<List<Growth>>(
                        stream: PostService.getGrowth(post.id!),
                        builder: (_, snapshot) {
                          final logs = snapshot.data ?? [];
                          return Column(
                            children: [
                              _logItem(
                                date: DateFormat(
                                  'd MMM y',
                                ).format(
                                  post.createdAt!.toDate(),
                                ),
                                text: '🌱 Tanaman pertama kali didokumentasikan.',
                                isLast: logs.isEmpty,
                              ),
                              ...logs.asMap().entries.map(
                                (entry) {
                                  final index = entry.key;
                                  final log = entry.value;
                                  return GestureDetector(
                                    onTap: () {
                                      _pageController.animateToPage(
                                        index + 1,
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        curve: Curves.easeInOut,
                                      );
                                    },

                                    child: _logItem(
                                      date: log.createdAt == null
                                        ? '-'
                                        : DateFormat('d MMM y').format(log.createdAt!.toDate()),
                                      text: log.note,
                                      isLast: index == logs.length - 1,
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2D4A2E), Color(0xFF4A7A4D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Text('🌿', style: TextStyle(fontSize: 72)),
      ),
    );
  }

  Widget _infoChip({
    required String emoji,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8, offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 8, letterSpacing: 0.8,
                color: Color(0xFFAAAAAA), fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 11, color: Color(0xFF1E2B1F),
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: child,
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 10, letterSpacing: 2,
        color: Color(0xFF6B4F3A), fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _logItem({
    required String date,
    required String text,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 10, height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFF3D5A3E),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: const Color(0xFF3D5A3E).withOpacity(0.2),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: const TextStyle(
                        fontSize: 10, color: Color(0xFF7B9E80),
                        letterSpacing: 0.3),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    text,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF555555), height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}
