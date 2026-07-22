import 'package:hive/hive.dart';
import 'ruqyah_track.dart';

part 'ruqyah.g.dart';

/// يمثل رقية مخصصة أنشأها المستخدم: عنوان + قائمة مرتبة من المقاطع
/// الصوتية وعدد تكرار كل مقطع.
@HiveType(typeId: 2)
class Ruqyah extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  List<RuqyahTrack> tracks;

  @HiveField(3)
  DateTime createdAt;

  Ruqyah({
    required this.id,
    required this.title,
    required this.tracks,
    required this.createdAt,
  });

  /// وصف مختصر مثل: "الفاتحة (تكرار 7) - الزلزلة (تكرار 3)"
  String get summary {
    if (tracks.isEmpty) return 'لا توجد مقاطع بعد';
    return tracks
        .map((t) => '${t.audioTitle} (تكرار ${t.repeatCount})')
        .join(' - ');
  }
}
