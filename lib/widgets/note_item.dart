import 'package:flutter/material.dart';
import '../services/note_service.dart';
import '../widgets/adit_note_model.dart';

class NoteItem extends StatefulWidget {
  final dynamic note;
  final Function(String)? onNoteDeleted;
  final Function(dynamic)? onNoteUpdated;

  const NoteItem({
    Key? key,
    required this.note,
    this.onNoteDeleted,
    this.onNoteUpdated,
  }) : super(key: key);

  @override
  _NoteItemState createState() => _NoteItemState();
}

class _NoteItemState extends State<NoteItem> {
  final NoteService _noteService = NoteService();
  bool _isDeleting = false;

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Date invalide';
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la note'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette note ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        setState(() {
          _isDeleting = true;
        });

        await _noteService.deleteNote(widget.note.$id);

        if (widget.onNoteDeleted != null) {
          widget.onNoteDeleted!(widget.note.$id);
        }
      } catch (e) {
        print('Error deleting note: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Échec de la suppression. Veuillez réessayer.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isDeleting = false;
          });
        }
      }
    }
  }

  void _showEditNoteDialog() {
    showDialog(
      context: context,
      builder: (context) => EditNoteModal(
        note: widget.note,
        onNoteUpdated: widget.onNoteUpdated!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.note.data['title'] as String? ?? 'Sans titre';
    final content = widget.note.data['content'] as String? ?? 'Pas de contenu';
    final updatedAt = widget.note.$updatedAt;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditNoteDialog();
                    } else if (value == 'delete') {
                      _handleDelete();
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Modifier'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text('Supprimer', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Dernière modification: ${_formatDate(updatedAt)}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(fontSize: 14),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (_isDeleting)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: LinearProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}