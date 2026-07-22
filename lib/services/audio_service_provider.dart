import 'package:audio_service/audio_service.dart';
import 'ruqyah_audio_handler.dart';

/// نقطة وصول واحدة لمعالج الصوت في الخلفية.
/// تتم تهيئتها بشكل مؤجل (lazy) عند فتح شاشة التشغيل لأول مرة فقط،
/// وليس عند إقلاع التطبيق، لتفادي بدء خدمة أندرويد الأمامية
/// (Foreground Service) قبل أن يطلب المستخدم التشغيل فعليًا.
late RuqyahAudioHandler audioHandler;
bool _audioServiceInitialized = false;

/// يُهيّئ خدمة الصوت مرة واحدة فقط طوال عمر التطبيق. آمن الاستدعاء
/// المتكرر (مثلاً في كل مرة تُفتح فيها شاشة التشغيل).
Future<void> ensureAudioServiceInitialized() async {
  if (_audioServiceInitialized) return;

  audioHandler = await AudioService.init(
    builder: () => RuqyahAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.ruqyah.app.audio',
      androidNotificationChannelName: 'تشغيل الرقية الشرعية',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      androidNotificationIcon: 'mipmap/ic_launcher',
    ),
  );

  _audioServiceInitialized = true;
}
