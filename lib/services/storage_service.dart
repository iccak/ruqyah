import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../models/audio_item.dart';
import '../models/ruqyah.dart';
import '../models/ruqyah_track.dart';

/// طبقة الوصول للتخزين المحلي: يفتح صناديق Hive، وينسخ ملفات mp3
/// المستوردة إلى مجلد دائم داخل التطبيق، ويوفر عمليات CRUD بسيطة.
class StorageService {
  static const String audioBoxName = 'audio_items';
  static const String ruqyahBoxName = 'ruqyah_list';

  static final StorageService instance = StorageService._internal();
  StorageService._internal();

  late Box<AudioItem> _audioBox;
  late Box<Ruqyah> _ruqyahBox;
  final Uuid _uuid = const Uuid();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();

    Hive.registerAdapter(AudioItemAdapter());
    Hive.registerAdapter(RuqyahTrackAdapter());
    Hive.registerAdapter(RuqyahAdapter());

    _audioBox = await Hive.openBox<AudioItem>(audioBoxName);
    _ruqyahBox = await Hive.openBox<Ruqyah>(ruqyahBoxName);
    _initialized = true;
  }

  // ---------------- Audio Library ----------------

  List<AudioItem> getAllAudios() => _audioBox.values.toList()
    ..sort((a, b) => b.addedAt.compareTo(a.addedAt));

  AudioItem? getAudioById(String id) {
    try {
      return _audioBox.values.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  /// ينسخ ملف mp3 من المسار المؤقت الذي اختاره المستخدم إلى مجلد
  /// داخلي دائم لضمان توفره حتى بدون اتصال بالإنترنت لاحقًا.
  Future<AudioItem> importAudio({
    required String sourcePath,
    required String title,
  }) async {
    final appDir = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${appDir.path}/ruqyah_audio');
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }

    final id = _uuid.v4();
    final extension = sourcePath.split('.').last;
    final destPath = '${audioDir.path}/$id.$extension';

    final sourceFile = File(sourcePath);
    await sourceFile.copy(destPath);

    final item = AudioItem(
      id: id,
      title: title,
      filePath: destPath,
      addedAt: DateTime.now(),
    );

    await _audioBox.put(id, item);
    return item;
  }

  Future<void> deleteAudio(String id) async {
    final item = getAudioById(id);
    if (item != null) {
      final file = File(item.filePath);
      if (await file.exists()) {
        await file.delete();
      }
      await _audioBox.delete(id);
    }
    // إزالة أي إشارات لهذا المقطع من كل الرقيات المحفوظة
    for (final ruqyah in _ruqyahBox.values) {
      final originalLength = ruqyah.tracks.length;
      ruqyah.tracks.removeWhere((t) => t.audioId == id);
      if (ruqyah.tracks.length != originalLength) {
        await ruqyah.save();
      }
    }
  }

  // ---------------- Ruqyah Playlists ----------------

  List<Ruqyah> getAllRuqyahs() => _ruqyahBox.values.toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  Ruqyah? getRuqyahById(String id) {
    try {
      return _ruqyahBox.values.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Ruqyah> createRuqyah({
    required String title,
    required List<RuqyahTrack> tracks,
  }) async {
    final ruqyah = Ruqyah(
      id: _uuid.v4(),
      title: title,
      tracks: tracks,
      createdAt: DateTime.now(),
    );
    await _ruqyahBox.put(ruqyah.id, ruqyah);
    return ruqyah;
  }

  Future<void> updateRuqyah({
    required String id,
    required String title,
    required List<RuqyahTrack> tracks,
  }) async {
    final ruqyah = getRuqyahById(id);
    if (ruqyah == null) return;
    ruqyah.title = title;
    ruqyah.tracks = tracks;
    await ruqyah.save();
  }

  Future<void> deleteRuqyah(String id) async {
    await _ruqyahBox.delete(id);
  }
}
