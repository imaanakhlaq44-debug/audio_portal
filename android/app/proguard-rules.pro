# Flutter / plugins
-keep class io.flutter.** { *; }
-keep class com.ryanheise.audioservice.** { *; }
-keep class com.ryanheise.just_audio.** { *; }
-dontwarn io.flutter.embedding.**
# Google Play Core (deferred components) is not used but referenced by Flutter
-dontwarn com.google.android.play.core.**
