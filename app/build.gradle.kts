import java.time.Instant
import java.util.Properties

plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.compose.compiler)
}

fun git(vararg args: String): String = try {
    providers.exec {
        commandLine("git", *args)
        isIgnoreExitValue = true
    }.standardOutput.asText.get().trim().ifBlank { "unknown" }
} catch (_: Exception) {
    "unknown"
}

val versionProps = Properties().apply {
    rootProject.file("version.properties").inputStream().use(::load)
}
val baseVersionName = versionProps.getProperty("VERSION_NAME", "0.1.0")
val baseVersionCode = versionProps.getProperty("VERSION_CODE", "1").toInt()
val buildNumber = providers.environmentVariable("BUILD_NUMBER").orNull ?: Instant.now().epochSecond.toString()
val gitSha = git("rev-parse", "--short=12", "HEAD")
val gitDirty = git("status", "--porcelain").let { if (it == "unknown") "unknown" else if (it.isBlank()) "clean" else "dirty" }
val buildTimeUtc = Instant.now().toString()

val qaPropsFile = rootProject.file("qa-signing.properties")
val qaProps = Properties()
val hasQaSigning = qaPropsFile.isFile.also { exists ->
    if (exists) qaPropsFile.inputStream().use(qaProps::load)
}

android {
    namespace = "com.example.agentictemplate"
    compileSdk = 37

    defaultConfig {
        applicationId = "com.example.agentictemplate"
        minSdk = 26
        targetSdk = 37
        versionCode = baseVersionCode
        versionName = baseVersionName
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"

        buildConfigField("String", "GIT_SHA", "\"$gitSha\"")
        buildConfigField("String", "GIT_STATE", "\"$gitDirty\"")
        buildConfigField("String", "BUILD_NUMBER", "\"$buildNumber\"")
        buildConfigField("String", "BUILD_TIME_UTC", "\"$buildTimeUtc\"")
    }

    signingConfigs {
        if (hasQaSigning) {
            create("qa") {
                storeFile = rootProject.file(qaProps.getProperty("storeFile"))
                storePassword = qaProps.getProperty("storePassword")
                keyAlias = qaProps.getProperty("keyAlias")
                keyPassword = qaProps.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        getByName("debug") {
            applicationIdSuffix = ".debug"
            versionNameSuffix = "-debug"
            buildConfigField("String", "BUILD_CHANNEL", "\"debug\"")
            buildConfigField("String", "SIGNING_MODE", "\"debug\"")
        }
        create("qa") {
            initWith(getByName("debug"))
            applicationIdSuffix = ".qa"
            versionNameSuffix = "-qa.$buildNumber"
            matchingFallbacks += listOf("debug")
            signingConfig = if (hasQaSigning) signingConfigs.getByName("qa") else signingConfigs.getByName("debug")
            buildConfigField("String", "BUILD_CHANNEL", "\"qa\"")
            buildConfigField("String", "SIGNING_MODE", if (hasQaSigning) "\"persistent-qa\"" else "\"debug-fallback\"")
        }
        getByName("release") {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            buildConfigField("String", "BUILD_CHANNEL", "\"release\"")
            buildConfigField("String", "SIGNING_MODE", "\"release-external\"")
            // Release signing is intentionally not configured in the template.
            // Configure a protected release signing flow only when publishing an app.
        }
    }

    buildFeatures {
        compose = true
        buildConfig = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    packaging {
        resources.excludes += setOf("/META-INF/{AL2.0,LGPL2.1}")
    }

    testOptions {
        managedDevices {
            localDevices {
                create("ciApi30Atd") {
                    device = "Pixel 2"
                    apiLevel = 30
                    systemImageSource = "aosp-atd"
                }
                create("ciApi37") {
                    device = "Pixel 2"
                    apiLevel = 37
                    systemImageSource = "aosp"
                }
            }
        }
    }
}

composeCompiler {
    reportsDestination = layout.buildDirectory.dir("compose_compiler")
}

dependencies {
    implementation(project(":core:domain"))

    val composeBom = platform(libs.compose.bom)
    implementation(composeBom)
    androidTestImplementation(composeBom)

    implementation(libs.activity.compose)
    implementation(libs.lifecycle.viewmodel.compose)
    implementation(libs.lifecycle.viewmodel.ktx)
    implementation(libs.lifecycle.runtime.compose)
    implementation(libs.compose.ui)
    implementation(libs.compose.ui.tooling.preview)
    implementation(libs.compose.material3)

    debugImplementation(libs.compose.ui.tooling)
    debugImplementation(libs.compose.ui.test.manifest)
    add("qaImplementation", libs.compose.ui.test.manifest)

    testImplementation(libs.junit4)

    androidTestImplementation(libs.androidx.test.runner)
    androidTestImplementation(libs.androidx.test.ext.junit)
    androidTestImplementation(libs.espresso.core)
    androidTestImplementation(libs.compose.ui.test.junit4)
}
