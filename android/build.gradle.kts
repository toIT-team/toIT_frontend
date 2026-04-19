import com.android.build.gradle.BaseExtension
import org.gradle.api.Project
import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

fun Project.applyJvmAlignment() {
    extensions.findByType<BaseExtension>()?.compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    tasks.withType<KotlinCompile>().configureEach {
        compilerOptions {
            jvmTarget.set(JvmTarget.JVM_17)
        }
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

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

// Flutter 플러그인 중 일부는 Java 1.8 기본값과 Kotlin JVM(예: 21)이
// 어긋나 빌드가 실패한다. 앱 모듈과 동일하게 Java/Kotlin JVM을 맞춘다.
// evaluationDependsOn(":app") 때문에 이미 평가된 모듈은 afterEvaluate를
// 쓸 수 없어 분기한다. :app은 자체 compileOptions가 있어 여기서 건드리면
// finalized 오류가 난다.
subprojects {
    if (name == "app") {
        return@subprojects
    }
    if (state.executed) {
        applyJvmAlignment()
    } else {
        afterEvaluate { applyJvmAlignment() }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
