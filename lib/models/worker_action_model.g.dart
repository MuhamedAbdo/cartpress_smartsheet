// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'worker_action_model.dart';

class WorkerActionAdapter extends TypeAdapter<WorkerAction> {
  @override
  final int typeId = 2;

  @override
  WorkerAction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};

    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      fields[key] = reader.read();
    }

    return WorkerAction(
      type: fields[0] as String,
      days: fields[1] as double,
      date: fields[2] as DateTime,
      notes: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, WorkerAction obj) {
    writer.writeByte(4);
    writer.writeByte(0);
    writer.write(obj.type);
    writer.writeByte(1);
    writer.write(obj.days);
    writer.writeByte(2);
    writer.write(obj.date);
    writer.writeByte(3);
    writer.write(obj.notes);
  }

  @override
  int get hashCode => typeId;

  @override
  bool operator ==(Object other) =>
      other is WorkerActionAdapter && other.typeId == typeId;
}
