import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'appwrite_config.dart';
import 'auth_service.dart';

class NoteService {
  final Client _client = getClient();
  late final Databases _databases;
  final AuthService _authService = AuthService();

  NoteService() {
    _databases = Databases(_client);
  }

  Future<List<dynamic>> getNotes() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user == null) {
        throw Exception('User not authenticated');
      }

      List<String> queries = [];
      queries.add(Query.equal('userId', user.$id));
      queries.add(Query.orderDesc('\$createdAt'));

      final response = await _databases.listDocuments(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        collectionId: dotenv.env['APPWRITE_COLLECTION_ID']!,
        queries: queries,
      );

      print('✅ Successfully fetched ${response.documents.length} notes');
      return response.documents;
    } catch (e) {
      print('❌ Error getting notes: $e');
      throw e;
    }
  }

  Future<dynamic> createNote(Map<String, dynamic> data) async {
    try {
      final user = await _authService.getCurrentUser();
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final noteData = {
        'title': data['title'],
        'content': data['content'],
        'userId': user.$id,
      };

      final response = await _databases.createDocument(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        collectionId: dotenv.env['APPWRITE_COLLECTION_ID']!,
        documentId: ID.unique(),
        data: noteData,
      );

      print('✅ Note created successfully: ${response.$id}');
      return response;
    } catch (e) {
      print('❌ Error creating note: $e');
      throw e;
    }
  }

  Future<bool> deleteNote(String noteId) async {
    try {
      final user = await _authService.getCurrentUser();
      if (user == null) {
        throw Exception('User not authenticated');
      }

      await _databases.deleteDocument(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        collectionId: dotenv.env['APPWRITE_COLLECTION_ID']!,
        documentId: noteId,
      );

      print('✅ Note deleted successfully');
      return true;
    } catch (e) {
      print('❌ Error deleting note: $e');
      throw e;
    }
  }

  Future<dynamic> updateNote(String noteId, Map<String, dynamic> data) async {
    try {
      final user = await _authService.getCurrentUser();
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final noteData = {
        'title': data['title'],
        'content': data['content'],
      };

      final response = await _databases.updateDocument(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        collectionId: dotenv.env['APPWRITE_COLLECTION_ID']!,
        documentId: noteId,
        data: noteData,
      );

      print('✅ Note updated successfully');
      return response;
    } catch (e) {
      print('❌ Error updating note: $e');
      throw e;
    }
  }
}