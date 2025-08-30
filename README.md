# Android HelloWorld (Python)

This repo contains a minimal Python Android app scaffold using BeeWare (Toga + Briefcase). It lets you write your UI and logic in Python and package it for Android.

If you prefer a different route (e.g., Kivy via WSL/Ubuntu or a Kotlin app that embeds Python via Chaquopy), say the word and we can switch. This path keeps everything in Python for the UI.

## Prerequisites (Windows)
- Python 3.11 or 3.12 on PATH
- Git
- Java 17 (Temurin recommended) and `JAVA_HOME` set
- Android Studio (SDK, Platform Tools, and NDK; Briefcase can help install pieces)
- pipx (recommended) or pip

Quick installs:
- pipx: `python -m pip install --user pipx && python -m pipx ensurepath`
- Briefcase: `pipx install briefcase` (or `pip install briefcase`)

## Automated Windows setup
Run this PowerShell script to validate/install everything via winget (Java 17, Python 3.12, Android Studio) and set up pipx + Briefcase:

`powershell -ExecutionPolicy Bypass -File scripts/windows/setup-dev.ps1`

## Run Locally (Desktop sanity check)
You can run the app on your desktop first to verify Python-side logic:

1) From the repo root, run: `briefcase dev`
   - This will create a virtual env and install desktop backend (`toga-winforms`) automatically.
2) You should see a small window titled "Hello World" with the text "Hello, Android!".

## Run on Android
1) Ensure Android Studio is installed and you’ve opened it once to complete setup.
2) Accept Android SDK licenses if prompted by Briefcase.
3) With a device/emulator available, run:
   - `briefcase create android`
   - `briefcase build android`
   - `briefcase run android`

Notes:
- To use an emulator, open Android Studio > Device Manager and create a device (e.g., Pixel 3a) with a recent API image, then start it before `briefcase run android`.
- The first Android build can take a while; subsequent builds are much faster.

## Project Structure
- `pyproject.toml` — Briefcase app config
- `src/helloworld/app.py` — Toga app entry point
- `src/helloworld/__init__.py` — Package init with `main()` export

## Alternative Approaches
- Kivy + Buildozer: Great for Python, but packaging is Linux-only. On Windows, use WSL2 Ubuntu. I can set this up if you prefer Kivy.
- Chaquopy: Use a standard Android (Kotlin/Java) app and embed Python for selected modules. Useful if you want native Android UI but Python for logic.

## Next Steps
- Tell me if you want to stick with BeeWare or switch to Kivy/Chaquopy.
- If BeeWare: I can help verify your Java/Android SDK setup and walk through the first `briefcase run android` together.
