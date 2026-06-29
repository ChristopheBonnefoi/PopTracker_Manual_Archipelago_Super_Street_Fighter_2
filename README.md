# PopTracker for Manual Archipelago Super Street Fighter II

PopTracker pack for `Manual_SSF2_NaruSnake`, the Manual Archipelago world for Super Street Fighter II.

This pack tracks the Manual Archipelago items and checks in PopTracker, including Archipelago connection support, Manual location checking, character unlocks, game modes, difficulty items, CPU Time Challenge items, and Shadaloo Emblem token counts.

## Status

Current version: `0.1.2`

The pack is usable with Archipelago Manual and PopTracker. Core AP tracking is working:

- Connects to Archipelago as a PopTracker client.
- Receives AP items and updates tracker items.
- Receives checked locations from AP and updates map checks.
- Sends Manual location checks to Archipelago when checks are clicked in PopTracker.
- Tracks `Shadaloo Emblem` as a consumable token counter.

## Installation

Use the generated pack archive:

```text
SSF2_PopTracker_pack.zip
```

Place it in your PopTracker `packs` folder, or extract it into a short path such as:

```text
C:\PopTracker\packs\SSF2\
```

If extracted, `manifest.json` must be directly inside the pack folder.

## Usage

1. Start an Archipelago room generated with `Manual_SSF2_NaruSnake`.
2. Open PopTracker.
3. Load this pack.
4. Connect PopTracker to the Archipelago server using the correct slot name.
5. Click checks in PopTracker to send Manual checks to Archipelago.

## Known Limitations

- The tracker currently displays the main Super Battle and Time Challenge checks, but not every possible check from the AP world is represented visually yet.
- SNES memory autotracking is not implemented. This is a Manual Archipelago tracker, so checks are handled manually through PopTracker.
- Debug logging is still enabled while the pack is being stabilized.

## Changelog

### Version 0.1.2

- Added `apmanual` support in the PopTracker manifest.
- Fixed Archipelago item and location mappings to match the Manual AP world IDs.
- Added Manual location check sending through `Archipelago:LocationChecks`.
- Fixed item tracking toggles for characters, game modes, difficulty, and CPU Time Challenge items.
- Fixed `Shadaloo Emblem` token tracking as a consumable counter.
- Added item-name validation so mismatched AP item IDs cannot be counted as the wrong item.
- Disabled the unused example SNES memory autotracking script.
- Fixed missing tab icons in the tracker layout.
- Updated `Shadaloo Emblem` maximum quantity to `100`.
- Updated `versions_url` to point to this PopTracker repository.

### Version 0.1.1

- Updated README.
- Added `.gitignore`.
- Created `docs/` folder and added it to `.gitignore`.

### Version 0.1.0

- Initial pack structure.
- Added base PopTracker items, layouts, maps, locations, and autotracking scripts.

## Contributing

Feedback, bug reports, and pull requests are welcome.

Useful areas for future improvements:

- Add the remaining AP checks to the PopTracker layout.
- Clean up debug logging for release builds.
- Improve map visuals and location organization.
- Add documentation for creating future Manual Archipelago PopTracker packs.

## Links

- PopTracker website/repository: <https://github.com/PopTracker/PopTracker.github.io>
- PopTracker documentation source: <https://github.com/black-sliver/PopTracker/tree/master/doc>
- This repository: <https://github.com/ChristopheBonnefoi/PopTracker_Manual_Archipelago_Super_Street_Fighter_2>
