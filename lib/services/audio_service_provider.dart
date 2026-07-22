import 'package:audio_service/audio_service.dart';
import 'ruqyah_audio_handler.dart';

/// نقطة وصول واحدة لمعالج الصوت في الخلفية، يتم تهيئتها مرة واحدة
/// عند إقلاع التطبيق داخل main().
late RuqyahAudioHandler audioHandler;

Future<void> initAudioService() async {
  audioHandler = await AudioService.init(
    builder: () => RuqyahAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.ruqyah.app.audio',
      androidNotificationChannelName: 'تشغيل الرقية الشرعية',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: false,
      androidNotificationIcon: 'mipmap/ic_launcher',
    ),
  );
}
