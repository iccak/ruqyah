import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

import '../models/ruqyah.dart';
import '../services/audio_service_provider.dart';
import '../services/storage_service.dart';
import '../theme.dart';

/// شاشة التشغيل: تعرض المقطع الحالي وحالة التكرار ("سورة الفاتحة -
/// تكرار 3 من 7") مع أزرار تحكم كبيرة (تشغيل/إيقاف/التالي/السابق).
/// التشغيل الفعلي يتم عبر خدمة الخلفية (Background Service) بحيث
/// يستمر حتى عند إغلاق الشاشة أو قفل الجهاز.
class PlayerScreen extends StatefulWidget {
  final Ruqyah ruqyah;
  const PlayerScreen({super.key, required this.ruqyah});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final storage = StorageService.instance;

  @override
  void initState() {
    super.initState();
    _startPlayback();
  }

  Future<void> _startPlayback() async {
    final filePaths = <String, String>{};
    for (final track in widget.ruqyah.tracks) {
      final audio = storage.getAudioById(track.audioId);
      if (audio != null) filePaths[track.audioId] = audio.filePath;
    }
    await audioHandler.loadRuqyah(widget.ruqyah, filePaths);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.ruqyah.title)),
      body: StreamBuilder<MediaItem?>(
        stream: audioHandler.mediaItem,
        builder: (context, mediaSnapshot) {
          final mediaItem = mediaSnapshot.data;

          return StreamBuilder<PlaybackState>(
            stream: audioHandler.playbackState,
            builder: (context, stateSnapshot) {
              final playbackState = stateSnapshot.data;
              final playing = playbackState?.playing ?? false;
              final processingState = playbackState?.processingState;
              final isLoading = processingState == AudioProcessingState.loading ||
                  processingState == AudioProcessingState.buffering;

              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.menu_book, size: 96, color: AppTheme.primaryGreen),
                    const SizedBox(height: 24),
                    Text(
                      mediaItem?.title ?? 'جارٍ التحميل...',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    if (mediaItem?.artist != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          mediaItem!.artist!,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppTheme.primaryGreenDark,
                              ),
                        ),
                      ),
                    const SizedBox(height: 40),
                    if (isLoading) const CircularProgressIndicator(),
                    if (!isLoading)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            iconSize: 48,
                            icon: const Icon(Icons.skip_previous),
                            onPressed: audioHandler.skipToPrevious,
                          ),
                          const SizedBox(width: 12),
                          _BigPlayButton(
                            playing: playing,
                            onPressed: playing ? audioHandler.pause : audioHandler.play,
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            iconSize: 48,
                            icon: const Icon(Icons.skip_next),
                            onPressed: audioHandler.skipToNext,
                          ),
                        ],
                      ),
                    const SizedBox(height: 24),
                    TextButton.icon(
                      onPressed: () async {
                        await audioHandler.stop();
                        if (context.mounted) Navigator.pop(context);
                      },
                      icon: const Icon(Icons.stop_circle, color: AppTheme.danger, size: 28),
                      label: const Text(
                        'إيقاف والخروج',
                        style: TextStyle(color: AppTheme.danger, fontSize: 18),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _BigPlayButton extends StatelessWidget {
  final bool playing;
  final VoidCallback onPressed;
  const _BigPlayButton({required this.playing, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.primaryGreen,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Icon(
            playing ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
            size: 48,
          ),
        ),
      ),
    );
  }
}
