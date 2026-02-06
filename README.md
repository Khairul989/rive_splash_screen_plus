# rive_splash_screen

[![pub package](https://img.shields.io/pub/v/rive_splash_screen.svg)](https://pub.dartlang.org/packages/rive_splash_screen)

Facilitator for having a Splash screen with a Rive animation until some work has been done for the initialization of the app

## Compatibility

- Flutter: 3.0.0+ (tested on 3.35.7 and latest stable)
- Dart: 3.0.0+
- Rive: uses `rive_loading_plus` (modern Rive 0.14.x)

## Android 15 16KB Page Size Support

This package ships no native code, but your app may include native libraries via Flutter/Rive.
Use the included checker to validate your release APK:

```bash
./check_elf_alignment.sh example/build/app/outputs/flutter-apk/app-release.apk
```

## Usage

### Navigation

The splash screen will show the animation and push the new route you gave once it's finish, by default it does a fade animation but you can customize it by using `transitionsBuilder`

```dart
SplashScreen.navigate(
    name: 'intro.riv',
    next: (_) => MyHomePage(title: 'Flutter Demo Home Page'),
    until: () => Future.delayed(Duration(seconds: 5)),
    startAnimation: '1',
),
```

### Callback

The splash screen will show the animation and call the `onFinished` callback when it's finish.

```dart
SplashScreen.callback(
    name: 'intro.riv',
    onSuccess: (data) {
      //data is the optional data returned by until callback function
      Navigator.of(context).pushReplacement(PageRouteBuilder(pageBuilder: (_,__,___) => MyHomePage(title: 'Flutter Demo Home Page')));
    },
    onError: (err, stack) {
      //error throw by until callback function
    },
    loopAnimation: '1',
    until: () => Future.delayed(Duration(seconds: 1)),
    endAnimation: '1',
),
```

### API 

`name` : path/name of the Rive animation

`next` : screen to show once animation is finished as widget builder

`loopAnimation`: animation name to run, default same as first param

`startAnimation`: animation name to run once before going into loop

`endAnimation`: animation name to run once `until` is complete

`until`: callback that return a future to process your initialization

`isLoading`: alternative to `until` if you want to manage loading state with a boolean

`height`: force the height of the Rive animation, by default it take the all place available

`width`: force the width of the Rive animation, by default it take the all place available

`alignment`: alignment of the Rive animation, center by default

`transitionsBuilder` transition to apply when showing `next`

### Available animation mode

### Only one animation 
Basically you have one animation to show and then just need to stay at last frame. In order to do that only specify the `startAnimation` 

### Start and loop animation 
Your animation have an intro and a loop state, in order to do that only specify the `startAnimation` and `loopAnimation`

### End and loop animation 
Your animation have a finish and a loop state, in order to do that only specify the `endAnimation` and `loopAnimation`

### Start and end animation 
Your animation have an intro and a finish that should stay on the last frame, in order to do that only `startAnimation` and `endAnimation`

### Start, end and loop animation 
Your animation have an intro, a finish and a loop state, in order to do that specify the `startAnimation`, `endAnimation` and `loopAnimation`
