import 'package:flutter/material.dart';

import '../models/ruqyah.dart';
import '../services/storage_service.dart';
import '../theme.dart';
import 'ruqyah_editor_screen.dart';
import 'player_screen.dart';
import 'audio_library_screen.dart';

/// الشاشة الرئيسية (الرئيسية): تعرض كل الرقيات المخصصة التي أنشأها
/// المستخدم مع أزرار تشغيل/تعديل/حذف لكل رقية.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final storage = StorageService.instance;
  List<Ruqyah> _ruqyahs = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _ruqyahs = storage.getAllRuqyahs();
    });
  }

  Future<void> _confirmDelete(Ruqyah ruqyah) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف "${ruqyah.title}"؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حذف', style: TextStyle(color: AppTheme.danger)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await storage.deleteRuqyah(ruqyah.id);
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الرقية الشرعية'),
        actions: [
          IconButton(
            icon: const Icon(Icons.library_music, size: 28),
            tooltip: 'مكتبة السور',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AudioLibraryScreen()),
              );
              _refresh();
            },
          ),
        ],
      ),
      body: _ruqyahs.isEmpty
          ? _EmptyState(onCreate: _openCreateEditor)
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 90),
              itemCount: _ruqyahs.length,
              itemBuilder: (context, index) {
                final ruqyah = _ruqyahs[index];
                return _RuqyahCard(
                  ruqyah: ruqyah,
                  onPlay: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlayerScreen(ruqyah: ruqyah),
                      ),
                    );
                  },
                  onEdit: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RuqyahEditorScreen(existing: ruqyah),
                      ),
                    );
                    _refresh();
                  },
                  onDelete: () => _confirmDelete(ruqyah),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateEditor,
        icon: const Icon(Icons.add),
        label: const Text(
          'إنشاء رقية جديدة',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<void> _openCreateEditor() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RuqyahEditorScreen()),
    );
    _refresh();
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreate;
  const _EmptyState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.menu_book, size: 72, color: AppTheme.primaryGreen),
            const SizedBox(height: 16),
            Text(
              'لا توجد رقيات بعد',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'اضغط على "إنشاء رقية جديدة" للبدء',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('إنشاء رقية جديدة'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RuqyahCard extends StatelessWidget {
  final Ruqyah ruqyah;
  final VoidCallback onPlay;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RuqyahCard({
    required this.ruqyah,
    required this.onPlay,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ruqyah.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              ruqyah.summary,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onPlay,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('تشغيل'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, color: AppTheme.primaryGreen, size: 28),
                  tooltip: 'تعديل',
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, color: AppTheme.danger, size: 28),
                  tooltip: 'حذف',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
