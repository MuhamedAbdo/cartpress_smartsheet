// terms_and_policy_screen.dart
import 'package:flutter/material.dart';

class TermsAndPolicyScreen extends StatelessWidget {
  final String title;
  final String content;

  const TermsAndPolicyScreen({
    Key? key,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            content,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
          ),
        ),
      ),
    );
  }
}
