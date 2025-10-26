import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/note.dart';

class ApiService {
  // If running in browser (flutter web) use localhost.
  // For Android emulator use 10.0.2.2
  // For real device replace with machine IP (e.g. http://192.168.1.100:3000)
  static String get baseHost {
    if (kIsWeb) {
      return 'http://localhost:3000';
    } else {
      // default assume testing on Android emulator
      return 'http://10.0.2.2:3000';
    }
  }

  static String get baseUrl => '$baseHost/notes';

  static Future<List<Note>> getNotes() async {
    final resp = await http.get(Uri.parse(baseUrl));
    if (resp.statusCode == 200) {
      final List<dynamic> arr = jsonDecode(resp.body);
      return arr.map((e) => Note.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load notes (${resp.statusCode})');
    }
  }

  static Future<Note> createNote(String title, String description) async {
    final resp = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': title, 'description': description}),
    );
    if (resp.statusCode == 201) {
      return Note.fromJson(jsonDecode(resp.body));
    } else {
      throw Exception('Failed to create note (${resp.statusCode}) ${resp.body}');
    }
  }

  static Future<Note> updateNote(Note note) async {
    final resp = await http.put(
      Uri.parse('$baseUrl/${note.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(note.toJson()),
    );
    if (resp.statusCode == 200) {
      return Note.fromJson(jsonDecode(resp.body));
    } else {
      throw Exception('Failed to update note (${resp.statusCode}) ${resp.body}');
    }
  }

  static Future<void> deleteNote(int id) async {
    final resp = await http.delete(Uri.parse('$baseUrl/$id'));
    if (resp.statusCode != 200) {
      throw Exception('Failed to delete note (${resp.statusCode})');
    }
  }

  static Future<Note> toggleCompleted(Note note) async {
    final updated = Note(
      id: note.id,
      title: note.title,
      description: note.description,
      completed: !note.completed,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
    );
    return updateNote(updated);
  }
}
