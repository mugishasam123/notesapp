import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final DateTime timestamp;
  final String userId;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.timestamp,
    required this.userId,
  });

  factory Note.fromMap(Map<String, dynamic> data, String documentId) {
    return Note(
      id: documentId,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'timestamp': timestamp,
      'userId': userId,
    };
  }
} 