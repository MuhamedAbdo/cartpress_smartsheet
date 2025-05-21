import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cartpress_smartsheet/models/worker_model.dart';
import 'package:cartpress_smartsheet/models/worker_action_model.dart';
import 'package:cartpress_smartsheet/screens/worker_details_screen.dart';

class WorkersScreen extends StatefulWidget {
  final String departmentBoxName;
  final String departmentTitle;

  const WorkersScreen({
    Key? key,
    required this.departmentBoxName,
    required this.departmentTitle,
  }) : super(key: key);

  @override
  State<WorkersScreen> createState() => _WorkersScreenState();
}

class _WorkersScreenState extends State<WorkersScreen> {
  late Box<Worker> workerBox;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeBox();
  }

  Future<void> _initializeBox() async {
    try {
      if (!Hive.isBoxOpen(widget.departmentBoxName)) {
        await Hive.openBox<Worker>(widget.departmentBoxName);
      }
      workerBox = Hive.box<Worker>(widget.departmentBoxName);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'فشل في تحميل بيانات العمال: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.departmentTitle)),
        body: Center(child: Text(errorMessage!)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("👷‍♂️ ${widget.departmentTitle} - العمال"),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<Box<Worker>>(
        valueListenable: workerBox.listenable(),
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.green),
                        onPressed: () =>
                            _showWorkerActionsDialog(context, worker),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showAddWorkerDialog(
                            context, widget.departmentBoxName,
                            existingWorker: worker),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => box.deleteAt(index),
                      ),
                    ],
                  ),
                  onTap: () => _showWorkerDetails(context, worker),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            _showAddWorkerDialog(context, widget.departmentBoxName),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddWorkerDialog(
    BuildContext context,
    String boxName, {
    Worker? existingWorker,
  }) {
    final nameController =
        TextEditingController(text: existingWorker?.name ?? '');
    final phoneController =
        TextEditingController(text: existingWorker?.phone ?? '');
    String job = existingWorker?.job ?? 'مشرف';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
              existingWorker == null ? "➕ إضافة عامل جديد" : "🔄 تعديل العامل"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "👤 الإسم"),
                ),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: "📞 رقم الهاتف"),
                ),
                DropdownButtonFormField<String>(
                  value: job,
                  items: const [
                    DropdownMenuItem(
                        value: 'رئيس القسم', child: Text('رئيس القسم')),
                    DropdownMenuItem(value: 'مشرف', child: Text('مشرف')),
                    DropdownMenuItem(value: 'فني', child: Text('فني')),
                    DropdownMenuItem(value: 'عامل', child: Text('عامل')),
                    DropdownMenuItem(value: 'مساعد', child: Text('مساعد')),
                  ],
                  onChanged: (val) => setState(() => job = val ?? 'مشرف'),
                  decoration: const InputDecoration(labelText: "🛠 الوظيفة"),
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
                final newWorker = Worker(
                  name: nameController.text,
                  phone: phoneController.text,
                  job: job,
                  actions: existingWorker?.actions ?? [],
                );

                if (existingWorker == null) {
                  workerBox.add(newWorker);
                } else {
                  existingWorker.name = nameController.text;
                  existingWorker.phone = phoneController.text;
                  existingWorker.job = job;
                  existingWorker.save();
                }

                Navigator.pop(context);
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
        builder: (_) => WorkerDetailsScreen(
          worker: worker,
          boxName: widget.departmentBoxName,
        ),
      ),
    );
  }

  Future<void> _showWorkerActionsDialog(
      BuildContext context, Worker worker) async {
    final dayController = TextEditingController(text: '1');
    final noteController = TextEditingController();
    final startDateController = TextEditingController();
    DateTime? selectedStartDate;
    DateTime? selectedReturnDate;
    String actionType = 'إجازة';

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
                        value: double.tryParse(dayController.text) ?? 1.0,
                        items: const [
                          DropdownMenuItem(value: 0.25, child: Text("¼ يوم")),
                          DropdownMenuItem(value: 0.5, child: Text("½ يوم")),
                          DropdownMenuItem(value: 1.0, child: Text("يوم واحد")),
                          DropdownMenuItem(value: 2.0, child: Text("يومين")),
                          DropdownMenuItem(value: 3.0, child: Text("3 أيام")),
                          DropdownMenuItem(value: 7.0, child: Text("أسبوع")),
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
                        controller: startDateController,
                        readOnly: true,
                        decoration:
                            const InputDecoration(labelText: "📅 تاريخ البدء"),
                        onTap: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              selectedStartDate = pickedDate;
                              startDateController.text =
                                  "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
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
                        initialDate: selectedStartDate!,
                        firstDate: selectedStartDate!,
                        lastDate: DateTime(2100),
                      );

                      if (pickedDate != null) {
                        setState(() {
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
                    date: selectedStartDate!,
                    returnDate: selectedReturnDate,
                    notes: noteController.text,
                  );

                  actionBox.add(newAction);
                  worker.actions.add(newAction);
                  worker.save();

                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("❌ خطأ في حفظ الإجراء: ${e.toString()}")));
                }
              },
              child: const Text("✅ حفظ الإجراء"),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
