// settings.gradle.kts

pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val sdkPath = properties.getProperty("flutter.sdk")
        require(!sdkPath.isNullOrBlank()) { "flutter.sdk not set in local.properties" }
        sdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
        maven {
            url = uri("https://storage.googleapis.com/download.flutter.io")
        }
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.2.0" apply false
    id("com.google.gms.google-services") version "4.4.2" apply false
    id("org.jetbrains.kotlin.android") version "1.9.22" apply false
}

dependencyResolutionManagement {
    // ✅ Plugin projects will prefer settings.gradle-defined repositories
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)

    repositories {
        google()
        mavenCentral()

        // ✅ Hosted Flutter artifacts (from Google's storage)
        maven {
            url = uri("https://storage.googleapis.com/download.flutter.io")
        }

        // ✅ Local Flutter engine artifacts used by plugin overrides
        val flutterSdk = providers.gradleProperty("flutter.sdk").getOrElse("")
        if (flutterSdk.isNotBlank()) {
            maven {
                url = uri("$flutterSdk/bin/cache/artifacts/engine")
            }
        }
    }
}

// ✅ Force repository resolution injection into all local plugins
gradle.beforeProject {
    project.repositories.clear()
    project.repositories.google()
    project.repositories.mavenCentral()
    project.repositories.maven {
        url = uri("https://storage.googleapis.com/download.flutter.io")
    }

    val flutterSdk = project.findProperty("flutter.sdk")?.toString()
    if (!flutterSdk.isNullOrBlank()) {
        project.repositories.maven {
            url = uri("$flutterSdk/bin/cache/artifacts/engine")
        }
    }
}

include(":app")
