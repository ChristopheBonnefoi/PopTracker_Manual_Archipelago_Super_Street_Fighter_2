# PopTracker for Manual Archipelago Super Street Fighter II

PopTracker pack for `Manual_SSF2_NaruSnake`, the Manual Archipelago world for Super Street Fighter II.

This pack tracks the Manual Archipelago items and checks in PopTracker, including Archipelago connection support, Manual location checking, character unlocks, game modes, difficulty items, CPU Time Challenge items, and Shadaloo Emblem token counts.

## Status

Current version: `0.2.0`

The pack is usable with Archipelago Manual and PopTracker. Core AP tracking is working:

- Connects to Archipelago as a PopTracker client.
- Receives AP items and updates tracker items.
- Receives checked locations from AP and updates map checks.
- Sends Manual location checks to Archipelago when checks are clicked in PopTracker.
- Tracks `Shadaloo Emblem` as a consumable token counter.
- References all current Manual APWorld locations in the tracker data.
- Includes Super Battle, Time Challenge, Defeat, character, All, and Other map views.

## Installation

Use the generated pack archive:

```text
SSF2_ap_Tracker.zip
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

- Special Move items are present for AP logic, but they are not displayed in the tracker UI yet.
- SNES memory autotracking is not implemented. This is a Manual Archipelago tracker, so checks are handled manually through PopTracker.
- Some map marker placements may still receive visual polish.

## Changelog

### Version 0.2.0

- Updated the tracker data to match the current `Manual_SSF2_NaruSnake` APWorld.
- Added all current APWorld locations to the tracker location data.
- Added hidden Special Move items so APWorld requirements can be represented correctly in tracker logic.
- Rebuilt AP item and location mappings for Archipelago connection support.
- Added and reorganized map views for `All`, `Defeat`, `Super Battle`, `Time Challenge`, character pages, and `Other`.
- Added per-character Super Battle tabs and updated tab ordering.
- Updated map assets for the new tracker layout.
- Updated access rules so tracker checks follow the APWorld requirements.
- Cleaned pack output rules for logs, archives, source art, and local documentation.
- Renamed the generated pack archive to `SSF2_ap_Tracker.zip`.

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

- Design a clean UI for displaying Special Move items.
- Continue polishing map marker placements.
- Improve map visuals and location organization.
- Add documentation for creating future Manual Archipelago PopTracker packs.

## Links

- PopTracker website/repository: <https://github.com/PopTracker/PopTracker.github.io>
- PopTracker documentation source: <https://github.com/black-sliver/PopTracker/tree/master/doc>
- This repository: <https://github.com/ChristopheBonnefoi/PopTracker_Manual_Archipelago_Super_Street_Fighter_2>
