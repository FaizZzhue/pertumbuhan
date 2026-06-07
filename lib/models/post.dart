import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  String? id;
  String? imageBase64;
  String plantName;
  String scientificName;
  final String category;
  final String description;
  bool isFavorite;
  Timestamp? createdAt;
  Timestamp? updatedAt;
  double? latitude;
  double? longitude;
  String? userId;
  String? userFullName;

  Post({
    this.id,
    this.imageBase64,
    required this.plantName,
    required this.scientificName,
    required this.description,
    required this.category,
    this.isFavorite = false,
    this.createdAt,
    this.updatedAt,
    this.latitude,
    this.longitude,
    this.userId,
    this.userFullName
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      plantName: data['plantName'],
      scientificName: data['scientificName'],
      imageBase64: data['image_base_64'],
      description: data['description'],
      category: data['category'],
      isFavorite: data['is_favorite'] ?? false,
      createdAt: data['created_at'] as Timestamp,
      updatedAt: data['updated_at'] as Timestamp,
      latitude: data['latitude'],
      longitude: data['longitude'],
      userId: data['user_id'],
      userFullName: data['user_full_name']
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'image_base_64': imageBase64,
      'plantName': plantName,
      'scientificName': scientificName,
      'description': description,
      'category': category,
      'is_favorite': isFavorite,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'latitude': latitude,
      'longitude': longitude,
      'user_id': userId,
      'user_full_name': userFullName
    };
  }
}