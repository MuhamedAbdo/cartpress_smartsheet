import 'package:cartpress_smartsheet/drawers/app_drawer.dart';
import 'package:cartpress_smartsheet/models/worker_action_model.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cartpress_smartsheet/models/worker_model.dart';

class WorkerDetailsScreen extends StatefulWidget {
  final Worker worker;
  final String boxName;

  const WorkerDetailsScreen({
    Key? key,
    required this.worker,
    required this.boxName,
  }) : super(key: key);

  @override
  State<WorkerDetailsScreen> createState() => _WorkerDetailsScreenState();
}

class _WorkerDetailsScreenState extends State<WorkerDetailsScreen> {
  void _refresh() => setState(() {});

  @override
  void initState() {
    super.initState();

    // إعادة الاتصال بالصندوق إذا انفصلت العلاقة
    if (widget.worker.actions.box == null) {
      widget.worker.reconnectActionsBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "👤 ${widget.worker.name.isNotEmpty ? widget.worker.name : 'غير معروف'}",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                "📞 رقم الهاتف: ${widget.worker.phone.isNotEmpty ? widget.worker.phone : 'غير متوفر'}"),
            Text(
                "🛠 الوظيفة: ${widget.worker.job.isNotEmpty ? widget.worker.job : 'غير معرفة'}"),
            const SizedBox(height: 16),
            const Text("📜 الإجراءات",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const Divider(),
            Expanded(
              child: widget.worker.actions.isEmpty
                  ? const Text("لا توجد إجراءات لهذا العامل بعد")
                  : ListView.builder(
                      itemCount: widget.worker.actions.length,
                      itemBuilder: (context, index) {
                        final action = widget.worker.actions[index];
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
                                  Text("📝 ملاحظات: ${action.notes!}"),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () async {
                                    await _showEditActionDialog(
                                        context, widget.worker, action, index);
                                    _refresh();
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () async {
                                    widget.worker.actions.removeAt(index);
                                    await widget.worker.save();
                                    _refresh();
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _showEditActionDialog(BuildContext context, Worker worker,
      WorkerAction action, int? index) async {
    final dayController = TextEditingController(text: action.days.toString());
    final noteController = TextEditingController(text: action.notes ?? '');
    final startDateController =
        TextEditingController(text: _formatDate(action.date));
    final returnDateController = TextEditingController(
        text: action.returnDate != null ? _formatDate(action.returnDate!) : '');

    String actionType = action.type;
    DateTime selectedStartDate = action.date;
    DateTime? selectedReturnDate = action.returnDate;

    await showDialog(
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
                                  _formatDate(pickedDate);
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                if (actionType == 'إجازة')
                  TextField(
                    controller: TextEditingController(
                      text: selectedReturnDate != null
                          ? _formatDate(selectedReturnDate!)
                          : '',
                    ),
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
              onPressed: () async {
                if (selectedStartDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("❌ اختر تاريخ البدء أولًا")));
                  return;
                }
                try {
                  final actionBox = Hive.box<WorkerAction>('worker_actions');
                  final newAction = WorkerAction(
                    type: actionType,
                    days: double.tryParse(dayController.text) ?? 1.0,
                    date: selectedStartDate,
                    returnDate: selectedReturnDate,
                    notes: noteController.text,
                  );
                  final key = await actionBox.add(newAction);
                  if (index != null &&
                      index >= 0 &&
                      index < worker.actions.length) {
                    worker.actions.removeAt(index);
                    worker.actions
                        .insert(index, actionBox.get(key)! as WorkerAction);
                  } else {
                    worker.actions.add(actionBox.get(key)! as WorkerAction);
                  }
                  await worker.save();
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("❌ خطأ في حفظ الإجراء: $e")));
                }
              },
              child: const Text("✅ حفظ التعديلات"),
            ),
          ],
        ),
      ),
    );
    _refresh();
  }
}
