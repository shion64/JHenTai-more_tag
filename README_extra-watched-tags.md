# JHenTai: Extra Watched Tags and Mouse Navigation (unofficial fork)

This repository ([shion64/JHenTai-more_tag](https://github.com/shion64/JHenTai-more_tag)) adds **local watched tags** and **mouse back/forward navigation** to [JHenTai](https://github.com/jiangtian616/JHenTai). It is an unofficial modification and is not affiliated with the upstream project.

The code was written with the help of an AI assistant (Claude). It has **not** been submitted upstream. The upstream contribution guidelines do not accept large AI-written changes without human code review.

## What it does

E-Hentai limits how many tags you can watch online. This feature stores extra watched tags **only on your device** and searches for them from the app, so the online limit does not apply.

- Galleries for your extra tags are merged into the **Watched** page, ordered by publish time.
- Tag chips that match an extra watched tag are highlighted in purple.
- Tags are matched ignoring case and the difference between `_` and a space.

## How to use

- **Manage tags**: Settings → EH → *Extra Watched Tags*. Enter a tag as `namespace:key` (for example `artist:alp`). Do not add quotes or `$`.
  - Tapping a tag in the list opens an exact-match search for it.
- **Add from a gallery**: long-press a tag chip on a gallery detail page, then use the bookmark button (*Add local watch* / *Remove local watch*). This works without logging in.
- **See the results**: open the Watched page (login is required, as for the normal Watched page).

## How the Watched page behaves

- It waits up to 6 seconds for the extra tags. If they are not ready, it shows the official results first and inserts the extra ones when they arrive.
- With more than 20 extra tags, it fetches only the latest page of each tag, in small batches with short delays, and stops if a whole batch fails.
- Pull-to-refresh fetches the extra tags again.

## Mouse back / forward buttons

The mouse side buttons navigate on every page.

- **Back**: closes the page on top. In the desktop and tablet layouts the right pane is closed first, then the left pane. When there is nothing left to close, the desktop layout goes back to the previously selected tab of the left tab bar.
- **Forward**: reopens the page that was closed by back, or goes forward to the next tab. The history keeps up to 20 entries and is cleared when you navigate somewhere new.
- **Read page**: back closes the reader by default. If you bind the back button to another action in the read shortcut settings, that binding wins.
- Ignored while a dialog or bottom sheet is shown, on the lock page, on the read page itself (it handles the buttons by itself) and on the keyboard shortcuts settings page.

## Status

Checked on Linux only, by a GitHub Actions workflow (`linux-check`, run from separate `ci-*` branches), not on a local Flutter install:

- The Linux release build succeeds.
- `flutter analyze` reports no errors from these changes.
- `flutter test` passes, including new tests for tag handling.
- Mouse back/forward navigation was also checked by hand on the Linux desktop layout.

Not verified: Android, iOS, Windows, macOS, and a real phone-sized layout.

Translations are provided for English, Simplified Chinese and Traditional Chinese only. Other languages are not translated.

## Things to know

- Settings and the database are shared with the official app on the same machine. Do not run both at the same time.
- The setting is stored under the config key `extraWatchedTagSetting`. Remove the tags from the management page to clear it.

## Building

Same as upstream. With Flutter installed:

```
flutter pub get
flutter analyze
flutter test
flutter build linux --release -t lib/src/main.dart
```

The branch is `feature/extra-watched-tags`: a few commits rebased on top of upstream `master`. It is updated by rebasing when upstream releases a new version.

## License

Apache-2.0, the same as upstream.
