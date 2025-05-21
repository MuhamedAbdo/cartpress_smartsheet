import 'package:hive_flutter/hive_flutter.dart';
import 'worker_action_model.dart';

part 'worker_model.g.dart';

@HiveType(typeId: 1)
class Worker extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String phone;

  @HiveField(2)
  final String job;

  @HiveField(3)
  late HiveList<WorkerAction> actions;

  Worker({
    required this.name,
    required this.phone,
    required this.job,
    List<WorkerAction>? actions,
  }) {
    if (actions != null) {
      this.actions =
          HiveList(Hive.box<WorkerAction>('worker_actions'), objects: actions);
    } else {
      this.actions = HiveList(Hive.box<WorkerAction>('worker_actions'));
    }
  }
}
