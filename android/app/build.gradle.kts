plugins {
    id("com.android.application") // Seu plugin de aplicação Android
    id("kotlin-android")          // Se você estiver usando Kotlin
    id("dev.flutter.flutter-gradle-plugin") // Se for um projeto Flutter
    id("com.google.gms.google-services") // Aplica o plugin Google Services
}

android {
    namespace = "com.barreto.dev.petverse"
    compileSdk = 35
    ndkVersion = "27.0.12077973"
 
    defaultConfig {
        multiDexEnabled = true
    }

    compileOptions {
        // Flag to enable support for the new language APIs
        isCoreLibraryDesugaringEnabled = true
        // Sets Java compatibility to Java 11
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
  
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.barreto.dev.petverse"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    packaging {
        resources.excludes.add("/META-INF/{AL2.0,LGPL2.1}")
    }

}

flutter {
    source = "../.."
}
 dependencies {
    // Adicione esta linha para o desugaring das bibliotecas principais 
     coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}