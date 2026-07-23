import 'package:flutter/material.dart';

import '../models/audio_item.dart';
import '../models/ruqyah.dart';
import '../models/ruqyah_track.dart';
import '../services/storage_service.dart';
import '../theme.dart';
import '../widgets/pill_button.dart';
import 'audio_library_screen.dart';

/// نموذج إنشاء/تعديل رقية، معروض كورقة سفلية (Bottom Sheet): اسم،
/// واختيار السور من المكتبة مع تكرار كل سورة عبر عدّاد يظهر بمجرد
/// تحديد مربع الاختيار الخاص بها.
class RuqyahEditorSheet extends StatefulWidget {
  final Ruqyah? existing;
  const RuqyahEditorSheet({super.key, this.existing});

  @override
  State<RuqyahEditorSheet> createState() => _RuqyahEditorSheetState();
}

class _SelectableAudio {
  final AudioItem audio;
  bool selected;
  int repeatCount;
  _SelectableAudio({required this.audio, this.selected = false, this.repeatCount = 7});
}

class _RuqyahEditorSheetState extends State<RuqyahEditorSheet> {
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

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
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
    final maxHeight = MediaQuery.of(context).size.height * 0.9;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Container(
          decoration: const BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppTheme.softGreenBorder,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        isEditing ? 'تعديل رقية' : 'رقية جديدة',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryGreenDark,
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Text('اسم الرقية', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _titleController,
                        textDirection: TextDirection.rtl,
                        style: Theme.of(context).textTheme.bodyLarge,
                        decoration: const InputDecoration(hintText: 'مثال: رقية النوم'),
                      ),
                      const SizedBox(height: 22),
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Text('اختيار السور والتكرار',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      const SizedBox(height: 10),
                      if (_items.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.softGreen,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'لا توجد سور في المكتبة بعد',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 12),
                              PillButton(
                                label: 'الذهاب إلى مكتبة السور',
                                background: AppTheme.primaryGreen,
                                foreground: Colors.white,
                                onPressed: _openLibraryThenReload,
                              ),
                            ],
                          ),
                        )
                      else
                        ..._items.map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _SelectableAudioRow(
                                item: item,
                                onToggle: () => setState(() => item.selected = !item.selected),
                                onRepeatChanged: (v) => setState(() => item.repeatCount = v),
                              ),
                            )),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          PillButton(
                            label: 'إلغاء',
                            background: AppTheme.softGreen,
                            foreground: AppTheme.primaryGreen,
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: PillButton(
                              label: 'حفظ',
                              background: AppTheme.primaryGreen,
                              foreground: Colors.white,
                              onPressed: _save,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// صف اختيار سورة واحد: يظهر عدّاد التكرار أسفله بمجرد التحديد.
class _SelectableAudioRow extends StatelessWidget {
  final _SelectableAudio item;
  final VoidCallback onToggle;
  final ValueChanged<int> onRepeatChanged;

  const _SelectableAudioRow({
    required this.item,
    required this.onToggle,
    required this.onRepeatChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = item.selected;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: AppTheme.softGreen,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? AppTheme.primaryGreen : Colors.transparent,
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  _CheckSquare(checked: selected),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.audio.title,
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (selected)
            Padding(
              padding: const EdgeInsets.only(bottom: 12, top: 4),
              child: Row(
                children: [
                  Text('التكرار', style: Theme.of(context).textTheme.bodyMedium),
                  const Spacer(),
                  _StepCircle(
                    icon: Icons.remove,
                    onTap: item.repeatCount > 1 ? () => onRepeatChanged(item.repeatCount - 1) : null,
                  ),
                  Container(
                    width: 52,
                    height: 44,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.softGreenBorder),
                    ),
                    child: Text(
                      '${item.repeatCount}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  _StepCircle(
                    icon: Icons.add,
                    onTap: () => onRepeatChanged(item.repeatCount + 1),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CheckSquare extends StatelessWidget {
  final bool checked;
  const _CheckSquare({required this.checked});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: checked ? AppTheme.primaryGreen : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: checked ? AppTheme.primaryGreen : AppTheme.softGreenBorder,
          width: 1.5,
        ),
      ),
      child: checked ? const Icon(Icons.check, size: 18, color: Colors.white) : null,
    );
  }
}

class _StepCircle extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _StepCircle({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return SizedBox(
      width: 40,
      height: 40,
      child: Material(
        color: enabled ? AppTheme.softGreen : AppTheme.softGreen.withOpacity(0.5),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Icon(
            icon,
            size: 20,
            color: enabled ? AppTheme.primaryGreen : AppTheme.textMuted,
          ),
        ),
      ),
    );
  }
}
