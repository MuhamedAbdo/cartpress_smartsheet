import 'package:cartpress_smartsheet/drawers/app_drawer.dart';
import 'package:cartpress_smartsheet/models/worker_action_model.dart';
import 'package:cartpress_smartsheet/screens/worker_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cartpress_smartsheet/models/worker_model.dart';

class WorkersScreen extends StatelessWidget {
  final String departmentBoxName;
  final String departmentTitle;

  const WorkersScreen({
    Key? key,
    required this.departmentBoxName,
    required this.departmentTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(), // ✅ تم الإضافة هنا
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "👷‍♂️ $departmentTitle - العمال",
        ),
      ),
      body: ValueListenableBuilder<Box<Worker>>(
        valueListenable: Hive.box<Worker>(departmentBoxName).listenable(),
        builder: (context, box, _) {
          if (box.isEmpty) {
            return const Center(child: Text("🚫 لا يوجد عمال بعد"));
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final worker = box.getAt(index)!;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text("👤 ${worker.name}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("📞 ${worker.phone}"),
                      Text("🛠 ${worker.job}"),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.add, color: Colors.green),
                    onPressed: () => _showWorkerActionsDialog(context, worker),
                  ),
                  onTap: () => _showWorkerDetails(context, worker),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddWorkerDialog(context, departmentBoxName),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddWorkerDialog(BuildContext context, String boxName) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    String job = 'فني';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("➕ إضافة عامل جديد"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "👤 الإسم")),
                TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration:
                        const InputDecoration(labelText: "📞 رقم الهاتف")),
                DropdownButtonFormField<String>(
                  value: job,
                  items: const [
                    DropdownMenuItem(
                        value: 'رئيس القسم', child: Text('رئيس القسم')),
                    DropdownMenuItem(value: 'فني', child: Text('فني')),
                    DropdownMenuItem(value: 'عامل', child: Text('عامل')),
                    DropdownMenuItem(value: 'مساعد', child: Text('مساعد')),
                  ],
                  onChanged: (val) => setState(() => job = val ?? 'فني'),
                  decoration: const InputDecoration(labelText: "🛠 الوظيفة"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: Navigator.of(context).pop,
                child: const Text("❌ إلغاء")),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    phoneController.text.isNotEmpty) {
                  final newWorker = Worker(
                    name: nameController.text,
                    phone: phoneController.text,
                    job: job,
                    actions: [],
                  );
                  Hive.box<Worker>(boxName).add(newWorker);
                  Navigator.pop(context);
                }
              },
              child: const Text("💾 حفظ"),
            ),
          ],
        ),
      ),
    );
  }

  void _showWorkerDetails(BuildContext context, Worker worker) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            WorkerDetailsScreen(worker: worker, boxName: departmentBoxName),
      ),
    );
  }

  void _showWorkerActionsDialog(BuildContext context, Worker worker) {
    final actionController = TextEditingController();
    final dayController = TextEditingController(text: '1');
    final noteController = TextEditingController();

    String actionType = 'إجازة';
    late DateTime selectedDate;
    bool isDatePickerEnabled = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("➕ إضافة إجراء"),
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
                      setState(() => actionType = val ?? 'إجازة'),
                  decoration: const InputDecoration(labelText: "نوع الإجراء"),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<double>(
                        value: 1.0,
                        items: const [
                          DropdownMenuItem(value: 0.25, child: Text("¼ يوم")),
                          DropdownMenuItem(value: 0.5, child: Text("½ يوم")),
                          DropdownMenuItem(value: 1.0, child: Text("يوم كامل")),
                          DropdownMenuItem(value: 2.0, child: Text("يومين")),
                        ],
                        onChanged: (val) =>
                            setState(() => dayController.text = val.toString()),
                        decoration:
                            const InputDecoration(labelText: "عدد الأيام"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: actionController,
                        readOnly: true,
                        decoration:
                            const InputDecoration(labelText: "📆 التاريخ"),
                        onTap: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            selectedDate = pickedDate;
                            actionController.text =
                                "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";
                            isDatePickerEnabled = false;
                            setState(() {});
                          }
                        },
                      ),
                    ),
                  ],
                ),
                TextField(
                    controller: noteController,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: "📝 ملاحظات")),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: Navigator.of(context).pop,
                child: const Text("❌ إلغاء")),
            ElevatedButton(
              onPressed: () {
                final newAction = WorkerAction(
                  type: actionType,
                  days: double.tryParse(dayController.text) ?? 1.0,
                  date: selectedDate,
                  notes: noteController.text,
                );

                // ✅ استخدم الصندوق اللي مفتوح
                final actionBox = Hive.box<WorkerAction>('worker_actions');

// ✅ أضف الإجراء وخذ الـ key
                final key = actionBox.add(newAction); // ← هيرجع المفتاح

// ✅ أضف الإجراء إلى العامل
                worker.actions.add(newAction);
                worker.save(); // ← أو worker.actions.put(key, newAction)

                // ✅ أضف الإجراء إلى العامل باستخدام الصندوق
                worker.actions.add(newAction);
                worker.save(); // ← أو worker.actions.put() لو محتاج تعديل مباشر

                Navigator.pop(context);
              },
              child: const Text("✅ حفظ الإجراء"),
            ),
          ],
        ),
      ),
    );
  }
}
