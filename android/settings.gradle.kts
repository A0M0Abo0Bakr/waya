// android/settings.gradle.kts

pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
    plugins {
        // Loader عشان Gradle يعرف يجيب Flutter plugin
        id("dev.flutter.flutter-plugin-loader") version "1.0.0"
        // Android Gradle Plugin (AGP) – ضبّط الإصدار حسب Gradle Wrapper
        id("com.android.application")     version "8.7.0" apply false
        // Kotlin Android Plugin – ضبّط الإصدار حسب Kotlin
        id("org.jetbrains.kotlin.android") version "1.8.22" apply false
    }
}

rootProject.name = "waya"
include(":app")
