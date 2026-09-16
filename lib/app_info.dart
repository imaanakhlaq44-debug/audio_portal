/// The version shown inside the app.
///
/// Duplicated from `pubspec.yaml` rather than read through a plugin: the app
/// deliberately ships no dependency it does not need, and `package_info_plus`
/// would add platform code to display one string. `test/app_info_test.dart`
/// parses the pubspec and fails if the two ever drift apart, which is the
/// part that actually matters.
const String appVersion = '1.2.0';

const String appName = 'Qissora';
