# Keep Flutter entry points and plugin registrants.
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Kotlin metadata used by reflection in some dependencies.
-keep class kotlin.Metadata { *; }

# Keep model classes used in JSON serialization/deserialization.
-keepclassmembers class ** {
    @com.google.gson.annotations.SerializedName <fields>;
}
