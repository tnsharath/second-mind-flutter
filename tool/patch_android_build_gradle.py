"""Enables core library desugaring in the `flutter create`-generated
android/app/build.gradle(.kts). Required by flutter_local_notifications. Idempotent."""
from pathlib import Path

BUILD_GRADLE = Path('android/app/build.gradle')
BUILD_GRADLE_KTS = Path('android/app/build.gradle.kts')


def patch_groovy(text: str) -> str:
    if 'coreLibraryDesugaringEnabled' not in text:
        text = text.replace(
            '    compileOptions {\n',
            '    compileOptions {\n        coreLibraryDesugaringEnabled true\n',
            1,
        )
    if 'coreLibraryDesugaring' not in text:
        dep = "    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.1.4'\n"
        text = text.replace(
            'dependencies {\n',
            'dependencies {\n' + dep,
            1,
        )
    return text


def patch_kotlin(text: str) -> str:
    if 'isCoreLibraryDesugaringEnabled' not in text:
        text = text.replace(
            '    compileOptions {\n',
            '    compileOptions {\n        isCoreLibraryDesugaringEnabled = true\n',
            1,
        )
    if 'coreLibraryDesugaring' not in text:
        dep = '    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")\n'
        text = text.replace(
            'dependencies {\n',
            'dependencies {\n' + dep,
            1,
        )
    return text


def main() -> None:
    target: Path | None = None
    patcher = None

    if BUILD_GRADLE_KTS.exists():
        target = BUILD_GRADLE_KTS
        patcher = patch_kotlin
    elif BUILD_GRADLE.exists():
        target = BUILD_GRADLE
        patcher = patch_groovy

    if target is None or patcher is None:
        print('ERROR: No android/app/build.gradle(.kts) found.')
        print(f'CWD: {Path.cwd()}')
        android_dir = Path('android')
        if android_dir.exists():
            for item in android_dir.rglob('*'):
                print(f'  {item}')
        else:
            print('  android/ directory does not exist.')
        raise SystemExit(1)

    text = target.read_text()
    text = patcher(text)
    target.write_text(text)
    print(f'{target} patched for core library desugaring.')


if __name__ == '__main__':
    main()
