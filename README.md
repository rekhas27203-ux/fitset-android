# FitSet — اپنی ایکسرسائز، اپنے سیٹس، اپنی ویڈیو

A small Android fitness app (single signed APK, ~41 KB) where you:

1. **Pick an exercise** from a library of 16 moves (Squat, Push-Up, Plank, Lunge, Glute Bridge,
   Romanian Deadlift, Shoulder Press, Bicep Curl, Lateral Raise, Pull-Up, Mountain Climber,
   Crunch, Burpee, Bench Press, Triceps Dip, Calf Raise).
2. **Set sets · reps · time per set · rest** on that exercise and **save** it.
3. **Tap the saved exercise** — it opens the player and streams that exercise's
   **official YouTube demo video**, playing it in the correct form for exactly the
   number of seconds you set. The video pauses itself when the set time is up,
   a rest countdown runs, then the next set starts from the beginning of the video.

## Install

Download `FitSet.apk` from this repo (or the release) and open it on the phone.
Android will ask to allow install from unknown sources — that is normal for a
self-signed APK. Android 5.0 (API 21) and above.

The APK is signed with a local self-signed key (`CN=FitSet`), not a Play Store key.

## How the video works (and why it is copyright-safe)

The app never downloads, copies or re-hosts any video. It embeds the **official
YouTube player** (YouTube IFrame Player API) and streams the video from YouTube
itself, so views and ads stay with the original creator. Each exercise points at a
public tutorial video from a fitness channel; the channel name is credited in the
commit history / exercise list. If a video owner disables embedding, the app shows
an "Open on YouTube" button instead of a broken player.

You need an internet connection for the video. Everything else (your sets, reps,
time, saved plan) is stored offline on the phone with `localStorage`.

## Tech

* One `Activity` (`MainActivity.java`) hosting a `WebView`.
* The whole UI is a single self-contained `assets/index.html` (no frameworks),
  served to the WebView through a virtual `https://appassets.androidplatform.net`
  origin via `shouldInterceptRequest`, which is what lets the YouTube IFrame API
  treat the page as a normal https origin.
* Saved plans persist in `localStorage`; the timer engine, set dots and rest
  countdown are plain JavaScript.
* No third-party libraries, no ad SDKs, no analytics, no extra permissions —
  only `INTERNET` and `ACCESS_NETWORK_STATE`.

## Build from source

`build.sh` builds and signs the APK with the plain Android SDK tools
(`aapt2` → `ecj` → `d8` → `zipalign` → `apksigner`), no Gradle needed:

```bash
./build.sh          # needs ANDROID SDK build-tools 34 + platform 34 + a JDK
```

Edit `assets/index.html` → the `EXERCISES` array to change exercises, defaults or
the YouTube video id of any move.

## Project layout

```
AndroidManifest.xml
assets/index.html                     # entire app UI + logic
src/com/rekha/fitset/MainActivity.java
res/values/{strings,styles}.xml
res/mipmap-*/ic_launcher.png
build.sh
FitSet.apk                           # signed, ready to install
```
