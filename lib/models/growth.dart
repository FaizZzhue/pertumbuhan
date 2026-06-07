import 'package:cloud_firestore/cloud_firestore.dart';

class Growth {
  String? id;
  String postId;
  String imageBase64;
  String note;
  Timestamp? createdAt;

  Growth({
    this.id,
    required this.postId,
    required this.imageBase64,
    required this.note,
    this.createdAt,
  });

  factory Growth.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Growth(
      id: doc.id,
      postId: data['post_id'],
      imageBase64: data['image_base_64'],
      note: data['note'],
      createdAt: data['created_at'],
    );
  }
}