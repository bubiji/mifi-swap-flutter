# MifiSwap-native-app

> MifiSwap native application of flutter : [HomePage](https://www.mifiswap.org/)

MifiSwap for Android, IOS, powered by [Flutter](https://flutter.dev/), the Dart SDK from another repo [mifi_swap dart](https://github.com/bubiji/mifi_swap_dart_sdk).


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
- [4swap-Web-vue](https://github.com/fox-one/4swap-web)  
- [SDK golang](https://github.com/fox-one/4swap-sdk-go) 
- [4Swap Webside](https://app.4swap.org/#/pool)  
- [flutter dart package](https://pub.dev/publishers/mixin.dev/packages)  
- [mixin flutter](https://github.com/MixinNetwork/flutter-app)  

- [pando-4swap文档](https://docs.pando.im/developer/intro)
- [Web代码(vue)](https://github.com/fox-one/4swap-web)
- [SDK代码 golang](https://github.com/fox-one/4swap-sdk-go)
- [4Swap Webside](https://app.4swap.org/#/pool)
- [flutter dart包地址](https://pub.dev/publishers/mixin.dev/packages)
- [mixin的flutter项目](https://github.com/MixinNetwork/flutter-app)
- [4swap-flutter-app](https://github.com/bubiji/4swap-flutter-app)
- [4swap_sdk_dart](https://github.com/bubiji/4swap_sdk_dart)

``` bash
flutter analyze --watch
dart run build_runner build
flutter pub run flutter_native_splash:create
flutter pub run intl_utils:generate
dart pub global activate assets_generator
$HOME/.pub-cache/bin/agen
```