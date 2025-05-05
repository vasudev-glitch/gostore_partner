val kotlinVersion = "1.9.22"

group = "dev.fluttercommunity.plus.deviceinfo"
version = "1.0"

buildscript {
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:8.2.0")
    }
}

plugins {
    id("com.android.library")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "dev.fluttercommunity.plus.deviceinfo"
    compileSdk = 34

    defaultConfig {
        minSdk = 23
        targetSdk = 34
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildFeatures {
        buildConfig = false
    }
}

repositories {
    google()
    mavenCentral()
    maven {
        url = uri("${project.findProperty("flutter.sdk")}/bin/cache/artifacts/engine")
    }
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib:$kotlinVersion")
    implementation("androidx.core:core-ktx:1.10.1")
    implementation("androidx.annotation:annotation:1.7.0")
}

afterEvaluate {
    configurations.all {
        resolutionStrategy.eachDependency {
            if (requested.group == "io.flutter" &&
                (requested.name == "flutter_embedding_debug" || requested.name == "flutter_embedding_release")
            ) {
                useVersion("1.0.0-18b71d647a292a980abb405ac7d16fe1f0b20434")
            }
        }
    }
}

