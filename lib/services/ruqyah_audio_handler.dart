import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

import '../models/ruqyah.dart';

/// وحدة تمثل "تشغيلة" واحدة داخل القائمة الموسعة: مقطع صوتي معيّن
/// مع رقم التكرار الحالي والعدد الكلي المطلوب لهذا المقطع.
class _ExpandedTrack {
  final String audioId;
  final String title;
  final String filePath;
  final int repeatIndex; // 1-based
  final int repeatTotal;

  _ExpandedTrack({
    required this.audioId,
    required this.title,
    required this.filePath,
    required this.repeatIndex,
    required this.repeatTotal,
  });
}

/// معالج الصوت الذي يعمل في الخلفية (Background Service) ويدير:
/// - بناء قائمة تشغيل موسعة تكرر كل مقطع العدد المطلوب من المرات
///   بشكل متتابع قبل الانتقال للمقطع التالي.
/// - تحديث الإشعار الدائم (Foreground Notification) وشاشة القفل
///   بحالة التشغيل باللغة العربية، مثل: "سورة الفاتحة - تكرار 3 من 7".
/// - الاستمرار بالتشغيل عند إغلاق الشاشة أو قفلها.
class RuqyahAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  List<_ExpandedTrack> _expanded = [];

  RuqyahAudioHandler() {
    _listenForCurrentSongIndexChanges();
    _listenForPlaybackEvents();
  }

  /// يبني ويشغّل رقية كاملة بناءً على قائمة المقاطع وتكرارها.
  Future<void> loadRuqyah(Ruqyah ruqyah, Map<String, String> filePaths) async {
    _expanded = [];
    final audioSources = <AudioSource>[];

    for (final track in ruqyah.tracks) {
      final path = filePaths[track.audioId];
      if (path == null) continue;
      for (int i = 1; i <= track.repeatCount; i++) {
        _expanded.add(_ExpandedTrack(
          audioId: track.audioId,
          title: track.audioTitle,
          filePath: path,
          repeatIndex: i,
          repeatTotal: track.repeatCount,
        ));
        audioSources.add(AudioSource.uri(Uri.file(path)));
      }
    }

    if (audioSources.isEmpty) return;

    final playlist = ConcatenatingAudioSource(children: audioSources);

    // بناء قائمة الانتظار (queue) الظاهرة في الإشعار/شاشة القفل
    queue.add(_expanded
        .map((t) => MediaItem(
              id: t.filePath,
              title: t.title,
              // يظهر هذا السطر تحت العنوان في بعض واجهات الإشعارات
              artist: 'تكرار ${t.repeatIndex} من ${t.repeatTotal}',
              extras: {
                'repeatIndex': t.repeatIndex,
                'repeatTotal': t.repeatTotal,
              },
            ))
        .toList());

    try {
      await _player.setAudioSource(playlist, initialIndex: 0);
      await _player.play();
    } catch (e) {
      // فشل تحميل أحد الملفات (قد يكون محذوفًا من التخزين)
      // لا نوقف التطبيق، فقط نمنع البدء.
    }
  }

  void _listenForCurrentSongIndexChanges() {
    _player.currentIndexStream.listen((index) {
      final playlist = queue.value;
      if (index == null || playlist.isEmpty || index >= playlist.length) {
        return;
      }
      mediaItem.add(playlist[index]);
    });
  }

  void _listenForPlaybackEvents() {
    _player.playbackEventStream.listen((event) {
      final playing = _player.playing;
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          playing ? MediaControl.pause : MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 3],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex,
      ));
    });
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    return super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> skipToQueueItem(int index) async {
    await _player.seek(Duration.zero, index: index);
  }

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<bool> get playingStream => _player.playingStream;

  Future<void> dispose() async {
    await _player.dispose();
  }
}
