## Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

## Play Core library (for deferred components)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

## Hive Database
-keep class * extends hive.HiveObject
-keep class hive.** { *; }
-keep class * implements hive.HiveObject { *; }

## Riverpod
-keep class * extends riverpod.** { *; }

## Gson (for JSON serialization)
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

## Keep model classes
-keep class com.islamictodo.islamic_todo_app.** { *; }

## Prevent obfuscation of native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

## Keep custom view constructors
-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet);
}

-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet, int);
}

## Keep setters in Views
-keepclassmembers public class * extends android.view.View {
   void set*(***);
   *** get*();
}

## Keep Activity subclasses
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider
-keep public class * extends android.app.backup.BackupAgentHelper
-keep public class * extends android.preference.Preference

## Adhan (Prayer Times)
-keep class com.batoulapps.adhan2.** { *; }

## Geolocator
-keep class com.baseflow.geolocator.** { *; }

## WorkManager
-keep class androidx.work.** { *; }
-keep interface androidx.work.** { *; }
-dontwarn androidx.work.**

## Notification
-keep class androidx.core.app.NotificationCompat** { *; }

## Remove logging in release builds
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}
