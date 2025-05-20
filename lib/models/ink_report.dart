class InkReport {
  final String date;
  final String client;
  final String type;
  final String dimensions;
  final Map<String, double> colors; // اللون: الكمية
  final int count;
  final String? notes;

  InkReport({
    required this.date,
    required this.client,
    required this.type,
    required this.dimensions,
    required this.colors,
    required this.count,
    this.notes,
  });
}
