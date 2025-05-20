import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CameraQualitySettingsScreen extends StatefulWidget {
  static const String routeName = '/camera-quality-settings';

  const CameraQualitySettingsScreen({super.key});

  @override
  State<CameraQualitySettingsScreen> createState() =>
      _CameraQualitySettingsScreenState();
}

class _CameraQualitySettingsScreenState
    extends State<CameraQualitySettingsScreen> {
  String? selectedQuality;

  final List<String> qualities = ['low', 'medium', 'high'];

  Future<void> _saveQuality(String quality) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cameraQuality', quality);
    setState(() => selectedQuality = quality);
  }

  Future<void> _loadQuality() async {
    final prefs = await SharedPreferences.getInstance();
    setState(
        () => selectedQuality = prefs.getString('cameraQuality') ?? 'medium');
  }

  @override
  void initState() {
    super.initState();
    _loadQuality();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "📷 جودة الكاميرا",
        ),
      ),
      body: ListView(
        children: qualities.map((quality) {
          return RadioListTile<String>(
            title: Text(quality.toUpperCase()),
            value: quality,
            groupValue: selectedQuality,
            onChanged: (value) => _saveQuality(value!),
            activeColor: Theme.of(context).primaryColor,
          );
        }).toList(),
      ),
    );
  }
}
