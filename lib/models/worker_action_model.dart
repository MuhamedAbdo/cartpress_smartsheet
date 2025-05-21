import 'package:hive_flutter/hive_flutter.dart';

part 'worker_action_model.g.dart';

@HiveType(typeId: 2)
class WorkerAction extends HiveObject {
  @HiveField(0)
  final String type; // إجازة، غياب، مكافئة، جزاء...

  @HiveField(1)
  final double days;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final String? notes;

  @HiveField(4)
  final DateTime? returnDate; // تاريخ العودة (في حالة الإجازة)

  WorkerAction({
    required this.type,
    required this.days,
    required this.date,
    this.notes,
    this.returnDate,
  });
}
