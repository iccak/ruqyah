import 'package:flutter/material.dart';

import '../models/ruqyah.dart';
import '../services/storage_service.dart';
import '../theme.dart';
import '../widgets/app_header.dart';
import '../widgets/pill_button.dart';
import 'ruqyah_editor_screen.dart';
import 'player_screen.dart';

/// الشاشة الرئيسية (الرئيسية): تعرض كل الرقيات المخصصة التي أنشأها
/// المستخدم مع أزرار تشغيل/تعديل/حذف لكل رقية، وشريط بحث لتصفيتها.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final storage = StorageService.instance;
  final TextEditingController _searchController = TextEditingController();
  List<Ruqyah> _all = [];
  List<Ruqyah> _filtered = [];

  @override
  void initState() {
    super.initState();
    _refresh();
    _searchController.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refresh() {
    _all = storage.getAllRuqyahs();
    _applyFilter();
  }

  void _applyFilter() {
    final query = _searchController.text.trim();
    setState(() {
      if (query.isEmpty) {
        _filtered = _all;
      } else {
        _filtered = _all.where((r) => r.title.contains(query)).toList();
      }
    });
  }

  Future<void> _confirmDelete(Ruqyah ruqyah) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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

  Future<void> _openCreateEditor({Ruqyah? existing}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RuqyahEditorSheet(existing: existing),
    );
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AppHeader(
          title: 'رقيتي',
          subtitle: 'اقرأ ورقِ نفسك بكل هدوء',
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              children: [
                ElevatedButton.icon(
                  onPressed: () => _openCreateEditor(),
                  icon: const Icon(Icons.add),
                  label: const Text('إنشاء رقية جديدة'),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _searchController,
                  textDirection: TextDirection.rtl,
                  decoration: const InputDecoration(
                    hintText: 'ابحث في السور والآيات...',
                    suffixIcon: Padding(
                      padding: EdgeInsets.only(left: 12),
                      child: Icon(Icons.search, color: AppTheme.primaryGreen),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_filtered.isEmpty)
                  _EmptyState(hasQuery: _searchController.text.trim().isNotEmpty)
                else
                  ..._filtered.map(
                    (ruqyah) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _RuqyahCard(
                        ruqyah: ruqyah,
                        onPlay: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => PlayerScreen(ruqyah: ruqyah)),
                          );
                        },
                        onEdit: () => _openCreateEditor(existing: ruqyah),
                        onDelete: () => _confirmDelete(ruqyah),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasQuery;
  const _EmptyState({required this.hasQuery});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.softGreenBorder,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Text(
            hasQuery ? 'لا توجد نتائج مطابقة' : 'لا توجد رقية محفوظة بعد',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            hasQuery
                ? 'جرّب كلمة بحث أخرى'
                : 'اضغط "إنشاء رقية جديدة" لبدء أول قائمة.',
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ],
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
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEDEAE0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(ruqyah.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            ruqyah.summary,
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 15),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: PillButton(
                  label: 'تعديل',
                  icon: Icons.edit_outlined,
                  background: AppTheme.softGreen,
                  foreground: AppTheme.primaryGreen,
                  onPressed: onEdit,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PillButton(
                  label: 'تشغيل',
                  icon: Icons.play_arrow_rounded,
                  background: AppTheme.primaryGreen,
                  foreground: Colors.white,
                  onPressed: onPlay,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: PillButton(
              label: 'حذف',
              icon: Icons.delete_outline,
              background: AppTheme.softPink,
              foreground: AppTheme.danger,
              onPressed: onDelete,
            ),
          ),
        ],
      ),
    );
  }
}
