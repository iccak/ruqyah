import 'package:hive/hive.dart';

part 'audio_item.g.dart';

/// يمثل ملف صوتي واحد تم استيراده من المستخدم (سورة أو مقطع رقية)
/// ويُخزَّن بشكل دائم داخل التخزين الداخلي للتطبيق.
@HiveType(typeId: 0)
class AudioItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title; // اسم السورة/المقطع كما يظهر للمستخدم

  @HiveField(2)
  String filePath; // المسار الداخلي الدائم للملف بعد نسخه

  @HiveField(3)
  DateTime addedAt;

  AudioItem({
    required this.id,
    required this.title,
    required this.filePath,
    required this.addedAt,
  });
}
