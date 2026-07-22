// GENERATED CODE - manually written to match build_runner output.
// If you run `flutter packages pub run build_runner build` this file
// will be regenerated automatically and can safely be overwritten.

part of 'ruqyah_track.dart';

class RuqyahTrackAdapter extends TypeAdapter<RuqyahTrack> {
  @override
  final int typeId = 1;

  @override
  RuqyahTrack read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RuqyahTrack(
      audioId: fields[0] as String,
      audioTitle: fields[1] as String,
      repeatCount: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, RuqyahTrack obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.audioId)
      ..writeByte(1)
      ..write(obj.audioTitle)
      ..writeByte(2)
      ..write(obj.repeatCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RuqyahTrackAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
