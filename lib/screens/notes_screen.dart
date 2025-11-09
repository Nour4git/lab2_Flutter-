import 'package:flutter/material.dart';
import '../services/note_service.dart';
import '../services/auth_service.dart';
import '../widgets/note_item.dart';
import '../widgets/add_note_model.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({Key? key}) : super(key: key);

  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final NoteService _noteService = NoteService();
  final AuthService _authService = AuthService();
  List<dynamic> _notes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final fetchedNotes = await _noteService.getNotes();
      setState(() {
        _notes = fetchedNotes;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching notes: $e');
      setState(() {
        _error = 'Failed to load notes. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _showAddNoteDialog() {
    showDialog(
      context: context,
      builder: (context) => AddNoteModal(
        onNoteAdded: _handleNoteAdded,
      ),
    );
  }

  void _handleNoteAdded(dynamic newNote) {
    setState(() {
      _notes = [newNote, ..._notes];
    });
  }

  void _handleNoteDeleted(String noteId) {
    setState(() {
      _notes = _notes.where((note) => note.$id != noteId).toList();
    });
  }

  void _handleNoteUpdated(dynamic updatedNote) {
    setState(() {
      _notes = _notes.map((note) =>
          note.$id == updatedNote.$id ? updatedNote : note).toList();
    });
  }

  Future<void> _logout() async {
    try {
      await _authService.logout();
      // Pour recharger l'application et revenir à l'écran de connexion
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Notes'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddNoteDialog,
        child: Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoading && _notes.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 20),
                      Text('Chargement des notes...'),
                    ],
                  ),
                ),
              ),

            if (_error != null && _notes.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      SizedBox(height: 20),
                      Text(
                        _error!,
                        style: TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _fetchNotes,
                        child: Text('Réessayer'),
                      ),
                    ],
                  ),
                ),
              ),

            if (!_isLoading || _notes.isNotEmpty)
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _fetchNotes,
                  child: _notes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.note_add, size: 64, color: Colors.grey),
                              SizedBox(height: 20),
                              Text(
                                'Aucune note pour le moment',
                                style: TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Appuyez sur le bouton + pour créer votre première note',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _notes.length,
                          itemBuilder: (context, index) {
                            return NoteItem(
                              note: _notes[index],
                              onNoteDeleted: _handleNoteDeleted,
                              onNoteUpdated: _handleNoteUpdated,
                            );
                          },
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}