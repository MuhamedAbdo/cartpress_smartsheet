import 'package:cartpress_smartsheet/models/worker_action_model.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cartpress_smartsheet/models/worker_model.dart';

class WorkerDetailsScreen extends StatelessWidget {
  final Worker worker;
  final String boxName;

  const WorkerDetailsScreen({
    Key? key,
    required this.worker,
    required this.boxName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("👤 ${worker.name}")),
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
            Expanded(
              child: ValueListenableBuilder<Box<WorkerAction>>(
                valueListenable:
                    Hive.box<WorkerAction>('worker_actions').listenable(),
                builder: (context, actionBox, _) {
                  return ListView.builder(
                    itemCount: worker.actions.length,
                    itemBuilder: (context, index) {
                      final action = worker.actions[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: ListTile(
                          title: Text("${action.type} (${action.days} يوم)"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("📆 من: ${_formatDate(action.date)}"),
                              if (action.returnDate != null)
                                Text(
                                    "🗓️ إلى: ${_formatDate(action.returnDate!)}"),
                              if (action.notes?.isNotEmpty == true)
                                Text("📝 ملاحظات: ${action.notes}"),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showEditActionDialog(
                                    context, worker, action, index),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  // حذف مباشر + تحديث فوري للشاشة
                                  worker.actions.removeAt(index);
                                  worker.save();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ تم تعريف الدالة مرة واحدة فقط
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  void _showEditActionDialog(
      BuildContext context, Worker worker, WorkerAction action, int index) {
    final dayController = TextEditingController(text: action.days.toString());
    final noteController = TextEditingController(text: action.notes ?? '');
    final startDateController =
        TextEditingController(text: _formatDate(action.date));
    final returnDateController = TextEditingController(
        text: action.returnDate != null ? _formatDate(action.returnDate!) : '');

    String actionType = action.type;
    DateTime selectedStartDate = action.date;
    DateTime? selectedReturnDate = action.returnDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text("🔄 تعديل الإجراء"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: actionType,
                  items: const [
                    DropdownMenuItem(value: 'إجازة', child: Text('إجازة')),
                    DropdownMenuItem(value: 'غياب', child: Text('غياب')),
                    DropdownMenuItem(value: 'مكافئة', child: Text('مكافئة')),
                    DropdownMenuItem(value: 'جزاء', child: Text('جزاء')),
                  ],
                  onChanged: (val) =>
                      setStateDialog(() => actionType = val ?? 'إجازة'),
                  decoration: const InputDecoration(labelText: "نوع الإجراء"),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<double>(
                        value: double.tryParse(dayController.text) ?? 1.0,
                        items: const [
                          DropdownMenuItem(value: 0.25, child: Text("¼ يوم")),
                          DropdownMenuItem(value: 0.5, child: Text("½ يوم")),
                          DropdownMenuItem(value: 1.0, child: Text("يوم واحد")),
                          DropdownMenuItem(value: 2.0, child: Text("يومين")),
                          DropdownMenuItem(value: 3.0, child: Text("3 أيام")),
                          DropdownMenuItem(value: 7.0, child: Text("أسبوع")),
                        ],
                        onChanged: (val) => setStateDialog(
                            () => dayController.text = val.toString()),
                        decoration:
                            const InputDecoration(labelText: "عدد الأيام"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: startDateController,
                        readOnly: true,
                        decoration:
                            const InputDecoration(labelText: "📅 تاريخ البدء"),
                        onTap: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedStartDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            setStateDialog(() {
                              selectedStartDate = pickedDate;
                              startDateController.text =
                                  _formatDate(selectedStartDate);
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                if (actionType == 'إجازة')
                  TextField(
                    controller: returnDateController,
                    readOnly: true,
                    decoration:
                        const InputDecoration(labelText: "🗓️ تاريخ العودة"),
                    onTap: () async {
                      if (selectedStartDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("❌ اختر تاريخ البدء أولًا")));
                        return;
                      }

                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedStartDate,
                        firstDate: selectedStartDate,
                        lastDate: DateTime(2100),
                      );

                      if (pickedDate != null) {
                        setStateDialog(() {
                          selectedReturnDate = pickedDate;
                          returnDateController.text = _formatDate(pickedDate);
                        });
                      }
                    },
                  ),
                TextField(
                  controller: noteController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: "📝 ملاحظات"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: const Text("❌ إلغاء"),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedAction = WorkerAction(
                  type: actionType,
                  days: double.tryParse(dayController.text) ?? 1.0,
                  date: selectedStartDate,
                  returnDate: selectedReturnDate,
                  notes: noteController.text,
                );

                worker.actions[index] = updatedAction;
                worker.save();

                Navigator.pop(context);
              },
              child: const Text("💾 حفظ التعديلات"),
            ),
          ],
        ),
      ),
    );
  }
}
