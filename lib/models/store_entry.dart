class StoreEntry {
  final String date;
  final String type;
  final String unit;
  final int count;
  final String? notes;

  StoreEntry({
    required this.date,
    required this.type,
    required this.unit,
    required this.count,
    this.notes,
  });
}
