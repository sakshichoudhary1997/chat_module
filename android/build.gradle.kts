buildscript {
    repositories {
        google() // Google's Maven repository for Firebase and other dependencies
        mavenCentral() // Maven Central repository for other dependencies
    }
    dependencies {
        // Add the Google Services classpath to ensure Firebase works
        classpath("com.google.gms:google-services:4.3.15") // Ensure this is the latest version
    }
}

allprojects {
    repositories {
        google() // Google's Maven repository for Firebase and other dependencies
        mavenCentral() // Maven Central repository for other dependencies
    }
}

rootProject.buildDir = file("../build")

subprojects {
    project.buildDir = file("${rootProject.buildDir}/${project.name}")
}

subprojects {
    project.evaluationDependsOn(":app")
}

// Clean task to clear build files
tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}
