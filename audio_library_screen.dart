// GENERATED CODE - manually written to match build_runner output.
// If you run `flutter packages pub run build_runner build` this file
// will be regenerated automatically and can safely be overwritten.

part of 'ruqyah.dart';

class RuqyahAdapter extends TypeAdapter<Ruqyah> {
  @override
  final int typeId = 2;

  @override
  Ruqyah read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Ruqyah(
      id: fields[0] as String,
      title: fields[1] as String,
      tracks: (fields[2] as List).cast<RuqyahTrack>(),
      createdAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Ruqyah obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.tracks)
      ..writeByte(3)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RuqyahAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
