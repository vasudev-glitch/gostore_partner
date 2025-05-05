import org.gradle.api.file.Directory

buildscript {
    repositories {
        google()
        mavenCentral()
        maven {
            url = uri(
                System.getenv("FLUTTER_STORAGE_BASE_URL")?.let {
                    "$it/download.flutter.io"
                } ?: "https://storage.googleapis.com/download.flutter.io"
            )
        }
    }

    dependencies {
        classpath("com.android.tools.build:gradle:8.2.0")
        classpath("com.google.gms:google-services:4.4.2")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.22") // ✅ Add this line
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven {
            url = uri(
                System.getenv("FLUTTER_STORAGE_BASE_URL")?.let {
                    "$it/download.flutter.io"
                } ?: "https://storage.googleapis.com/download.flutter.io"
            )
        }

        // ✅ Flutter engine jars for plugin overrides
        val flutterSdk = findProperty("flutter.sdk")?.toString()
        if (!flutterSdk.isNullOrBlank()) {
            maven {
                url = uri("$flutterSdk/bin/cache/artifacts/engine")
            }
        }
    }
}

// ✅ Force safe BouncyCastle version to avoid D8 crashes
subprojects {
    configurations.all {
        resolutionStrategy.eachDependency {
            if (requested.group == "org.bouncycastle" && requested.name == "bcprov-jdk15to18") {
                useVersion("1.68")
            }
        }
    }
}

// ✅ Unified build dir for local plugin overrides
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val subprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(subprojectBuildDir)
    project.evaluationDependsOn(":app")
}

// ✅ Clean
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
