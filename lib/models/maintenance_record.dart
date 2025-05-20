class MaintenanceRecord {
  final String date;
  final String machine;
  final String issue;
  final String technician;
  final String action;
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
