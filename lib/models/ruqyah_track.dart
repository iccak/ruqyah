import 'package:hive/hive.dart';

part 'ruqyah_track.g.dart';

/// يمثل عنصرًا واحدًا ضمن قائمة الرقية: إشارة إلى ملف صوتي محدد
/// مع عدد مرات التكرار المطلوبة له داخل هذه الرقية.
@HiveType(typeId: 1)
class RuqyahTrack extends HiveObject {
  @HiveField(0)
  String audioId; // معرف AudioItem المرتبط

  @HiveField(1)
  String audioTitle; // نسخة من العنوان لعرض سريع دون إعادة الجلب

  @HiveField(2)
  int repeatCount; // عدد مرات التكرار (مثال: 7)

  RuqyahTrack({
    required this.audioId,
    required this.audioTitle,
    required this.repeatCount,
  });
}
