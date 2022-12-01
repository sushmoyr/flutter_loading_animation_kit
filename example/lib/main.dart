import 'package:flutter/material.dart';
import 'package:flutter_loading_animation_kit/flutter_loading_animation_kit.dart';

import 'helpers.dart';

void main() {
  runApp(ThemeColorChooser(
      key: ThemeColorChooser.themeKey,
      color: Colors.blue,
      child: const MyApp()));
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
