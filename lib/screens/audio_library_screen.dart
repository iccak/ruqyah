import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../models/audio_item.dart';
import '../services/storage_service.dart';
import '../theme.dart';
import '../widgets/app_header.dart';
import '../widgets/pill_button.dart';

/// شاشة "مكتبة السور": استيراد ملفات mp3 من التخزين المحلي ونسخها
/// بشكل دائم داخل التطبيق، مع إمكانية معاينة كل مقطع وحذفه.
///
/// [embedded] يحدد ما إذا كانت الشاشة تُعرض كأحد تبويبات الشريط
/// السفلي (بدون زر رجوع) أو كشاشة مدفوعة (Navigator.push) من محرر
/// الرقية (مع زر رجوع دائري في الهيدر).
class AudioLibraryScreen extends StatefulWidget {
  final bool embedded;
  const AudioLibraryScreen({super.key, this.embedded = false});

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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

  String _formatFileSize(String path) {
    try {
      final bytes = File(path).lengthSync();
      final mb = bytes / (1024 * 1024);
      return '${mb.toStringAsFixed(2)} م.ب';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        AppHeader(
          title: 'مكتبة السور',
          subtitle: 'جميع السور محفوظة على جهازك',
          trailing: widget.embedded
              ? null
              : CircleIconButton(
                  icon: Icons.arrow_forward,
                  background: Colors.white,
                  foreground: AppTheme.primaryGreen,
                  onPressed: () => Navigator.pop(context),
                ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            children: [
              ElevatedButton.icon(
                onPressed: _importing ? null : _importAudio,
                icon: _importing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.add),
                label: const Text('إضافة سورة جديدة'),
              ),
              const SizedBox(height: 20),
              if (_audios.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.softGreenBorder, width: 1.5),
                  ),
                  child: Text(
                    'لم تتم إضافة أي سورة بعد',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ..._audios.map((item) {
                  final isPlaying = _playingId == item.id;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppTheme.softGreenBorder),
                      ),
                      child: Row(
                        children: [
                          CircleIconButton(
                            icon: Icons.delete_outline,
                            background: AppTheme.softPink,
                            foreground: AppTheme.danger,
                            onPressed: () => _confirmDelete(item),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  item.title,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 19),
                                  textAlign: TextAlign.right,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatFileSize(item.filePath),
                                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          CircleIconButton(
                            icon: isPlaying ? Icons.pause : Icons.play_arrow_rounded,
                            background: AppTheme.primaryGreen,
                            foreground: Colors.white,
                            size: 52,
                            onPressed: () => _togglePreview(item),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );

    if (widget.embedded) return content;

    return Scaffold(
      body: SafeArea(top: false, child: content),
    );
  }
}
