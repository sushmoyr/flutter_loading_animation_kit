import 'package:flutter/material.dart';

final GlobalKey<ThemeColorChooserState> _themeKey = GlobalKey();

class ThemeColorChooser extends StatefulWidget {
  const ThemeColorChooser({
    Key? key,
    required this.color,
    required this.child,
  }) : super(key: key);

  final MaterialColor color;
  final Widget child;

  static GlobalKey<ThemeColorChooserState> get themeKey => _themeKey;

  @override
  State<ThemeColorChooser> createState() => ThemeColorChooserState();
}

class ThemeColorChooserState extends State<ThemeColorChooser> {
  late MaterialColor color = widget.color;

  void updateColor(MaterialColor color) => setState(() {
        this.color = color;
      });

  @override
  Widget build(BuildContext context) {
    return ThemeColor(color: color, child: widget.child);
  }
}

class ThemeColor extends InheritedWidget {
  const ThemeColor({
    Key? key,
    required Widget child,
    required this.color,
  }) : super(key: key, child: child);

  final MaterialColor color;

  static ThemeColor of(BuildContext context) {
    final ThemeColor? result =
        context.dependOnInheritedWidgetOfExactType<ThemeColor>();
    assert(result != null, 'No ThemeColor found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(covariant ThemeColor oldWidget) {
    return oldWidget.color != color;
  }
}
