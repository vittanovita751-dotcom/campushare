# TODO - Fix Flutter Android Gradle build failure (JVM target mismatch)

- [ ] Inspect Android Gradle/Kotlin configuration (app/build.gradle.kts, android/build.gradle.kts, gradle.properties, maybe gradle-wrapper or local.properties if needed).
- [ ] Create edit plan to align Java/Kotlin JVM target versions (17) and/or configure Kotlin toolchain.
- [ ] Apply code changes to Android Gradle Kotlin DSL files.
- [ ] Run `flutter clean` and `flutter run` (or `./gradlew assembleDebug`) to verify the build passes.
- [ ] If build still fails, re-check where Kotlin JVM target (21) is set (plugins, gradle scripts, or dependencies) and override accordingly.

