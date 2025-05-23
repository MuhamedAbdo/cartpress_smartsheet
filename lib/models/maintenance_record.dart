import 'package:hive_flutter/hive_flutter.dart';

part 'maintenance_record.g.dart'; // هنشغل ده وقت ما نحتاج TypeAdapter

@HiveType(typeId: 0)
class MaintenanceRecord {
  @HiveField(0)
  final String date;

  @HiveField(1)
  final String machine;

  @HiveField(2)
  final String issue;

  @HiveField(3)
  final String technician;

  @HiveField(4)
  final String action;

  @HiveField(5)
  final String? notes;

  MaintenanceRecord({
    required this.date,
    required this.machine,
    required this.issue,
    required this.technician,
    required this.action,
    this.notes,
  });
}
