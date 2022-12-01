import 'package:flutter/material.dart';
import 'package:flutter_loading_animation_kit/flutter_loading_animation_kit.dart';

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

void main() {
  runApp(ThemeColorChooser(key: _themeKey, color: Colors.blue, child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: ThemeColor.of(context).color,
      ),
      home: const Gallery(),
    );
  }
}

class Gallery extends StatelessWidget {
  const Gallery({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery'),
      ),
      body: GridView(
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 300, crossAxisSpacing: 16, mainAxisSpacing: 16),
        children: [
          const FourCirclePulse(),
          YinAndYang(
            yangColor: Theme.of(context).colorScheme.primary,
          ),
          const RippleRing(),
          const LineEllipsis()
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          int idx =
              DateTime.now().millisecondsSinceEpoch % Colors.primaries.length;
          ThemeColorChooser.themeKey.currentState
              ?.updateColor(Colors.primaries[idx]);
        },
        child: const Icon(Icons.palette_outlined),
      ),
    );
  }
}
