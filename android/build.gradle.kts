// build.gradle.kts (корневой)

plugins {
    // Другие плагины, если есть
    // Здесь не нужно подключать google-services, он подключается на уровне app
}

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.1.1")
        classpath("com.google.gms:google-services:4.4.4") // <- добавляем Google Services
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Ниже оставляем твои настройки buildDir и задачи clean
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
