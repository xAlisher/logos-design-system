---
name: mobile-ready-ui
description: Build or change a Logos/Basecamp app's QML UI so it works from phone to desktop. Use whenever an agent writes or edits app screens with the Logos design system (import Logos.Controls / Logos.Theme) — new apps, new pages, layout fixes, "make it mobile", "responsive", "narrow window", "touch". Gives the breakpoints, the app frame, a pattern per common layout, touch rules, and a mandatory render-and-check step at 390 / 700 / 1280.
---

# Mobile-ready UI for Logos apps

Every screen you build must work at **390 px (phone), 700 px (tablet / narrow window) and
1280 px (desktop)**, and be proven so with renders. The full rules, with the reasoning, are in
the design system's `docs/RESPONSIVE.md`; this skill is the working checklist.

## 1. Decide layout by window class, never by pixels sprinkled around

```qml
readonly property string windowClass: Theme.windowClass(width)   // your own area's width
```

| Class | Width | Navigation | Columns |
|---|---|---|---|
| `compact` | < 600 | ☰ drawer, ‹ back on a detail | 1 |
| `medium` | 600–839 | icon rail | 1–2 |
| `expanded` | ≥ 840 | sidebar with labels | 2–3 |

Use `Theme.pageMargin(width)` for side margins, `Theme.minTouchTarget` (44) for hit areas.
Measure the page's own `width` (it may sit in a shell, a split, or a torn-off window).

## 2. Frame the app with `LogosAppScaffold`

Do not hand-build a sidebar. Put pages inside `LogosAppScaffold` (`title`, `pageTitle`,
`navModel`, `currentNav`, `canGoBack`, `onNavActivated`, `onBackRequested`, `actions`). It gives
sidebar → rail → ☰ drawer, and ‹ instead of ☰ when a page has pushed a detail. 3–7 destinations,
one-word labels.

## 3. Pick the pattern, apply its rules

| Your screen is… | Rules (details: RESPONSIVE.md §3) |
|---|---|
| a list with a detail (inbox, chat, items) | 2 panes ≥ 600 (list 320/360, detail fills, first item shown); compact: list only, tap pushes the detail full width with ‹ |
| settings | one column, max 720, centred; grouped `LogosListRow`s: chevron = goes somewhere, value = current setting, switch = on/off; destructive group last |
| a form | max 720 centred, page scrolls; expanded: 200 px label column; medium: labels above, short fields two per row; compact: one per row, full width, primary action full width and **last** |
| a dashboard | content max 1200 centred; columns from the width you get and a minimum card width (stat cards 4 / 2×2 / 1, never 3+1); side-by-side cards only if both stay usable |
| a table | expanded: full table; medium: 3 key columns + ⋯, detail in a sheet; compact: **no table**, rows become cards, tap → detail with ‹; toolbar wraps (search on its own line) |

Not listed? Combine these: a page is usually a scaffold + one pattern per region.

## 4. Touch rules (no exceptions in compact or `density: "touch"`)

- Every tappable thing has a hit area ≥ 44 × 44. Visual can be smaller: wrap it in an `Item`
  of 44 with a `MouseArea` / `TapHandler`, or set the control's `implicitHeight` to
  `Theme.minTouchTarget`.
- Nothing hover-only: actions get a visible ⋯ button (`LogosIconButton` + `LogosIcons.more`,
  opening a `LogosMenu`); information in tooltips also appears as visible help text.
- No double-click: one tap opens. No horizontal scrolling of a page; long text elides or wraps.
- Help and error text sit visibly under fields.

Known design-system controls that are still under 44 at touch density (wrap them until the DS
fixes land, see RESPONSIVE.md §6): checkbox, radio, switch rows; spin box − / +; slider; copy
button; info button; tile; link; search-bar clear; notice / toast close; combo popup rows;
paginator; table header and checkboxes. Tooltips never open on touch.

## 5. Prove it (required before you say done)

With the design-system repo's responsive lab (`responsive-lab/`), or the same shot mode built
into your app's test harness:

```
shot.sh <page> 390 844 out-390.png --density touch
shot.sh <page> 700 844 out-700.png --density touch
shot.sh <page> 1280 800 out-1280.png
python3 montage.py all.png out-390.png out-700.png out-1280.png
```

Each shot prints `{"overflow": [...], "smallTargets": [...]}`. Done means:
1. no QML warnings on stderr;
2. `overflow` empty at all three widths;
3. `smallTargets` empty at 390 and 700 with `--density touch`;
4. you **looked** at the three PNGs (Read them) and each looks deliberate, not just squeezed;
5. pages that push a detail or scroll are shot in those states too (`--state …`).

Attach the montage and the three report lines to the PR or reply. "Should work on mobile" is not
done.

## 6. Don't

- Don't branch on `Qt.platform.os` or screen size for layout; use the window class.
- Don't fix one width at the cost of another; re-shoot all three after every layout change.
- Don't build custom controls that duplicate a DS one to dodge a size problem; wrap the DS
  control and note the gap.
