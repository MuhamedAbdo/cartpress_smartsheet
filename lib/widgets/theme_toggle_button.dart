import 'package:cartpress_smartsheet/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return IconButton(
      icon:
          Icon(themeProvider.isDarkTheme ? Icons.dark_mode : Icons.light_mode),
      onPressed: () {
        themeProvider.toggleTheme();
      },
    );
  }
}
