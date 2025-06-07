// O bloco 'plugins' deve SEMPRE vir primeiro no arquivo.
plugins { 
    id("com.google.gms.google-services") version "4.3.15" apply false 
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = file("../build")
subprojects {
    project.buildDir = file("${rootProject.buildDir}/${project.name}")
}

subprojects {
     project.evaluationDependsOn(":app")
}

tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir) 
}