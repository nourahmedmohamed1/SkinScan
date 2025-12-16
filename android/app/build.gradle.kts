plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.skinscan"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // A widely stable version for late 2025

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        // Updated to use simple string "17" to avoid deprecation errors
        jvmTarget = "17"
    }

    defaultConfig {
        // Unique Application ID
        applicationId = "com.example.skincarescan1"

        // Correct syntax for Kotlin Script (.kts)
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("release") {
            // Signing with the debug keys for now
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
