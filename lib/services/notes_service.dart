import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note.dart';

class NotesService {
  final CollectionReference notesCollection = FirebaseFirestore.instance.collection('notes');

  Stream<List<Note>> getNotes(String userId) {
    return notesCollection
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Note.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Future<void> addNote(Note note) async {
    await notesCollection.add(note.toMap());
  }

  Future<void> updateNote(Note note) async {
    await notesCollection.doc(note.id).update(note.toMap());
  }

  Future<void> deleteNote(String noteId) async {
    await notesCollection.doc(noteId).delete();
  }
} 