# Voltex (iOS)

A native SwiftUI iPhone app.

- **Theme:** black background with drifting **orange blobs** (orange + black are the main colours, purple is the accent).
- **Wordmark:** a big animated **Voltex** title in an orange -> purple gradient with a light that sweeps across it.
- **Scroll:** the landing screen scrolls down to **"This is a test of the IPA"**.
- **Bottom tabs:** **IPA's**, **Settings**, **About**.
  - **IPA's** — "None here yet".
  - **Settings** — version, build number, bundle ID, theme, device, and an Animations toggle.
  - **About** — "Soon".

## Layout

```
Voltex-iOS/
  Voltex.xcodeproj/          Xcode project (shared scheme "Voltex")
  Voltex/
    VoltexApp.swift          App entry point
    ContentView.swift        Tab bar (IPA's / Settings / About)
    Theme.swift              Orange / black / purple palette
    BlobBackground.swift     Animated orange blobs
    LogoHero.swift           Logo + animated "Voltex" wordmark
    IPAsView.swift           Landing tab
    SettingsView.swift       Build number etc.
    AboutView.swift          "Soon"
    Assets.xcassets/         App icon + in-app logo (from your PNG)
  build-ipa.sh               Build an unsigned .ipa on a Mac
  .github/workflows/build-ipa.yml
```

## Getting the .ipa

The app is real, but an iOS `.ipa` has to be compiled by Apple's toolchain (Xcode), which only
runs on macOS. Pick whichever you have:

### A. No Mac? Build it free in the cloud

1. Create a repo on GitHub and push the **inside** of this `Voltex-iOS` folder as the repo root.
2. The included workflow (`.github/workflows/build-ipa.yml`) runs automatically.
3. Open the run under **Actions**, download the **Voltex-ipa** artifact.

### B. On a Mac

```bash
./build-ipa.sh
```

Either way you get an **unsigned** `Voltex.ipa`.

## Installing it on your iPhone

An unsigned IPA can't be installed as-is — it needs signing with your Apple ID. Use **Sideloadly**
(you already have it):

1. Open **Voltex.ipa** in Sideloadly.
2. Enter your Apple ID, connect your iPhone, press **Start**.
3. Trust the developer profile on the phone: **Settings -> General -> VPN & Device Management**.

Free Apple IDs sign for 7 days at a time; re-run Sideloadly to renew.

## Changing things

- Build number / version: `CURRENT_PROJECT_VERSION` and `MARKETING_VERSION` in
  `Voltex.xcodeproj/project.pbxproj` (Settings screen reads them straight from the app bundle).
- Colours: `Voltex/Theme.swift`.
- Bundle ID (`com.voltex.app`): `PRODUCT_BUNDLE_IDENTIFIER` in `project.pbxproj`.
