import 'package:flutter/material.dart';

import '../models/audio_item.dart';
import '../models/ruqyah.dart';
import '../models/ruqyah_track.dart';
import '../services/storage_service.dart';
import '../theme.dart';
import 'audio_library_screen.dart';

/// نموذج إنشاء/تعديل رقية: اختيار اسم، وتحديد السور المطلوبة من
/// المكتبة مع عدد تكرار كل سورة، ثم الحفظ.
class RuqyahEditorScreen extends StatefulWidget {
  final Ruqyah? existing;
  const RuqyahEditorScreen({super.key, this.existing});

  @override
  State<RuqyahEditorScreen> createState() => _RuqyahEditorScreenState();
}

class _SelectableAudio {
  final AudioItem audio;
  bool selected;
  int repeatCount;
  _SelectableAudio({required this.audio, this.selected = false, this.repeatCount = 1});
}

class _RuqyahEditorScreenState extends State<RuqyahEditorScreen> {
  final storage = StorageService.instance;
  final TextEditingController _titleController = TextEditingController();
  List<_SelectableAudio> _items = [];
  bool get isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _loadItems();
    if (widget.existing != null) {
      _titleController.text = widget.existing!.title;
    }
  }

  void _loadItems() {
    final audios = storage.getAllAudios();
    final existingTracks = {
      for (final t in widget.existing?.tracks ?? <RuqyahTrack>[]) t.audioId: t
    };

    setState(() {
      _items = audios.map((a) {
        final existingTrack = existingTracks[a.id];
        return _SelectableAudio(
          audio: a,
          selected: existingTrack != null,
          repeatCount: existingTrack?.repeatCount ?? 7,
        );
      }).toList();
    });
  }

  Future<void> _openLibraryThenReload() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AudioLibraryScreen()),
    );
    _loadItems();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      _showMessage('يرجى إدخال اسم للرقية');
      return;
    }

    final selected = _items.where((i) => i.selected).toList();
    if (selected.isEmpty) {
      _showMessage('يرجى اختيار سورة واحدة على الأقل');
      return;
    }

    final tracks = selected
        .map((i) => RuqyahTrack(
              audioId: i.audio.id,
              audioTitle: i.audio.title,
              repeatCount: i.repeatCount,
            ))
        .toList();

    if (isEditing) {
      await storage.updateRuqyah(id: widget.existing!.id, title: title, tracks: tracks);
    } else {
      await storage.createRuqyah(title: title, tracks: tracks);
    }

    if (mounted) Navigator.pop(context);
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'تعديل رقية' : 'إنشاء رقية جديدة')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _titleController,
              textDirection: TextDirection.rtl,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: const InputDecoration(
                labelText: 'اسم الرقية',
                hintText: 'مثال: رقية الفاتحة والزلزلة',
              ),
            ),
          ),
          Expanded(
            child: _items.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'لا توجد سور في المكتبة بعد',
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _openLibraryThenReload,
                            icon: const Icon(Icons.library_music),
                            label: const Text('الذهاب إلى مكتبة السور'),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 90),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: Row(
                            children: [
                              Checkbox(
                                value: item.selected,
                                onChanged: (v) => setState(() => item.selected = v ?? false),
                              ),
                              Expanded(
                                child: Text(
                                  item.audio.title,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                              if (item.selected) _RepeatStepper(
                                value: item.repeatCount,
                                onChanged: (v) => setState(() => item.repeatCount = v),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _save,
        icon: const Icon(Icons.check),
        label: const Text('حفظ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryGreenDark,
      ),
    );
  }
}

/// عداد تكرار بسيط بأزرار كبيرة (+/-) مناسبة لكبار السن.
class _RepeatStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _RepeatStepper({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline, size: 28),
          onPressed: value > 1 ? () => onChanged(value - 1) : null,
        ),
        Text('$value', style: Theme.of(context).textTheme.titleLarge),
        IconButton(
          icon: const Icon(Icons.add_circle_outline, size: 28),
          onPressed: () => onChanged(value + 1),
        ),
      ],
    );
  }
}
