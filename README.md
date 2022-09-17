# 4swap-native

> 4swap native application of flutter

[![Dart CI](https://github.com/bubiji/4swap-flutter/workflows/Dart%20CI/badge.svg)](https://github.com/bubiji/4swap-flutter/actions)

4swap for Android, IOS, powered by [Flutter](https://flutter.dev/), the Dart SDK from another repo [4swap dart](https://github.com/bubiji/4swap_dart_sdk).


## Quick start

``` bash
# Install straight flutter from GitHub
$ git clone https://github.com/flutter/flutter.git -b stable

# update flutter
$ flutter upgrade

```

## Build Setup

``` bash
flutter run -d ios
flutter run -d android
```
## build Requirement

there are some addition library needed.
``` bash
flutter pub get
flutter pub run flutter_native_splash:create

cd ios
pod install
```
## Release

``` bash
flutter build ios --release
flutter build android --release
```
For detailed explanation on how things work, checkout [flutter docs](https://docs.flutter.dev/).
