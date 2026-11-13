# SilentHub Capture Lab

Android proof of concept for testing whether a separately rendered, secure overlay window remains visible on the device while being excluded from screen recordings.

## Contents

- `SilentHubCaptureLab-Android-Prototype.zip` — complete Android Studio project source.
- `TEST-RESULTS.txt` — manual test checklist for Medal and Samsung Screen Recorder.

## Build from GitHub Actions

1. Open the repository's **Actions** tab.
2. Select **Build SilentHub Capture Lab APK**.
3. Press **Run workflow**.
4. When the job succeeds, open its run and download the `SilentHub-CaptureLab-debug-apk` artifact.
5. Extract the artifact ZIP and install `app-debug.apk` on the Galaxy A55.

A push that changes this folder or the workflow also starts a build.

## Important limitations

This is only a capture-compatibility test marker. It does not connect to Delta, read Roblox state, inject code, or implement an ESP. `FLAG_SECURE` protects the entire Android overlay window; it does not selectively hide individual drawing primitives. Medal and Samsung Screen Recorder must be tested on the actual device. The result is useful only if the marker is absent from the saved video while the game image behind it remains intact.

The repository is public. Do not add credentials, private tokens, or personal data to this project.