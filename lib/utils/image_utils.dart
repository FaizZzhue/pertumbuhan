import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImageUtils {
  static Future<String> fileToBase64(File file) async {
    // Baca raw bytes dari file
    Uint8List bytes = await file.readAsBytes();

    // Firestore max 1 MB per document, kita batasi image base64 < 700 KB
    // Jika bytes asli sudah kecil, langsung encode
    if (bytes.length <= 500000) {
      return base64Encode(bytes);
    }

    // Jika terlalu besar, resize dengan cara decode → encode ulang
    // menggunakan Flutter's built-in image codec untuk compress
    final codec = await instantiateImageCodec(bytes, targetWidth: 800); // max lebar 800px
    final frame  = await codec.getNextFrame();
    final image  = frame.image;
    final byteData = await image.toByteData(format: ImageByteFormat.png);

    if (byteData == null) {
      // Fallback: encode apa adanya tapi warning ukuran besar
      debugPrint('[ImageUtils] WARNING: byteData null, encode raw bytes');
      return base64Encode(bytes);
    }

    final compressedBytes = byteData.buffer.asUint8List();
    debugPrint('[ImageUtils] Compressed: ${bytes.length} → ${compressedBytes.length} bytes');
    return base64Encode(compressedBytes);
  }

  // ─────────────────────────────────────────────────────
  // DECODE — Bersihkan string lalu decode ke Uint8List
  // Ini fix untuk bug gambar tidak muncul
  // ─────────────────────────────────────────────────────
  static Uint8List? safeBase64Decode(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;

    try {
      // 1. Hapus data URI prefix (data:image/jpeg;base64, dst)
      String cleaned = raw;
      if (cleaned.contains(',')) {
        cleaned = cleaned.substring(cleaned.indexOf(',') + 1);
      }

      // 2. Hapus whitespace, newline, carriage return
      cleaned = cleaned
          .replaceAll('\n', '')
          .replaceAll('\r', '')
          .replaceAll(' ', '')
          .trim();

      // 3. Pastikan panjang string kelipatan 4 (syarat base64 valid)
      //    Tambah padding '=' jika perlu
      final int remainder = cleaned.length % 4;
      if (remainder == 2) {
        cleaned += '==';
      } else if (remainder == 3) {
        cleaned += '=';
      }

      final bytes = base64Decode(cleaned);

      // 4. Validasi minimal ukuran — gambar valid minimal 100 bytes
      if (bytes.length < 100) {
        debugPrint('[ImageUtils] WARN: decoded bytes too small (${bytes.length})');
        return null;
      }

      return bytes;
    } catch (e) {
      debugPrint('[ImageUtils] DECODE ERROR: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────────────
  // WIDGET — Image.memory yang aman dengan fallback
  // ─────────────────────────────────────────────────────
  static Widget safeBase64Image({
    required String?    base64Str,
    required Widget     placeholder,
    double?             width,
    double?             height,
    BoxFit              fit = BoxFit.cover,
  }) {
    final bytes = safeBase64Decode(base64Str);

    if (bytes == null) return placeholder;

    return Image.memory(
      bytes,
      width:   width,
      height:  height,
      fit:     fit,
      // gotoframe: key buat paksa rebuild saat base64Str berubah
      key: ValueKey(base64Str.hashCode),
      errorBuilder: (_, error, __) {
        debugPrint('[ImageUtils] Image.memory error: $error');
        return placeholder;
      },
    );
  }
}
