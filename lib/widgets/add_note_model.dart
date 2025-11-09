import 'package:flutter/material.dart';
import '../services/note_service.dart';

class AddNoteModal extends StatefulWidget {
  final Function(dynamic) onNoteAdded;

  const AddNoteModal({
    Key? key,
    required this.onNoteAdded,
  }) : super(key: key);

  @override
  _AddNoteModalState createState() => _AddNoteModalState();
}

class _AddNoteModalState extends State<AddNoteModal> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _noteService = NoteService();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _titleController.clear();
    _contentController.clear();
    setState(() {
      _error = null;
    });
  }

  Future<void> _handleSave() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      setState(() {
        _error = 'Veuillez remplir le titre et le contenu';
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final noteData = {
        'title': title,
        'content': content,
      };

      final newNote = await _noteService.createNote(noteData);

      _resetForm();
      Navigator.pop(context);
      widget.onNoteAdded(newNote);

    } catch (e) {
      print('Error creating note: $e');
      setState(() {
        _error = 'Erreur lors de la sauvegarde. Veuillez réessayer.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Nouvelle Note',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),

              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),

              TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Contenu',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () {
                      _resetForm();
                      Navigator.pop(context);
                    },
                    child: const Text('Annuler'),
                  ),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleSave,
                    child: Text(_isLoading ? 'Création...' : 'Créer'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}