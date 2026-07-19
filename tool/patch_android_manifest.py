"""Injects the permissions and <queries> entries AURA needs into the
`flutter create`-generated AndroidManifest.xml. Idempotent."""
from pathlib import Path

MANIFEST = Path('android/app/src/main/AndroidManifest.xml')

PERMISSIONS = [
    'android.permission.INTERNET',
    'android.permission.RECORD_AUDIO',
    'android.permission.POST_NOTIFICATIONS',
]

QUERIES = (
    '    <queries>\n'
    '        <intent>\n'
    '            <action android:name="android.speech.RecognitionService" />\n'
    '        </intent>\n'
    '        <intent>\n'
    '            <action android:name="android.intent.action.TTS_SERVICE" />\n'
    '        </intent>\n'
    '    </queries>\n'
)


def main() -> None:
    text = MANIFEST.read_text()
    for permission in PERMISSIONS:
        if permission not in text:
            line = f'    <uses-permission android:name="{permission}"/>\n'
            text = text.replace('    <application', line + '    <application', 1)
    if '<queries>' not in text:
        text = text.replace('</manifest>', QUERIES + '</manifest>', 1)
    MANIFEST.write_text(text)
    print('AndroidManifest.xml patched.')


if __name__ == '__main__':
    main()
