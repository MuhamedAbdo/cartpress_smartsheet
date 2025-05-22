// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/ink_report.dart';
import '../models/store_entry.dart';
import '../models/maintenance_record.dart';

class PDFGenerator {
  static Future<void> generateInkReportPDF(List<InkReport> reports) async {
    final pdf = pw.Document();
    final font = await rootBundle.load("assets/fonts/arabic_font.ttf");
    final ttf = pw.Font.ttf(font);

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Table.fromTextArray(
          context: context,
          data: [
            [
              "مسلسل",
              "التاريخ",
              "العميل",
              "الصنف",
              "المقاس",
              "الألوان",
              "العدد",
              "الملاحظات"
            ],
            ...reports.asMap().entries.map((entry) {
              int index = entry.key + 1;
              InkReport report = entry.value;
              return [
                index.toString(),
                report.date,
                report.client,
                report.type,
                report.dimensions,
                report.colors.entries
                    .map((e) => "${e.key}: ${e.value} لتر")
                    .join("\n"),
                report.count.toString(),
                report.notes ?? ""
              ];
            }).toList(),
          ],
          cellStyle: pw.TextStyle(font: ttf),
          cellAlignment: pw.Alignment.center,
        ),
      ),
    );

    await savePDF(
        pdf, "ink_report_${DateTime.now().millisecondsSinceEpoch}.pdf");
  }

  static Future<void> generateStoreEntryPDF(List<StoreEntry> entries) async {
    final pdf = pw.Document();
    final font = await rootBundle.load("assets/fonts/arabic_font.ttf");
    final ttf = pw.Font.ttf(font);

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Table.fromTextArray(
          context: context,
          data: [
            ["مسلسل", "التاريخ", "الصنف", "الوحدة", "العدد", "الملاحظات"],
            ...entries.asMap().entries.map((entry) {
              int index = entry.key + 1;
              StoreEntry storeEntry = entry.value;
              return [
                index.toString(),
                storeEntry.date,
                storeEntry.type,
                storeEntry.unit,
                storeEntry.count.toString(),
                storeEntry.notes ?? ""
              ];
            }).toList(),
          ],
          cellStyle: pw.TextStyle(font: ttf),
          cellAlignment: pw.Alignment.center,
        ),
      ),
    );

    await savePDF(
        pdf, "store_entry_${DateTime.now().millisecondsSinceEpoch}.pdf");
  }

  static Future<void> generateMaintenanceRecordPDF(
      List<MaintenanceRecord> records) async {
    final pdf = pw.Document();
    final font = await rootBundle.load("assets/fonts/arabic_font.ttf");
    final ttf = pw.Font.ttf(font);

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Table.fromTextArray(
          context: context,
          data: [
            [
              "مسلسل",
              "التاريخ",
              "الماكينة",
              "العطل",
              "الفني",
              "الإجراء",
              "الملاحظات"
            ],
            ...records.asMap().entries.map((entry) {
              int index = entry.key + 1;
              MaintenanceRecord record = entry.value;
              return [
                index.toString(),
                record.date,
                record.machine,
                record.issue,
                record.technician,
                record.action,
                record.notes ?? ""
              ];
            }).toList(),
          ],
          cellStyle: pw.TextStyle(font: ttf),
          cellAlignment: pw.Alignment.center,
        ),
      ),
    );

    await savePDF(
        pdf, "maintenance_record_${DateTime.now().millisecondsSinceEpoch}.pdf");
  }

  static Future<void> savePDF(pw.Document pdf, String fileName) async {
    final output = await getApplicationDocumentsDirectory();
    final file = File("${output!.path}/$fileName");
    await file.writeAsBytes(await pdf.save());
  }
}
