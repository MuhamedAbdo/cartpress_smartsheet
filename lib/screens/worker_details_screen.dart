import 'package:cartpress_smartsheet/drawers/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cartpress_smartsheet/models/worker_model.dart';

class WorkerDetailsScreen extends StatelessWidget {
  final Worker worker;
  final String boxName;

  const WorkerDetailsScreen(
      {Key? key, required this.worker, required this.boxName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(), // ✅ تم الإضافة هنا
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "👤 ${worker.name}",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("📞 رقم الهاتف: ${worker.phone}"),
            Text("🛠 الوظيفة: ${worker.job}"),
            const SizedBox(height: 16),
            const Text("📜 الإجراءات",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const Divider(),
            if (worker.actions.isEmpty)
              const Text("لا توجد إجراءات لهذا العامل بعد"),
            ...worker.actions.map((action) => Card(
                  child: ListTile(
                    title: Text("${action.type} (${action.days} يوم)"),
                    subtitle: Text("${actionDateFormatted(action.date)}"),
                    trailing: Text("ملاحظات: ${action.notes ?? 'بدون'}"),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  String actionDateFormatted(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
