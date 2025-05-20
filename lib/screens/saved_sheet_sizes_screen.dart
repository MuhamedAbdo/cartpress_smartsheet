import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cartpress_smartsheet/drawers/app_drawer.dart';
import 'package:cartpress_smartsheet/screens/sheet_size_screen.dart';
import 'package:cartpress_smartsheet/screens/ink_report_screen.dart';

class SavedSheetSizesScreen extends StatefulWidget {
  const SavedSheetSizesScreen({super.key});

  @override
  _SavedSheetSizesScreenState createState() => _SavedSheetSizesScreenState();
}

class _SavedSheetSizesScreenState extends State<SavedSheetSizesScreen> {
  final Box savedSheetSizesBox = Hive.box('savedSheetSizes');
  String searchQuery = "";
  bool isSearching = false;

  void _navigateToInkReportWithSheetData(BuildContext context, Map record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InkReportScreen(initialData: {
          'date':
              "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}",
          'clientName': record['clientName'],
          'product': record['productName'],
          'productCode': record['productCode'],
          'dimensions': {
            'length': record['length'],
            'width': record['width'],
            'height': record['height'],
          },
          'colors': [],
          'quantity': '',
          'notes': '',
          'imagePaths': record['imagePaths'] ?? [],
        }),
      ),
    );
  }

  void _showSizeDetails(BuildContext context, Map record) {
    // حساب طول وعرض الشيت
    double length = double.tryParse(record['length']?.toString() ?? '0') ?? 0;
    double width = double.tryParse(record['width']?.toString() ?? '0') ?? 0;
    double height = double.tryParse(record['height']?.toString() ?? '0') ?? 0;

    bool isFullSize = record['isFullSize'] ?? true;
    bool isQuarterSize = record['isQuarterSize'] ?? false;
    bool isOverFlap = record['isOverFlap'] ?? false;
    bool isTwoFlap = record['isTwoFlap'] ?? true;
    bool addTwoMm = record['addTwoMm'] ?? false;

    double sheetLength = 0.0;
    double sheetWidth = 0.0;
    String productionWidth1 = '';
    String productionWidth2 = '';
    String productionHeight = '';

    if (isFullSize) {
      sheetLength = ((length + width) * 2) + 4;
    } else if (isQuarterSize) {
      sheetLength = width + 4;
    } else {
      sheetLength = length + width + 4;
    }

    if (isOverFlap && isTwoFlap) {
      sheetWidth = addTwoMm ? height + (width * 2) + 0.4 : height + (width * 2);
    } else if (record['isOneFlap'] == true && isOverFlap) {
      sheetWidth = addTwoMm ? height + width + 0.2 : height + width;
    } else if (record['isTwoFlap'] == true) {
      sheetWidth = addTwoMm ? height + width + 0.4 : height + width;
    } else if (record['isOneFlap'] == true) {
      sheetWidth = addTwoMm ? height + (width / 2) + 0.2 : height + (width / 2);
    }

    if (isOverFlap && isTwoFlap) {
      productionWidth1 = addTwoMm
          ? (width + 0.2).toStringAsFixed(2)
          : width.toStringAsFixed(2);
      productionWidth2 = productionWidth1;
    } else if (isOverFlap && record['isOneFlap'] == true) {
      productionWidth1 = ".....";
      productionWidth2 = addTwoMm
          ? (width + 0.2).toStringAsFixed(2)
          : width.toStringAsFixed(2);
    } else if (record['isTwoFlap'] == true) {
      productionWidth1 = addTwoMm
          ? ((width / 2) + 0.2).toStringAsFixed(2)
          : (width / 2).toStringAsFixed(2);
      productionWidth2 = productionWidth1;
    } else if (record['isOneFlap'] == true) {
      productionWidth1 = ".....";
      productionWidth2 = addTwoMm
          ? ((width / 2) + 0.2).toStringAsFixed(2)
          : (width / 2).toStringAsFixed(2);
    } else {
      productionWidth1 = productionWidth2 = ".....";
    }

    productionHeight = height.toStringAsFixed(2);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تفاصيل المقاس"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("📏 طول الشيت: ${sheetLength.toStringAsFixed(2)} سم"),
            Text("📐 عرض الشيت: ${sheetWidth.toStringAsFixed(2)} سم"),
            const SizedBox(height: 16),
            const Text("🔧 مقاسات خط الإنتاج",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Table(
              border: TableBorder.all(),
              children: [
                TableRow(
                  children: [
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(child: Text(productionWidth1)),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(child: Text(productionHeight)),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(child: Text(productionWidth2)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text("حسنًا"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        centerTitle: true,
        title: isSearching
            ? TextField(
                decoration: InputDecoration(
                  hintText: "بحث باستخدام كود الصنف أو اسم العميل...",
                  hintStyle: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black45,
                  ),
                  border: InputBorder.none,
                ),
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              )
            : const Text("📄 المقاسات المحفوظة"),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (isSearching) searchQuery = "";
                isSearching = !isSearching;
              });
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: savedSheetSizesBox.listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return const Center(child: Text("🚫 لا توجد مقاسات محفوظة."));
          }

          final filteredRecords = box.keys.where((key) {
            final record = box.get(key) as Map;
            final productCode =
                record['productCode']?.toString().toLowerCase() ?? "";
            final clientName =
                record['clientName']?.toString().toLowerCase() ?? "";
            final productName =
                record['productName']?.toString().toLowerCase() ?? "";
            final query = searchQuery.toLowerCase();

            if (searchQuery.isNotEmpty) {
              if (int.tryParse(searchQuery) != null) {
                return productCode.contains(query);
              } else {
                return clientName.contains(query) ||
                    productName.contains(query) ||
                    productCode.contains(query);
              }
            }
            return true;
          }).map((key) {
            final record = box.get(key) as Map;
            return {
              'key': key,
              'data': record,
              'date': record['date'] ?? '',
            };
          }).toList()
            ..sort((a, b) {
              final timeA = DateTime.tryParse(a['date']);
              final timeB = DateTime.tryParse(b['date']);
              if (timeA != null && timeB != null) {
                return timeB.compareTo(timeA); // الأحدث أولًا
              }
              return b['date'].compareTo(a['date']);
            });

          if (filteredRecords.isEmpty) {
            return const Center(child: Text("🚫 لا توجد نتائج للبحث"));
          }

          return ListView.builder(
            itemCount: filteredRecords.length,
            itemBuilder: (context, idx) {
              final record =
                  Map<String, dynamic>.from(filteredRecords[idx]['data']);
              final List<String> imagePaths =
                  record.containsKey('imagePaths') &&
                          record['imagePaths'] is List
                      ? List<String>.from(record['imagePaths'])
                      : [];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text("📅 التاريخ: ${filteredRecords[idx]['date']}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("👤 اسم العميل: ${record['clientName']}"),
                      Text("📦 الصنف: ${record['productName']}"),
                      Text("🔢 كود الصنف: ${record['productCode'] ?? ''}"),
                      Text(
                          "📏 المقاس: طول ${record['length']} × عرض ${record['width']} × ارتفاع ${record['height']}"),
                      if (record['isQuarterSize'] == true)
                        Text(
                          "(${record['isQuarterWidth'] == true ? 'عرض' : 'طول'})",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      if (imagePaths.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: SizedBox(
                            height: 60,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: imagePaths.length,
                              itemBuilder: (context, imgIndex) {
                                final imagePath = imagePaths[imgIndex];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  child: FutureBuilder<bool>(
                                    future: File(imagePath).exists(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const SizedBox.square(
                                          dimension: 50,
                                          child: Center(
                                              child:
                                                  CircularProgressIndicator()),
                                        );
                                      }
                                      if (snapshot.hasData &&
                                          snapshot.data == true) {
                                        return Image.file(
                                          File(imagePath),
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        );
                                      } else {
                                        return const Icon(Icons.broken_image,
                                            size: 30, color: Colors.red);
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 👇 أيقونة العين - تعرض بيانات المقاس
                      IconButton(
                        icon: const Icon(Icons.remove_red_eye,
                            color: Colors.orange),
                        onPressed: () => _showSizeDetails(context, record),
                      ),
                      IconButton(
                        icon: const Icon(Icons.print, color: Colors.purple),
                        onPressed: () =>
                            _navigateToInkReportWithSheetData(context, record),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.green),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SheetSizeScreen(
                                existingData: record,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          savedSheetSizesBox
                              .delete(filteredRecords[idx]['key']);
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
    );
  }
}
