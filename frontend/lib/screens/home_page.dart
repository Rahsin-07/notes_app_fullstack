import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/api_service.dart';
import 'add_edit_note.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Note>> _notesFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _notesFuture = ApiService.getNotes();
  }

  Future<void> _refresh() async {
    setState(() => _load());
    await _notesFuture;
  }

  Widget _noteTile(Note note) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        title: Text(
          note.title,
          style: TextStyle(
            decoration: note.completed ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          note.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            decoration: note.completed ? TextDecoration.lineThrough : null,
          ),
        ),
        trailing: Wrap(
          spacing: 8,
          children: [
            // Toggle completed
            IconButton(
              tooltip: note.completed ? 'Mark as not done' : 'Mark as done',
              icon: Icon(note.completed ? Icons.check_circle : Icons.circle_outlined),
              onPressed: () async {
                try {
                  await ApiService.toggleCompleted(note);
                  _refresh();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
            ),
            // Edit
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final changed = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(builder: (_) => AddEditNotePage(note: note)),
                );
                if (changed == true) _refresh();
              },
            ),
            // Delete
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete note?'),
                    content: const Text('Are you sure you want to delete this note?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
                    ],
                  ),
                );
                if (ok == true) {
                  try {
                    await ApiService.deleteNote(note.id);
                    _refresh();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deleted')));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
            ),
          ],
        ),
        leading: CircleAvatar(
          child: Text('${note.id}'),
          backgroundColor: note.completed ? Colors.green.shade200 : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          )
        ],
      ),
      body: FutureBuilder<List<Note>>(
        future: _notesFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final notes = snap.data ?? [];
          if (notes.isEmpty) {
            return Center(child: Text('No notes yet. Tap + to add.'));
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              itemCount: notes.length,
              itemBuilder: (c, i) => _noteTile(notes[i]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => const AddEditNotePage()));
          if (added == true) _refresh();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
