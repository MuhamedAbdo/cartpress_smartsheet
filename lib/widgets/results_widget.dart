import 'package:flutter/material.dart';

class ResultsWidget extends StatelessWidget {
  final double? a1;
  final double? t1;
  final double? a2;
  final double? t2;
  final bool isWidthActive;
  final List<String> labels;

  const ResultsWidget({
    Key? key,
    required this.a1,
    required this.t1,
    required this.a2,
    required this.t2,
    required this.isWidthActive,
    required this.labels,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "${labels[0]}: ${a1?.toStringAsFixed(2) ?? ''}",
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 10),
        Text(
          "${labels[1]}: ${t1?.toStringAsFixed(2) ?? ''}",
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 10),
        Text(
          "${labels[2]}: ${a2?.toStringAsFixed(2) ?? ''}",
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 10),
        Text(
          "${labels[3]}: ${t2?.toStringAsFixed(2) ?? ''}",
          style: const TextStyle(fontSize: 18),
        ),
      ],
    );
  }
}
