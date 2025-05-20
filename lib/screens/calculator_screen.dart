import 'package:cartpress_smartsheet/drawers/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _expression = "";
  String _result = "";
  bool _isResultDisplayed = false;

  void _onButtonPressed(String value) {
    setState(() {
      if (value == "C") {
        _expression = "";
        _result = "";
        _isResultDisplayed = false;
      } else if (value == "=") {
        try {
          String formattedExpression = _expression
              .replaceAll('x', '*')
              .replaceAll('÷', '/')
              .replaceAll('%', '/100');

          // ignore: deprecated_member_use
          Parser p = Parser();
          Expression exp = p.parse(formattedExpression);
          ContextModel cm = ContextModel();
          double eval = exp.evaluate(EvaluationType.REAL, cm);
          _result = eval.toString();
          _isResultDisplayed = true;
        } catch (e) {
          _result = "خطأ";
          _isResultDisplayed = true;
        }
      } else if (value == "⌫") {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      } else {
        if (_isResultDisplayed) {
          if (RegExp(r'[0-9.]').hasMatch(value)) {
            _expression = value;
            _result = "";
          } else {
            _expression = _result + value;
            _result = "";
          }
        } else {
          _expression += value;
        }
        _isResultDisplayed = false;
      }
    });
  }

  Widget _buildButton(String text) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () => _onButtonPressed(text),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(text, style: const TextStyle(fontSize: 24)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(), // ✅ تم الإضافة هنا

      appBar: AppBar(
        centerTitle: true,
        title: const Text("الآلة الحاسبة"),
        actions: const [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(_expression, style: const TextStyle(fontSize: 32)),
                    const SizedBox(height: 10),
                    Text(
                      _result,
                      style: const TextStyle(
                          fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            Row(children: [
              _buildButton("7"),
              const SizedBox(width: 8),
              _buildButton("8"),
              const SizedBox(width: 8),
              _buildButton("9"),
              const SizedBox(width: 8),
              _buildButton("÷"), // ✅ رمز القسمة الجديد
            ]),
            const SizedBox(height: 8),
            Row(children: [
              _buildButton("4"),
              const SizedBox(width: 8),
              _buildButton("5"),
              const SizedBox(width: 8),
              _buildButton("6"),
              const SizedBox(width: 8),
              _buildButton("x"),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              _buildButton("1"),
              const SizedBox(width: 8),
              _buildButton("2"),
              const SizedBox(width: 8),
              _buildButton("3"),
              const SizedBox(width: 8),
              _buildButton("-"),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              _buildButton("C"),
              const SizedBox(width: 8),
              _buildButton("0"),
              const SizedBox(width: 8),
              _buildButton("%"),
              const SizedBox(width: 8),
              _buildButton("+"),
            ]),
            const SizedBox(height: 8),
            // ✅ السطر الجديد: [ . ] [ ⌫ ] [ = ]
            Row(
              children: [
                _buildButton("."),
                const SizedBox(width: 8),
                _buildButton("⌫"),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => _onButtonPressed("="),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("=", style: TextStyle(fontSize: 24)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
