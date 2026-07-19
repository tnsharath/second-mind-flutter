"""Enables core library desugaring in the `flutter create`-generated
android/app/build.gradle(.kts). Required by flutter_local_notifications. Idempotent."""
import re
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
        # Empty block on one line: dependencies {}
        text = re.sub(
            r'^(\s*)dependencies\s*\{\s*\}\s*$',
            r'\1dependencies {\n' + dep + r'\1}\n',
            text,
            count=1,
            flags=re.MULTILINE,
        )
        # Non-empty or multi-line block: append after the opening brace
        if 'coreLibraryDesugaring' not in text:
            text = re.sub(
                r'^(\s*)dependencies\s*\{\s*$',
                r'\1dependencies {\n' + dep,
                text,
                count=1,
                flags=re.MULTILINE,
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
        # Empty block on one line: dependencies {}
        text = re.sub(
            r'^(\s*)dependencies\s*\{\s*\}\s*$',
            r'\1dependencies {\n' + dep + r'\1}\n',
            text,
            count=1,
            flags=re.MULTILINE,
        )
        # Non-empty or multi-line block: append after the opening brace
        if 'coreLibraryDesugaring' not in text:
            text = re.sub(
                r'^(\s*)dependencies\s*\{\s*$',
                r'\1dependencies {\n' + dep,
                text,
                count=1,
                flags=re.MULTILINE,
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

    original = target.read_text()
    print(f'--- {target} (before patch) ---')
    print(original)
    print('--- end ---')

    patched = patcher(original)

    print(f'--- {target} (after patch) ---')
    print(patched)
    print('--- end ---')

    target.write_text(patched)
    print(f'{target} patched for core library desugaring.')


if __name__ == '__main__':
    main()
