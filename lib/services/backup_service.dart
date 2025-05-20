// lib/services/backup_service.dart

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

class BackupService {
  // 📁 اسم المجلد الذي سنحفظ فيه النسخ الاحتياطية
  final String backupFolderName = "local_hive_backups";

  // 💾 قائمة بأسماء الصناديق التي تريد عمل نسخ احتياطية لها
  final List<String> boxesToBackup = [
    'inkReports',
    'storeEntries',
    'maintenanceRecords',
    'savedSheetSizes',
  ];

  // 📦 حفظ جميع الصناديق في ملف واحد
  Future<void> createLocalBackup(BuildContext context) async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${appDocDir.path}/$backupFolderName');

      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      final backupFile = File('${backupDir.path}/full_backup.json');

      final Map<String, List<Map<String, dynamic>>> allBoxesData = {};

      for (var boxName in boxesToBackup) {
        final Box<dynamic> box = Hive.box(boxName);

        if (box == null) {
          _showSnackBar(context, "$boxName غير موجود");
          continue;
        }

        final List<Map<String, dynamic>> boxData = [];

        box.toMap().forEach((key, value) {
          try {
            jsonEncode({'key': key, 'value': value});
            boxData.add({
              'key': key.toString(),
              'value': value,
            });
          } catch (e) {
            print("القيمة غير قابلة للتحويل إلى JSON: $key -> $value");
          }
        });

        allBoxesData[boxName] = boxData;
      }

      await backupFile.writeAsString(jsonEncode(allBoxesData));

      _showSnackBar(context, "تم إنشاء نسخة احتياطية كاملة");
    } catch (e) {
      _showSnackBar(context, "فشل في إنشاء النسخة الاحتياطية: $e");
    }
  }

  // 📤 استعادة البيانات من النسخة الاحتياطية الكاملة
  Future<void> restoreFromLocalBackup(BuildContext context) async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final backupFilePath =
          '${appDocDir.path}/local_hive_backups/full_backup.json';
      final backupFile = File(backupFilePath);

      if (!await backupFile.exists()) {
        _showSnackBar(context, "النسخة الاحتياطية الكاملة غير موجودة");
        return;
      }

      final content = await backupFile.readAsString();
      final Map<String, dynamic> allBoxesData = jsonDecode(content);

      for (var boxName in boxesToBackup) {
        final Box<dynamic> box = Hive.box(boxName);
        final List<dynamic>? boxData = allBoxesData[boxName];

        if (boxData == null || boxData.isEmpty) {
          _showSnackBar(
              context, "$boxName ليس لديه بيانات في النسخة الاحتياطية");
          continue;
        }

        await box.clear();

        for (var item in boxData) {
          final key = item['key'];
          final value = item['value'];
          box.put(key, value);
        }
      }

      _showSnackBar(context, "تم استعادة جميع البيانات بنجاح");
    } catch (e) {
      _showSnackBar(context, "فشل في الاستعادة: $e");
    }
  }

  // 🛠️ دالة مساعدة لإظهار الرسائل
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
