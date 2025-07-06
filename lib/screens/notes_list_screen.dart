import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notes_provider.dart';
import '../providers/auth_provider.dart';
import '../models/note.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user != null) {
        Provider.of<NotesProvider>(context, listen: false).loadNotes(user.uid);
      }
      _initialized = true;
    }
  }

  void _showNoteDialog({Note? note}) {
    final titleController = TextEditingController(text: note?.title ?? '');
    final contentController = TextEditingController(text: note?.content ?? '');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(note == null ? 'Add Note' : 'Edit Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Content'),
                minLines: 2,
                maxLines: 5,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final user = Provider.of<AuthProvider>(context, listen: false).user;
                if (user == null) return;
                if (note == null) {
                  await Provider.of<NotesProvider>(context, listen: false).addNote(
                    Note(
                      id: '',
                      title: titleController.text,
                      content: contentController.text,
                      timestamp: DateTime.now(),
                      userId: user.uid,
                    ),
                  );
                } else {
                  await Provider.of<NotesProvider>(context, listen: false).updateNote(
                    Note(
                      id: note.id,
                      title: titleController.text,
                      content: contentController.text,
                      timestamp: DateTime.now(),
                      userId: user.uid,
                    ),
                  );
                }
                Navigator.pop(context);
              },
              child: Text(note == null ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final notesProvider = Provider.of<NotesProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Notes'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: notesProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notesProvider.error != null
              ? Center(child: Text('Error: \\${notesProvider.error}'))
              : notesProvider.notes.isEmpty
                  ? const Center(child: Text('No notes yet.'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: notesProvider.notes.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final note = notesProvider.notes[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFF3EFFF),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      note.title,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    if (note.content.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4.0),
                                        child: Text(
                                          note.content,
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  await notesProvider.deleteNote(note.id);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showNoteDialog(note: note),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoteDialog(),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
} 