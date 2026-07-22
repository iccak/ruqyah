// GENERATED CODE - manually written to match build_runner output.
// If you run `flutter packages pub run build_runner build` this file
// will be regenerated automatically and can safely be overwritten.

part of 'audio_item.dart';

class AudioItemAdapter extends TypeAdapter<AudioItem> {
  @override
  final int typeId = 0;

  @override
  AudioItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AudioItem(
      id: fields[0] as String,
      title: fields[1] as String,
      filePath: fields[2] as String,
      addedAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, AudioItem obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.filePath)
      ..writeByte(3)
      ..write(obj.addedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
