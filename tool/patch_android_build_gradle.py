"""Enables core library desugaring in the `flutter create`-generated
android/app/build.gradle. Required by flutter_local_notifications. Idempotent."""
from pathlib import Path

BUILD_GRADLE = Path('android/app/build.gradle')

DESUGAR_DEPENDENCY = "    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.1.4'\n"


def main() -> None:
    text = BUILD_GRADLE.read_text()

    if 'coreLibraryDesugaringEnabled' not in text:
        text = text.replace(
            '    compileOptions {\n',
            '    compileOptions {\n        coreLibraryDesugaringEnabled true\n',
            1,
        )

    if 'coreLibraryDesugaring' not in text:
        text = text.replace(
            'dependencies {\n}',
            'dependencies {\n' + DESUGAR_DEPENDENCY + '}',
            1,
        )

    BUILD_GRADLE.write_text(text)
    print('android/app/build.gradle patched for core library desugaring.')


if __name__ == '__main__':
    main()
