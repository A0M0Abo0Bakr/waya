// android/app/build.gradle.kts

plugins {
    id("org.jetbrains.kotlin.android")
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin") version "2.3.0"
}

android {
    namespace      = "com.waya"
    compileSdk     = 33
    ndkVersion     = "27.0.12077973"
    compileSdkVersion 34


    defaultConfig {
        applicationId = "com.waya"
        minSdk        = 21
        targetSdk     = 33
        versionCode   = 1
        versionName   = "1.0.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlinOptions {
        jvmTarget = "11"
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
