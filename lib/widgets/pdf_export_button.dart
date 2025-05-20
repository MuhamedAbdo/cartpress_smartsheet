// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../utils/pdf_generator.dart';
import '../models/ink_report.dart';
import '../models/store_entry.dart';
import '../models/maintenance_record.dart';

class PDFExportButton extends StatelessWidget {
  final String reportType;
  final List<dynamic> data;

  const PDFExportButton(
      {super.key, required this.reportType, required this.data});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        try {
          switch (reportType) {
            case 'ink_report':
              await PDFGenerator.generateInkReportPDF(data.cast<InkReport>());
              break;
            case 'store_entry':
              await PDFGenerator.generateStoreEntryPDF(data.cast<StoreEntry>());
              break;
            case 'maintenance_record':
              await PDFGenerator.generateMaintenanceRecordPDF(
                  data.cast<MaintenanceRecord>());
              break;
            default:
              throw Exception('Invalid report type');
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PDF generated successfully')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to generate PDF: $e')),
          );
        }
      },
      child: const Icon(Icons.picture_as_pdf),
    );
  }
}
