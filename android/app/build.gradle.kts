import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.plugin.compose")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Add the Google services Gradle plugin
    id("com.google.gms.google-services")
    // Add the Crashlytics Gradle plugin
    id("com.google.firebase.crashlytics")
    // Add the Performance Monitoring Gradle plugin
    id("com.google.firebase.firebase-perf")
}

// Release signing is driven by android/keystore.properties, which CI decodes from
// secrets and which never lands in git. When the file is absent (fresh clone,
// local dev) we fall back to the debug keys so `flutter run --release` still works.
val keystorePropertiesFile = rootProject.file("keystore.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.exists()) {
        load(FileInputStream(keystorePropertiesFile))
    }
}
val hasReleaseSigning = keystorePropertiesFile.exists() &&
    keystoreProperties.getProperty("storeFile") != null

android {
    namespace = "com.np.hamrofutsal"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    defaultConfig {
        applicationId = "com.np.hamrofutsal"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                storeFile = rootProject.file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }

    buildFeatures {
        compose = true
    }
}

flutter {
    source = "../.."
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation(platform("androidx.compose:compose-bom:2025.01.01"))
    implementation("androidx.activity:activity-compose:1.10.1")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-graphics")
    implementation("androidx.compose.ui:ui-tooling-preview")
    debugImplementation("androidx.compose.ui:ui-tooling")
    
    // Import the Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:34.14.1"))
    
    // Firebase Analytics
    implementation("com.google.firebase:firebase-analytics")
    
    // Firebase Cloud Messaging (FCM)
    implementation("com.google.firebase:firebase-messaging")
    
    // Firebase Authentication
    implementation("com.google.firebase:firebase-auth")
    
    // Firebase Firestore
    implementation("com.google.firebase:firebase-firestore")
    
    // Firebase Storage
    implementation("com.google.firebase:firebase-storage")
    
    // Firebase Crashlytics
    implementation("com.google.firebase:firebase-crashlytics")
    
    // Firebase Performance Monitoring
    implementation("com.google.firebase:firebase-perf")
    
    // Firebase Remote Config
    implementation("com.google.firebase:firebase-config")
}

tasks.matching { it.name.matches(Regex("process.+Manifest")) }.configureEach {
    doLast {
        val adIdPermissions = listOf(
            """<uses-permission android:name="com.google.android.gms.permission.AD_ID" />""",
            """<uses-permission android:name="android.permission.ACCESS_ADSERVICES_AD_ID" />""",
            """<uses-permission android:name="android.permission.ACCESS_ADSERVICES_ATTRIBUTION" />""",
        )

        layout.buildDirectory
            .asFile
            .get()
            .walkTopDown()
            .filter { it.isFile && it.name == "AndroidManifest.xml" }
            .forEach { manifest ->
                val original = manifest.readText()
                val cleaned = adIdPermissions.fold(original) { text, permission ->
                    text.replace(Regex("""\s*${Regex.escape(permission)}"""), "")
                }
                if (cleaned != original) {
                    manifest.writeText(cleaned)
                }
            }
    }
}
