import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../models/audio_item.dart';
import '../services/storage_service.dart';
import '../theme.dart';

/// شاشة "السور": استيراد ملفات mp3 من التخزين المحلي ونسخها بشكل دائم
/// داخل التطبيق، مع إمكانية معاينة كل مقطع وحذفه.
class AudioLibraryScreen extends StatefulWidget {
  const AudioLibraryScreen({super.key});

  @override
  State<AudioLibraryScreen> createState() => _AudioLibraryScreenState();
}

class _AudioLibraryScreenState extends State<AudioLibraryScreen> {
  final storage = StorageService.instance;
  final AudioPlayer _previewPlayer = AudioPlayer();
  List<AudioItem> _audios = [];
  String? _playingId;
  bool _importing = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _audios = storage.getAllAudios();
    });
  }

  @override
  void dispose() {
    _previewPlayer.dispose();
    super.dispose();
  }

  Future<void> _importAudio() async {
    setState(() => _importing = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3'],
      );
      if (result == null || result.files.single.path == null) {
        return;
      }
      final path = result.files.single.path!;
      final defaultTitle = result.files.single.name.replaceAll('.mp3', '');

      if (!mounted) return;
      final title = await _askForTitle(defaultTitle);
      if (title == null || title.trim().isEmpty) return;

      await storage.importAudio(sourcePath: path, title: title.trim());
      _refresh();
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Future<String?> _askForTitle(String initial) async {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('اسم السورة/المقطع'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textDirection: TextDirection.rtl,
          decoration: const InputDecoration(hintText: 'مثال: سورة الفاتحة'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  Future<void> _togglePreview(AudioItem item) async {
    if (_playingId == item.id) {
      await _previewPlayer.stop();
      setState(() => _playingId = null);
      return;
    }
    try {
      await _previewPlayer.setFilePath(item.filePath);
      await _previewPlayer.play();
      setState(() => _playingId = item.id);
      _previewPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed && mounted) {
          setState(() => _playingId = null);
        }
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر تشغيل الملف')),
        );
      }
    }
  }

  Future<void> _confirmDelete(AudioItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف "${item.title}"؟ سيتم إزالته من أي رقية يستخدمه.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حذف', style: TextStyle(color: AppTheme.danger)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      if (_playingId == item.id) {
        await _previewPlayer.stop();
      }
      await storage.deleteAudio(item.id);
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('السور')),
      body: _audios.isEmpty
          ? Center(
              child: Text(
                'لم تتم إضافة أي سورة بعد',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 90, top: 8),
              itemCount: _audios.length,
              itemBuilder: (context, index) {
                final item = _audios[index];
                final isPlaying = _playingId == item.id;
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    title: Text(item.title, style: Theme.of(context).textTheme.bodyLarge),
                    leading: IconButton(
                      icon: Icon(
                        isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                        size: 36,
                        color: AppTheme.primaryGreen,
                      ),
                      onPressed: () => _togglePreview(item),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: AppTheme.danger, size: 28),
                      tooltip: 'حذف',
                      onPressed: () => _confirmDelete(item),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _importing ? null : _importAudio,
        icon: _importing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.upload_file),
        label: const Text(
          'إضافة سورة جديدة',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
