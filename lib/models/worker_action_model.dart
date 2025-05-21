import 'package:hive_flutter/hive_flutter.dart';

part 'worker_action_model.g.dart';

@HiveType(typeId: 2)
class WorkerAction extends HiveObject {
  @HiveField(0)
  final String type;

  @HiveField(1)
  final double days;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final String? notes;

  WorkerAction({
    required this.type,
    required this.days,
    required this.date,
    this.notes,
  });
}
