import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

val keystoreProperties = Properties().apply {
    val propertiesFile = rootProject.file("key.properties")
    if (propertiesFile.exists()) {
        propertiesFile.inputStream().use { load(it) }
    }
}

val hasReleaseSigning = listOf(
    "keyAlias",
    "keyPassword",
    "storeFile",
    "storePassword",
).all { !keystoreProperties.getProperty(it).isNullOrBlank() }

android {
    namespace = "com.example.reki_mvp"
    compileSdk = 36
    ndkVersion = "29.0.13113456"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.reki_mvp"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Google OAuth server client ID (Web OAuth client from Google Cloud Console).
        // Provide via key.properties / ~/.gradle/gradle.properties as GOOGLE_WEB_CLIENT_ID,
        // or with -PGOOGLE_WEB_CLIENT_ID=... on the Gradle command line. The release
        // build must NOT ship with this unset (Google sign-in without it fails at runtime).
        val googleWebClientId = (project.findProperty("GOOGLE_WEB_CLIENT_ID") as String?)
            ?: keystoreProperties.getProperty("googleWebClientId")
            ?: System.getenv("GOOGLE_WEB_CLIENT_ID")
            ?: "GOOGLE_WEB_CLIENT_ID_NOT_SET"
        manifestPlaceholders["googleWebClientId"] = googleWebClientId
        if (googleWebClientId == "GOOGLE_WEB_CLIENT_ID_NOT_SET") {
            logger.warn(
                "WARNING: GOOGLE_WEB_CLIENT_ID is not configured; " +
                    "Google sign-in backed by the server client ID will not work in this build.",
            )
        }

        val googleMapsApiKey = (project.findProperty("GOOGLE_MAPS_API_KEY") as String?)
            ?: keystoreProperties.getProperty("googleMapsApiKey")
            ?: System.getenv("GOOGLE_MAPS_API_KEY")
            ?: "GOOGLE_MAPS_API_KEY_NOT_SET"
        manifestPlaceholders["googleMapsApiKey"] = googleMapsApiKey
        if (googleMapsApiKey == "GOOGLE_MAPS_API_KEY_NOT_SET") {
            logger.warn(
                "WARNING: GOOGLE_MAPS_API_KEY is not configured; maps will not work in this build.",
            )
        }
    }

    signingConfigs {
        create("release") {
            if (hasReleaseSigning) {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = project.file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
            } else {
                initWith(getByName("debug"))
                logger.warn(
                    "WARNING: android/key.properties is missing or incomplete; " +
                        "this release build is signed with the debug certificate and must not be published.",
                )
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
