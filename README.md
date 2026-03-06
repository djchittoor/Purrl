# Purrl

A lightweight macOS menu bar utility that quietly lives in the background, automatically monitoring your clipboard for URLs, stripping out annoying tracking parameters, and fixing embed links. Ensure your privacy and share cleaner, more reliable links with minimal effort.

[![Purrl Demo](https://i.imgur.com/TxQjgoo.gif)](https://i.imgur.com/TxQjgoo.mp4)

## Features

- **Automatic URL Sanitization:** Purrl continuously monitors your clipboard. When you copy a URL, it automatically removes known tracking parameters like `utm_source`, `fbclid`, `gclid`, and many others.
- **Two Cleaning Modes:**
  - **Standard:** Removes common known tracking and marketing parameters, plus any custom-defined blocked parameters.
  - **Strict:** Removes everything except a strictly whitelisted set of parameters (like `q`, `id`, `v`, `page`, etc.).
- **Social Embed Fixes:** Automatically transforms social media links to their embed-friendly equivalents, perfect for sharing on platforms like Discord:
  - `twitter.com` & `x.com` -> `fxtwitter.com`
  - `instagram.com` -> `zzinstagram.com`
  - `reddit.com` -> `rxddit.com`
  - `bsky.app` -> `fxbsky.app`
- **Amazon Link Simplification:** Automatically simplifies sprawling Amazon product links to just the core `/dp/{productId}` path, removing all extraneous junk.
- **Whitelist Support:** Add specific domains to a whitelist. URLs from these domains will skip parameter sanitization. Embed fixes, if enabled, still apply to whitelisted domains.
- **Control & History:**
  - Temporarily pause URL sanitization for one hour if needed.
  - View a recent Activity Log showing original URLs, cleaned URLs, and exactly which tracking parameters were removed.


## Downloads

[![macOS](https://img.shields.io/badge/macOS-15%2B-blue?style=for-the-badge&logo=apple&logoColor=white&labelColor=%2321262d&color=%23000000)](https://www.apple.com/macos/macos-sequoia/) [![Release](https://img.shields.io/github/v/release/djchittoor/Purrl?display_name=tag&style=for-the-badge&logo=github&labelColor=%2321262d&color=%231f6feb)](https://github.com/djchittoor/Purrl/releases/latest) [![Downloads](https://img.shields.io/github/downloads/djchittoor/Purrl/total?style=for-the-badge&labelColor=%2321262d&color=%23238636)](https://github.com/djchittoor/Purrl/releases)

## Settings & Customization

Access the Settings panel via the menu bar icon to configure Purrl to your needs:

- **Auto-clean Enabled:** Enable or disable clipboard monitoring globally.
- **Cleaning Mode:** Switch between "Standard" and "Strict" sanitization rules.
- **Custom Parameters (Standard Mode):** Add custom tracking parameters that you want Purrl to block.
- **Whitelisted Domains:** Add domains you want to be ignored during parameter sanitization (e.g., `*.example.com`).
- **Embed Options:** Individually toggle embed formatting for each supported social platform (Twitter, Instagram, Reddit, Bluesky).

## How It Works

Purrl works by passively observing the system pasteboard (`NSPasteboard`). When it detects a change that contains a valid HTTP or HTTPS URL, it parses the string. The application will skip evaluation if the copied item includes files, images, or authentication credentials.

If the URL passes validation:
1. It strips tracking parameters matched against internal lists or custom user settings.
2. It processes configured embed formatting replacements based on enabled platforms.
3. It debounces the process and silently replaces the dirty URL on your clipboard with the clean version.
4. The menu bar icon briefly animates to confirm the modification was successful.
