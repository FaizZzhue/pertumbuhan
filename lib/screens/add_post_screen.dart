import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pertumbuhan/models/post.dart';
import 'package:pertumbuhan/services/post_service.dart';
import 'package:dotted_border/dotted_border.dart';


class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _sciCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();

  XFile? _imageFile;
  bool _loadingLocation = false;
  bool _saving = false;
  double? _latitude;
  double? _longitude;
  String _locationName = '';
  String _category = 'Pilih Kategori';
  List<String> get categories {
    return [
      'Tanaman Hias',
      'Tanaman Obat',
      'Tanaman Liar',
      'Sayuran',
      'Buah',
    ];
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF5F0E8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCCCCCC),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Pilih Sumber Foto',
                style: TextStyle(
                  fontSize: 15, fontStyle: FontStyle.italic,
                  color: Color(0xFF1E2B1F),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _imageSourceBtn(
                      icon: Icons.camera_alt_outlined,
                      label: 'Kamera',
                      onTap: () async {
                        Navigator.pop(context);
                        final file = await PostService.pickImage(ImageSource.camera);
                          if (file != null) {
                            setState(() => _imageFile = file);
                          }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _imageSourceBtn(
                      icon: Icons.photo_library_outlined,
                      label: 'Galeri',
                      onTap: () async {
                        Navigator.pop(context);
                        final image = await PostService.pickImage(ImageSource.gallery);
                        if (image != null) {
                          setState(() => _imageFile = image);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF5F0E8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        children: categories.map((cat) {
          return ListTile(
            title: Text(cat),
            onTap: () {
              setState(() => _category = cat);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _imageSourceBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF3D5A3E).withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: const Color(0xFF3D5A3E).withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF3D5A3E), size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF3D5A3E), fontSize: 12, fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _detectLocation() async {
    setState(() => _loadingLocation = true);

    try {
      final post = await PostService.getCurrentLocation();

      if (post == null) {
        _showSnack('Tidak bisa mendapatkan lokasi. Periksa izin GPS.');
        return;
      }

      setState(() {
        _latitude = post.latitude;
        _longitude = post.longitude;
        _locationName =
            "Lat: ${post.latitude}, Lng: ${post.longitude}";
      });
    } catch (e) {
      _showSnack('Gagal mendapatkan lokasi');
    } finally {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      _showSnack('Nama tanaman tidak boleh kosong');
      return;
    }
    if (_imageFile == null) {
      _showSnack('Pilih foto tanaman terlebih dahulu');
      return;
    }
    if (_latitude == null) {
      _showSnack('Deteksi lokasi terlebih dahulu');
      return;
    }
    if (_descCtrl.text.trim().isEmpty) {
      _showSnack('Deskripsi tidak boleh kosong');
      return;
    }

    setState(() => _saving = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final base64Image = await PostService.convertToBase64(_imageFile!);

      final post = Post(
        plantName: _nameCtrl.text.trim(),
        scientificName: _sciCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        category: 'tanaman', 
        imageBase64: base64Image, 
        latitude: _latitude!,
        longitude: _longitude!,
        userId: user.uid,
        userFullName: user.displayName ?? 'Pengguna',
      );

      await PostService.addPost(post);
      if (mounted) {
        Navigator.pop(context);
        _showSnack('Tanaman berhasil ditambahkan 🌿');
      }
    } catch (e) {
      _showSnack('Gagal menyimpan: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF3D5A3E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFF1E2B1F),
            foregroundColor: const Color(0xFFF5F0E8),
            pinned: true,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back_ios_new, size: 16),
              ),
            ),
            title: const Text(
              'Tanaman Baru',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 18,
                color: Color(0xFFF5F0E8),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                GestureDetector(
                  onTap: _showImagePicker,
                  child: _imageFile != null
                      ? Container(
                          height: 180,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                FutureBuilder(
                                  future: _imageFile!.readAsBytes(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return const Center(child: CircularProgressIndicator());
                                    }
                                    return Image.memory(
                                      snapshot.data!,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        )
                      : DottedBorder(
                          color: const Color(0xFF7B9E80),
                          strokeWidth: 2,
                          dashPattern: const [6, 3],
                          borderType: BorderType.RRect,
                          radius: const Radius.circular(16),
                          child: Container(
                            width: double.infinity,
                            height: 180,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8E0D0),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.camera_alt_outlined,
                                    size: 36, color: Color(0xFF7B9E80)),
                                SizedBox(height: 8),
                                Text(
                                  'AMBIL FOTO TANAMAN',
                                  style: TextStyle(
                                    fontSize: 11,
                                    letterSpacing: 1.5,
                                    color: Color(0xFF7B9E80),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Kamera atau Galeri',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF7B9E80),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),

                const SizedBox(height: 16),

                _buildLabel('NAMA TANAMAN'),
                const SizedBox(height: 6),
                _buildTextField(
                  controller: _nameCtrl,
                  hint: 'contoh: Monstera Deliciosa',
                  icon: Icons.local_florist_outlined,
                ),

                const SizedBox(height: 14),

                // _buildLabel('NAMA ILMIAH (OPSIONAL)'),
                // const SizedBox(height: 6),
                // _buildTextField(
                //   controller: _sciCtrl,
                //   hint: 'contoh: Monstera deliciosa',
                //   icon: Icons.science_outlined,
                // ),

                _buildLabel('KATEGORI'),
                const SizedBox(height: 6),

                GestureDetector(
                  onTap: _showCategoryPicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.category_outlined,
                            color: Color(0xFF3D5A3E), size: 18),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _category,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF1E2B1F),
                            ),
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down,
                            color: Color(0xFF3D5A3E)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                _buildLabel('LOKASI TANAM'),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: _loadingLocation ? null : _detectLocation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 26, height: 26,
                          child: _loadingLocation
                              ? const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF3D5A3E),
                                  ),
                                )
                              : const Icon(Icons.my_location,
                                  color: Color(0xFF3D5A3E), size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _latitude != null ? _locationName : 'Ketuk untuk deteksi lokasi',
                            style: TextStyle(
                              fontSize: 13,
                              color: _latitude != null
                                  ? const Color(0xFF1E2B1F)
                                  : const Color(0xFFAAAAAA),
                            ),
                          ),
                        ),
                        if (_latitude != null)
                          const Icon(Icons.check_circle,
                              color: Color(0xFF3D5A3E), size: 18),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                _buildLabel('DESKRIPSI & CATATAN'),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _descCtrl,
                    maxLines: 4,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF1E2B1F)),
                    decoration: InputDecoration(
                      hintText:
                          'Ceritakan asal tanaman, kondisi awal, cara perawatan...',
                      hintStyle: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFFAAAAAA)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3D5A3E),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          const Color(0xFF3D5A3E).withOpacity(0.5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: _saving
                        ? const SizedBox(
                            height: 20, width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('🌱', style: TextStyle(fontSize: 18)),
                              SizedBox(width: 8),
                              Text(
                                'Simpan Tanaman',
                                style: TextStyle(
                                  fontSize: 15, fontStyle: FontStyle.italic,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        letterSpacing: 1.8,
        color: Color(0xFF6B4F3A),
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 13, color: Color(0xFF1E2B1F)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 12, color: Color(0xFFAAAAAA)),
          prefixIcon: Icon(icon, color: const Color(0xFF7B9E80), size: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 14),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _sciCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }
}
