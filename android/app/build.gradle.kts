// android/app/build.gradle.kts

plugins {
    id("com.android.application")
    id("com.google.gms.google-services") // <- подключаем плагин Firebase к модулю
}

android {
    compileSdk = 34

    defaultConfig {
        applicationId = "com.example.myapp" // замени на свой package
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
    // Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:34.4.0"))

    // Firebase продукты
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-analytics")
}
