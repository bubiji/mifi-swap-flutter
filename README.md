# 4swap-native-app

> 4swap native application of flutter

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
## Build Requirement

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


## Reference

- <https://pando.im/>  
- [pando-4swap-doc](https://docs.pando.im/developer/intro)  
- [4swap-Web-vue)](https://github.com/fox-one/4swap-web)  
- [SDK golang](https://github.com/fox-one/4swap-sdk-go) 
- [4Swap Webside](https://app.4swap.org/#/pool)  
- [flutter dart package](https://pub.dev/publishers/mixin.dev/packages)  
- [mixin flutter](https://github.com/MixinNetwork/flutter-app)
