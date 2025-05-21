import 'package:hive_flutter/hive_flutter.dart';
import 'worker_action_model.dart';

part 'worker_model.g.dart';

@HiveType(typeId: 1)
class Worker extends HiveObject {
  @HiveField(0)
  late String name;

  @HiveField(1)
  late String phone;

  @HiveField(2)
  late String job;

  @HiveField(3)
  late HiveList<WorkerAction> actions;

  Worker({
    String? name,
    String? phone,
    String? job,
    List<WorkerAction>? actions,
  }) : super() {
    this.name = name ?? '';
    this.phone = phone ?? '';
    this.job = job ?? '';

    if (actions != null) {
      var box = Hive.box<WorkerAction>('worker_actions');
      this.actions = HiveList(box)..addAll(actions);
    } else {
      this.actions = HiveList(Hive.box<WorkerAction>('worker_actions'));
    }
  }

  // 👇 أضف هذه الدالة هنا
  void reconnectActionsBox() {
    var box = Hive.box<WorkerAction>('worker_actions');
    actions = HiveList(box)..addAll(actions);
  }
}
