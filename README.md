# flutter_loading_animation_kit

This package contains a set of loading animation kit which is implemented purely in dart and custom canvas. No third party assets are used.

## Package under development.

The package is still under development. Use it with caution because there may be breaking changes in the future.

## Gallery

![](https://s4.gifyu.com/images/loading-kit-demo.gif)

## Getting started

Depend on it

Run this command:

With Flutter:

```
flutter pub add flutter_loading_animation_kit
```

This will add a line like this to your package's pubspec.yaml (and run an implicit flutter pub get):

```yaml
  dependencies:
    flutter_loading_animation_kit: ^latest version
```

Import it

```dart
import 'package:flutter_loading_animation_kit/flutter_loading_animation_kit.dart';
```

## Usage

Import it

```dart
import 'package:flutter_loading_animation_kit/flutter_loading_animation_kit.dart';
```

Then add a widget provided by this package

```dart
Scaffold(
  body: Center(
    child: FourCirclePulse(),
  ),
)
```

You can also tweak various properties to modify the widget to your choice.


```dart
Scaffold(
  body: Center(
    child: FourCirclePulse(
      circleColor: Colors.blue, //The color of the circles
      dimension: 48.0, // The size of the widget.
      turns: 2, //Turns in each loop
      loopDuration: const Duration(seconds: 1), // Duration of each loop
      curve: Curves.linear, //Curve of the animation
    ),
  ),
)
```

In case you can't remember the loading widgets name, there is a class which provides all the loading animations via static methods.

```dart
Scaffold(
  body: Center(
    child: LoadingAnimationKit.fourCirclePulse(
      circleColor: Colors.blue, //The color of the circles
      dimension: 48.0, // The size of the widget.
      turns: 2, //Turns in each loop
      loopDuration: const Duration(seconds: 1), // Duration of each loop
      curve: Curves.linear, //Curve of the animation
    ),
  ),
)
```

## How to contribute

- Fork the repo
- Create a new brunch
- Do what you want
- Commit changes
- Open pull request

**NB: Try to follow the original code style. Study the existing classes and methods before editing. If you need to ask anything, contact me at sushmoyr@gmail.com**

