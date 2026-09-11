import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.dogadagezi.dogada_gezi"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.dogadagezi.dogada_gezi"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            storeFile = keystoreProperties.getProperty("storeFile")?.let { path ->
                val f = file(path)
                if (f.isAbsolute) f else if (f.exists()) f else rootProject.file(path)
            }
            storePassword = keystoreProperties.getProperty("storePassword")
        }
    }

    buildTypes {
        release {
            // Google Play release derlemesi için daima release signingConfig kullanılır.
            // key.properties veya keystore eksik olduğunda sessizce debug signing'e fallback YAPILMAZ.
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

tasks.matching { it.name.startsWith("validateSigning") && it.name.endsWith("Release") }.configureEach {
    doFirst {
        if (!keystorePropertiesFile.exists()) {
            throw GradleException(
                "Release build hatası: 'android/key.properties' dosyası bulunamadı. " +
                "Lütfen 'android/key.properties.example' dosyasını referans alarak 'android/key.properties' oluşturun ve keystore bilgilerinizi tanımlayın."
            )
        }
        val storeFilePath = keystoreProperties.getProperty("storeFile")
        val resolvedStoreFile = storeFilePath?.let { path ->
            val f = file(path)
            if (f.isAbsolute) f else if (f.exists()) f else rootProject.file(path)
        }
        if (resolvedStoreFile == null || !resolvedStoreFile.exists()) {
            throw GradleException(
                "Release build hatası: 'android/key.properties' dosyasında belirtilen keystore dosyası " +
                "(${resolvedStoreFile?.path ?: storeFilePath ?: "tanımsız"}) bulunamadı."
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
