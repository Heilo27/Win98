# Win98 iOS App — Level 1 Diagnostic Phase 1 (Worf)
**Date:** 2026-05-25  
**Scope:** Completeness audit, build check, spec compliance check  
**Project:** /Users/ryan/Documents/Development/Win98

---

## Checkpoint 1: Stub Sweep
**CLEAN.** No `fatalError`, `TODO`, `FIXME`, `NOT IMPLEMENTED`, `placeholder`, `stub`, `dummy`, or `hardcoded` strings found anywhere in the Swift source tree.

No Lorem ipsum or placeholder text in non-test code.

---

## Checkpoint 2: Dead Wiring (Enum Cases)

### BevelStyle
- `raised`, `sunken`, `flat`, `well`: All actively used at multiple call sites. Clean.
- `groupBox`: **DEAD WIRED.** Defined and dispatched in `BevelBorder.body`, but `drawGroupBox` is only called from the switch — no external caller ever passes `.groupBox`. No `View` extension wraps it. Effectively unreachable from UI code.

### Win98App (WindowManager.swift)
- `myDocuments`, `recycleBin`, `networkNeighborhood`, `explorer`, `shutDown`: All have call sites in DesktopView/StartMenu. Clean.

### SmileyState (MinesweeperView.swift)
- `normal`, `won`, `lost`: Used correctly in game model and SmileyButton.
- `clicking`: **DEAD WIRED.** Case exists, emoji defined in `smileyEmoji`. But `smileyState` is never set to `.clicking` anywhere in the game model. The Win98 Minesweeper shows a surprised face while mouse is held — this state is never triggered.

### MinesweeperDifficulty
- All three cases (`beginner`, `intermediate`, `expert`) are wired to menu items. Clean.

### PlayingCard.Suit
- All four cases used. Clean.

---

## Checkpoint 3: Build Check

**Result: BUILD FAILED — 1 compiler error**

**File:** `/Users/ryan/Documents/Development/Win98/Win98/Core/WindowManager.swift:146`

```swift
// BROKEN — uses 'func' keyword for a computed property
func activeWindowID: UUID? {
    windows.filter { !$0.isMinimized }.max(by: { $0.zIndex < $1.zIndex })?.id
}
```

The `func` keyword is used where `var` is required for a computed property. This prevents the entire project from compiling.

**Fix:** Change `func activeWindowID: UUID?` → `var activeWindowID: UUID?`

No other compiler errors. No warnings surfaced (build failed before warning generation).

---

## Checkpoint 4: Spec Compliance Check

### Desktop
- ✅ Teal background (#008080) — correct
- ✅ Desktop icons: My Computer, My Documents, Network Neighborhood, Recycle Bin
- ✅ Icons are custom-drawn Canvas views, not SF Symbols
- ⚠️ Only 4 desktop icons — Win98 SE typically also showed Internet Explorer on desktop
- ✅ Double-tap to open, single tap to select
- ✅ Long-press context menu (Arrange Icons, Refresh, Paste, New, Properties)
- ❌ Context menu items are all no-ops (empty action closures)

### Taskbar
- ✅ Start button with Windows logo and "Start" text
- ✅ Clock in system tray
- ✅ Window buttons for open apps (show/hide/bring-to-front)
- ✅ Quick launch area (IE placeholder + Show Desktop)
- ✅ Silver (#C0C0C0) taskbar background
- ✅ Bevel separators between sections
- ⚠️ Clock updates every 30 seconds — Win98 clock updated every minute (acceptable), but 30s means up to 30s drift visible to user

### Start Menu
- ✅ Blue vertical banner with "Windows 98" rotated text
- ✅ Programs → Accessories → Games → Minesweeper/Solitaire cascading submenus
- ✅ Shut Down dialog
- ✅ Win98-accurate menu items (Help, Run, Log Off, Find, Favorites, Settings)
- ⚠️ Start menu position hardcoded as `y: geo.size.height - taskbarHeight - 200` but menu is 400pt tall — on many screen sizes the top of the menu is clipped off-screen
- ⚠️ "Log Off Ryan..." has a hardcoded personal name — should be generic or use device name
- ❌ Favorites, Documents, Find submenus have no content (tap → dismisses menu, no submenu opens)
- ❌ Settings submenu items (Control Panel, Printers, Taskbar, Folder Options) open either My Computer or do nothing

### Window System
- ✅ Draggable via title bar
- ✅ Z-ordering (zIndex tracked per window)
- ✅ Minimize to taskbar / restore
- ✅ Maximize / restore (fills screen above taskbar)
- ✅ Close button
- ✅ Resize handle (bottom-right drag)
- ✅ Active window title bar gradient (#000080 → #1084D0)
- ✅ Inactive title bar (#808080)
- ✅ Double-tap title bar to maximize
- ⚠️ Resize handle is a 16×16 invisible Rectangle — no visual grip/hatching indicator
- ❌ **COMPILE ERROR** — `func activeWindowID` bug means the entire window activation / z-ordering system cannot compile (P0)

### 3D Bevel Effect
- ✅ Full 4-line bevel: outer highlight (white), inner highlight (light gray), inner shadow (gray), outer shadow (dark)
- ✅ Correct raised/sunken/well/flat variants
- ✅ Applied to windows, buttons, taskbar, wells, caption buttons
- ✅ Pixel-correct Canvas drawing

### Win98 Colors
- ✅ Desktop: #008080 ✓
- ✅ Silver: #C0C0C0 ✓
- ✅ Active title: #000080 ✓
- ✅ Title text: #FFFFFF ✓
- ✅ Selection: #000080 background, #FFFFFF text ✓
- ⚠️ Font: Uses Menlo (monospaced) instead of Tahoma/MS Sans Serif (proportional). Menlo is aesthetically different from authentic Win98 UI font.

### My Computer
- ✅ Menu bar (File/Edit/View/Help) — all items present
- ✅ Toolbar with Back/Forward/Up/Cut/Copy/Paste buttons
- ✅ Address bar with current path
- ✅ Drives: 3½ Floppy (A:), Local Disk (C:), CD-ROM (D:), Control Panel, Printers, Dial-Up Networking
- ✅ Double-click C: → drill into CDriveView with file list
- ✅ Status bar ("N object(s)")
- ⚠️ Toolbar buttons (Back, Forward, Cut, Copy) are all no-ops — they're decorative

### Notepad
- ✅ TextEditor (native iOS text editing — cursor, selection, keyboard)
- ✅ Word wrap toggle
- ✅ File/Edit/Search/Help menu bar
- ✅ Time/Date insertion (F5 equivalent)
- ✅ "Unsaved changes" alert on New
- ✅ Find dialog with Match Case and Direction pickers
- ❌ Open/Save/Save As are no-ops (openFile loads hardcoded sample text; saveFile/saveFileAs just reset isDirty flag with no actual file I/O)
- ❌ Cut/Copy/Paste/Select All menu items are empty closures — no text clipboard interaction
- ❌ Find Next button in dialog does nothing (empty closure)
- ❌ Find Next from menu bar does nothing

### Calculator
- ✅ Full numeric keypad layout matching Win98 Calculator
- ✅ All arithmetic operations: +, -, *, /
- ✅ Memory functions: MC, MR, MS, M+ with indicator
- ✅ Scientific operations: sqrt, %, 1/x
- ✅ Backspace, CE, C
- ✅ Divide-by-zero handling ("Cannot divide by zero")
- ✅ Chained operations (operator pressed again → computes pending, uses result as new operand)
- ✅ 7-segment LED-style display (Canvas drawing)
- ✅ Sunken display well
- ✅ Button press animation (bevel inverts on touch)
- CLEAN — no P0/P1 issues

### Minesweeper
- ✅ Full game logic: mine placement (avoids first click area), flood-fill reveal, flagging, question marks
- ✅ 7-segment LED mine counter and timer
- ✅ Smiley button (normal / won / lost states)
- ✅ Three difficulty modes (Beginner 9×9/10, Intermediate 16×16/40, Expert 16×30/99)
- ✅ Timer starts on first reveal, stops on win/loss
- ✅ Auto-flag mines on win
- ✅ Win condition check
- ❌ **SmileyState.clicking never set** — smiley doesn't show "😮" during mouse-hold (dead enum case)
- ❌ **Window size vs grid size mismatch**: Default window is 200×240. Expert grid is 30×18px cells = 540px wide minimum. Intermediate is 16×18 = 288px wide. The grid overflow is not handled — cells will be clipped unless user manually resizes the window.
- ⚠️ Best Times dialog (menu item) is a no-op

### Solitaire
- ✅ Klondike layout: 7 tableau columns, 4 foundations, stock + waste pile
- ✅ Proper deal (1 face-up per column, correct count)
- ✅ Stock draw/recycle mechanics
- ✅ Foundation rules (A→K, same suit)
- ✅ Tableau rules (alternating color, descending rank, King to empty)
- ✅ Score system (+10 foundation, +5 flip)
- ✅ Win detection (52 cards in foundations)
- ✅ Win animation (bouncing cards)
- ✅ Double-tap card to auto-move to foundation
- ❌ **Tableau drag drop is broken**: `TableauColumn` drag `.onEnded` (line 475) only clears `draggedCards` and `dragSource` — it never calls `handleDrop`. Cards dragged from tableau cannot be dropped anywhere. Only waste→foundation/tableau (via `handleDrop`) works.
- ❌ **Drag position heuristic is fragile**: `handleDrop` uses `predictedEndLocation` from within the waste card's local geometry, then tries to match against absolute column positions (offset from ZStack origin) — coordinate spaces don't match, making drops unreliable even for waste cards.
- ⚠️ No "Deal" / difficulty options (Win98 Solitaire had Draw 1 / Draw 3 modes)

---

## Issue Log

### P0 — Won't Compile / Crash on Launch
**[P0] [Build] [WindowManager]: `func activeWindowID: UUID?` uses `func` keyword instead of `var` for computed property — project fails to compile entirely.**
- File: `Win98/Core/WindowManager.swift:146`
- Fix: `func activeWindowID: UUID?` → `var activeWindowID: UUID?`

### P1 — Feature Present but Broken / Non-functional
**[P1] [Gameplay] [Solitaire]: Tableau drag-drop is broken — `TableauColumn` drag `.onEnded` never calls `handleDrop`, so cards dragged from tableau columns cannot be moved anywhere.**
- File: `Win98/Apps/SolitaireView.swift:475`

**[P1] [Gameplay] [Solitaire]: Drag coordinate space mismatch — `handleDrop` receives `predictedEndLocation` in the waste card's local frame but computes target column positions using ZStack-absolute offsets. Drops are unreliable.**
- File: `Win98/Apps/SolitaireView.swift:355-385`

**[P1] [Layout] [Minesweeper]: Default window size (200×240) cannot display Intermediate (288px wide) or Expert (540px wide) grids — cells are clipped. No minimum window size enforcement or auto-resize on difficulty change.**
- File: `Win98/Core/WindowManager.swift:42-43` (defaultSize for minesweeper), `Win98/Apps/MinesweeperView.swift:343-349`

**[P1] [Feature] [Notepad]: File I/O is not implemented — Open loads a hardcoded sample string, Save/Save As only reset `isDirty` flag with no actual file persistence.**
- File: `Win98/Apps/NotepadView.swift:100-115`

**[P1] [Feature] [Notepad]: Cut/Copy/Paste/Select All menu items are empty closures — no clipboard integration.**
- File: `Win98/Apps/NotepadView.swift:39-47`

**[P1] [Feature] [Notepad]: Find / Find Next are non-functional — Find Next button in dialog is an empty closure, Find Next menu item is an empty closure.**
- File: `Win98/Apps/NotepadView.swift:62-63`, `177`

### P2 — Feature Works but Visually Wrong / Partially Incomplete
**[P2] [Visual] [StartMenu]: Start menu positioned with hardcoded 200pt offset but menu is 400pt tall — top of menu clips off-screen on shorter display heights.**
- File: `Win98/Desktop/DesktopView.swift:73`

**[P2] [Dead Code] [Minesweeper]: `SmileyState.clicking` is defined and handled in `SmileyButton` but is never set in `MinesweeperGame` — smiley face never shows "😮" during mouse-hold.**
- File: `Win98/Apps/MinesweeperView.swift:216-224`, `Win98/Core/WindowManager.swift`

**[P2] [Dead Code] [Core]: `BevelStyle.groupBox` is defined and handled in `BevelBorder.drawGroupBox` but no `View` extension exposes it and no caller uses it — entirely unreachable from UI.**
- File: `Win98/Core/BevelModifier.swift:9`, `122-132`

**[P2] [Visual] [Taskbar]: Clock timer fires every 30 seconds (not 60) — functionally harmless but unnecessarily battery-inefficient.**
- File: `Win98/Desktop/TaskbarView.swift:8`

**[P2] [Feature] [StartMenu]: Favorites, Documents, Find menu items have no submenus — they dismiss the menu on tap with no content.**
- File: `Win98/StartMenu/StartMenuView.swift:47-74`

**[P2] [Visual] [Window]: Resize handle has no visual indicator (just transparent Rectangle) — user has no affordance to discover resize interaction.**
- File: `Win98/Core/Win98Window.swift:139-163`

### P3 — Code Quality / Minor Gap
**[P3] [Code Quality] [StartMenu]: "Log Off Ryan..." has a hardcoded personal name.**
- File: `Win98/StartMenu/StartMenuView.swift:91`

**[P3] [Visual] [Typography]: Entire UI uses Menlo (monospaced) instead of Tahoma or MS Sans Serif (proportional) — Menlo is correct for Notepad content but Win98 UI chrome used proportional fonts. This affects all labels, menus, and title bars.**
- File: `Win98/Core/Win98Theme.swift:59-69`

**[P3] [Feature] [DesktopContextMenu]: All context menu items (Arrange Icons, Refresh, Paste, New, Properties) are no-ops.**
- File: `Win98/Desktop/DesktopView.swift:157-186`

**[P3] [Feature] [MyComputer]: Toolbar Back/Forward/Cut/Copy buttons are decorative — no navigation state managed.**
- File: `Win98/Apps/MyComputerView.swift:50-57`

**[P3] [Feature] [Solitaire]: No Draw 1 / Draw 3 mode toggle (Win98 Solitaire supported both).**
- File: `Win98/Apps/SolitaireView.swift`

---

## Summary

| Severity | Count |
|----------|-------|
| P0       | 1     |
| P1       | 5     |
| P2       | 6     |
| P3       | 5     |
| **Total**| **17** |

**Build status: FAIL** — one compiler error (P0) blocking all testing.

**Architecture: Sound.** The window system design, game model separation, bevel rendering, and color system are all well-structured. No stubs, no Lorem placeholders, no dead placeholder functions.

**Priority fix order:**
1. `var activeWindowID` (P0 — unblocks everything)
2. Solitaire tableau drag onEnded (P1 — core gameplay)
3. Minesweeper window auto-resize for difficulty (P1 — playability)
4. Notepad Find implementation (P1 — functionality)
5. Start menu Y positioning math (P2 — UI correctness)
