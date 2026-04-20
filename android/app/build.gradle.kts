plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.echorandev.spark"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.echorandev.spark"
        minSdk = 24
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // =========================================================
    // Flavor 配置
    // =========================================================
    flavorDimensions += "environment"

    productFlavors {
        // 🛠️ 调试版 (dev)
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            // 覆盖 App 名称请在 src/dev/res/values/strings.xml 中定义
            manifestPlaceholders["appName"] = "灵光 Dev"
        }

        // 🚀 正式版 (prod)
        create("prod") {
            dimension = "environment"
            // prod 使用默认 applicationId，无后缀
            manifestPlaceholders["appName"] = "灵光"
        }
    }

    buildTypes {
        debug {
            isDebuggable = true
            isMinifyEnabled = false
        }
        release {
            isDebuggable = false
            isMinifyEnabled = true
            isShrinkResources = true
            // TODO: 配置正式签名
            signingConfig = signingConfigs.getByName("debug")
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}
