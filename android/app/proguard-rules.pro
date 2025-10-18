# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep generic signature of Call, Response (R8 full mode strips signatures from non-kept items)
-keep,allowobfuscation,allowshrinking interface retrofit2.Call
-keep,allowobfuscation,allowshrinking class retrofit2.Response

# With R8 full mode generic signatures are stripped for classes that are not kept
-keep,allowobfuscation,allowshrinking class kotlin.coroutines.Continuation

# Provider
-keep class androidx.lifecycle.** { *; }

# SQLite
-keep class androidx.sqlite.** { *; }

# Image processing
-keep class androidx.exifinterface.** { *; }

# TensorFlow Lite
-keep class org.tensorflow.lite.** { *; }
-keep interface org.tensorflow.lite.** { *; }

# Google ML Kit / Vision
-keep class com.google.android.gms.** { *; }
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.android.gms.**
-dontwarn com.google.mlkit.**

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep custom model classes (if you have any data classes)
-keep class com.homeai.home_ai_index.data.** { *; }
-keep class com.homeai.home_ai_index.models.** { *; }
