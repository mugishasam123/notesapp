import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/notes_service.dart';

class NotesProvider extends ChangeNotifier {
  final NotesService _notesService = NotesService();
  List<Note> _notes = [];
  bool _isLoading = false;
  String? _error;

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void loadNotes(String userId) {
    _isLoading = true;
    notifyListeners();
    _notesService.getNotes(userId).listen((notesList) {
      _notes = notesList;
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addNote(Note note) async {
    await _notesService.addNote(note);
  }

  Future<void> updateNote(Note note) async {
    await _notesService.updateNote(note);
  }

  Future<void> deleteNote(String noteId) async {
    await _notesService.deleteNote(noteId);
  }
} 