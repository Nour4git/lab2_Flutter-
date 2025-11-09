import 'package:flutter/material.dart';
import '../services/note_service.dart';

class EditNoteModal extends StatefulWidget {
  final dynamic note;
  final Function(dynamic) onNoteUpdated;

  const EditNoteModal({
    Key? key,
    required this.note,
    required this.onNoteUpdated,
  }) : super(key: key);

  @override
  _EditNoteModalState createState() => _EditNoteModalState();
}

class _EditNoteModalState extends State<EditNoteModal> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  final _noteService = NoteService();
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.data['title']);
    _contentController = TextEditingController(text: widget.note.data['content']);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _resetForm() {
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

      final updateData = {
        'title': title,
        'content': content,
      };

      final updatedNote = await _noteService.updateNote(widget.note.$id, updateData);

      _resetForm();
      Navigator.pop(context);
      widget.onNoteUpdated(updatedNote);

    } catch (e) {
      print('Error updating note: $e');
      setState(() {
        _error = 'Erreur lors de la modification. Veuillez réessayer.';
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
                'Modifier la Note',
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
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text('Annuler'),
                  ),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleSave,
                    child: Text(_isLoading ? 'Sauvegarde...' : 'Sauvegarder'),
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