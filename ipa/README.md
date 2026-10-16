# How the in-app installer works

The **Download** button in Voltex hands iOS an `itms-services://` link. iOS then
downloads a *manifest* and shows its own **Install / Cancel** prompt. That is exactly
how Scarlet and other on-device side-loaders do it.

There are only two things you need hosted:

1. **A signed `.ipa`** — a direct HTTPS link.
2. **A manifest `.plist`** — a small file that says where that `.ipa` lives.

This folder already contains the manifest: `ipa/manifest.plist`.

## One-time setup

### 1. Upload a **signed** IPA as a Release asset
- Go to **Releases → Draft a new release**
- Tag it anything (e.g. `ipa`), title it, publish
- Attach your `.ipa` and name it exactly **`CharlieTheSteak.ipa`**

The manifest already points at:
```
https://github.com/ysdf78297-cloud/voltex-/releases/latest/download/CharlieTheSteak.ipa
```
`releases/latest/download/<asset-name>` always serves the newest release, so you never
have to edit the manifest again.

### 2. That's it
The app's install source defaults to:
```
https://raw.githubusercontent.com/ysdf78297-cloud/voltex-/main/ipa/manifest.plist
```

Tap **Download → Install** in Voltex and iOS shows the real Install prompt.

## Important: the IPA must be signed

iOS will only install an IPA that carries a valid signature — an **Apple Developer**,
**Enterprise**, or **free-Apple-ID** provisioning profile that lists the installing
device. A decrypted / "cracked" IPA on its own will download and then fail with
*"Unable to Install"* — that is iOS refusing the signature, not Voltex.

If you re-sign with a free Apple ID, remember the profile only includes devices you've
registered, and it expires after 7 days.

## Changing the source without rebuilding

The app also has an **INSTALL SOURCE** field on the IPA's tab — paste any other
manifest URL there and it takes priority over the default.
