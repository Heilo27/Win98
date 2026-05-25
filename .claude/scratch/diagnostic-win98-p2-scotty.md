# Win98 iOS — Phase 2A Code/Architecture/Security Diagnostic
**Scotty — Code, Architecture & Security Review**
**Date:** 2026-05-25

---

## Summary

Reviewed all 15 source files across Core, Desktop, StartMenu, Icons, and Apps. No security vulnerabilities found (this is an entirely local, no-network app). Architecture is broadly sound for a retro toy project. Key concerns are in Solitaire's drag system, Calculator's chained-operator logic, Minesweeper's timer leak, and several Win98 fidelity gaps. Full issue list follows.

---

## Issues

---

### ARCHITECTURE

**[P1] Architecture [WindowManager/Win98Window]: bringToFront called on every drag event — excessive objectWillChange floods**

In `Win98Window.swift` titleBar drag `.onChanged`, `windowManager.bringToFront(windowState.id)` is called every frame of the drag. `bringToFront` increments `nextZIndex` and calls `objectWillChange.send()` on the WindowManager on every pixel of movement. This causes every window in the hierarchy to redraw on every drag frame.

Fix: call `bringToFront` only once at `.onChanged` start (add a `hasBroughtToFront` @State guard cleared in `.onEnded`), not every delta.

---

**[P1] Architecture [WindowManager]: zIndex leaks unboundedly — no compaction**

`nextZIndex` is a monotonically-increasing Int that is never reset or compacted. After extended use (open/close/drag many windows), zIndex values will be large integers. While this doesn't crash, it means `Double(windowState.zIndex)` passed to SwiftUI's `.zIndex()` modifier could theoretically drift into precision issues, and `activeWindowID` computation using `.max(by:)` iterates all windows every frame.

Fix: compact zIndex values when a window is brought to front (renumber 1..N in current sorted order).

---

**[P2] Architecture [DesktopView]: double z-ordering for windows — sorted in SwiftUI AND .zIndex modifier**

`DesktopView` both `.sorted { $0.zIndex < $1.zIndex }` the windows array before the `ForEach` AND also applies `.zIndex(Double(win.zIndex))` on each window view. The sort is redundant — SwiftUI's `.zIndex` already controls render order within a ZStack. The double-system is not wrong but wastes a sort on every WindowManager change.

Fix: remove the `.sorted` — rely solely on `.zIndex` modifier, which SwiftUI handles correctly.

---

**[P2] Architecture [DesktopView]: `screenSize` captured at `.onAppear` only — stale on rotation**

`@State private var screenSize: CGSize = .zero` is set once in `.onAppear`. On device rotation or iPad split-view resize, `screenSize` is never updated. This causes windows to clamp to wrong boundaries and toggleMaximize to set wrong dimensions.

Fix: update `screenSize` in a `.onChange(of: geo.size)` modifier as well.

---

**[P2] Architecture [Solitaire/WindowManager]: `SolitaireView` holds a `winTimer: Timer?` as `@State` — Timer in @State**

`winTimer` is stored as `@State private var winTimer: Timer? = nil` inside `SolitaireView`. SwiftUI may recreate view structs; while `@State` persists the timer reference across recompositions, this pattern is fragile and not idiomatic. If the view is removed from the hierarchy (window closed), the timer is NOT invalidated because `SolitaireView` has no `onDisappear` cleanup. The Timer will continue firing and mutating `winBalls` even after the window is closed.

Fix: move `winTimer` into `SolitaireGame` (an `ObservableObject`), add `deinit { winTimer?.invalidate() }`, or add `.onDisappear { stopWinAnimation() }` to the view.

---

**[P2] Architecture [MinesweeperGame]: Timer leak on window close**

`MinesweeperGame.timer` (the elapsed-time timer) is started in `initBoard` and only invalidated on `newGame()` or game-over/win. If the Minesweeper window is closed mid-game, `closeWindow` removes the `Win98WindowState` but the `MinesweeperGame` `@StateObject` is held by `DesktopView`'s `windowView(for:)` via `AnyView` — but actually it's a `@StateObject` inside `MinesweeperView`, which IS torn down with the view. However, the Timer's closure captures `[weak self]` correctly, so the timer will fire once after dealloc then do nothing. Low risk but leaves dangling timer callbacks. The `MinesweeperGame` should add `deinit { timer?.invalidate() }`.

---

**[P3] Architecture [StartMenu]: Submenus use hardcoded pixel offsets (`offset(x: 175, y: -10)`) — fragile layout**

`ProgramsSubmenu`, `AccessoriesSubmenu`, and `GamesSubmenu` all use hardcoded `offset(x: 150/175, y: -10)` to position child submenus. These offsets are relative to the overlay anchor and will break if menu item heights or widths change. On smaller screens the submenu can render off-screen with no clamping.

---

**[P3] Architecture [Win98Window]: resize handle position uses `.position()` which is center-relative — off by half**

```swift
resizeHandle
    .position(x: windowState.size.width - 5, y: windowState.size.height - 5)
```

`.position()` places the view's CENTER at those coordinates. The 16×16 handle's center is placed 5pt from the bottom-right of the window, meaning the actual handle extends from (width-13) to (width+3) and (height-13) to (height+3) — half the handle is outside the window frame. The visual resize target is partially clipped.

Fix: use `.frame()` + `.offset()` or account for the half-size: `position(x: size.width - 8, y: size.height - 8)`.

---

**[P3] Architecture [QuickLaunchArea]: Uses `UIScreen.main.bounds.size` instead of GeometryReader**

`windowManager.openApp(.myComputer, screenSize: UIScreen.main.bounds.size)` in `QuickLaunchArea` hardcodes the screen size via the deprecated `UIScreen.main`. On iPad multitasking or Stage Manager this returns the full physical screen, not the app window bounds.

Same issue exists in `ProgramsSubmenu`, `AccessoriesSubmenu`, `GamesSubmenu`, and `SettingsSubmenu` — all pass `UIScreen.main.bounds.size` to `openApp`.

Fix: thread `screenSize` down from `DesktopView` via environment or pass it through `WindowManager`.

---

### CODE REVIEW

**[P1] Code [Calculator]: Chained operator with pending computation double-assigns `firstOperand` after compute()**

In `setOperator`:
```swift
private func setOperator(_ op: String) {
    if !waitingForSecond {
        if firstOperand != nil && !justCalculated {
            compute()         // this sets firstOperand = result, currentOperator = nil
        }
        firstOperand = Double(displayText)   // ← overwrites result with displayText
    }
    ...
}
```

After `compute()` runs, `firstOperand` is set to `result` and `displayText` is the formatted result string. The line `firstOperand = Double(displayText)` then re-reads `displayText` and re-assigns. This is actually functionally correct in the common case (result == Double(formatResult(result))), BUT `formatResult` uses `"%.10g"` which may lose precision for large numbers. E.g., `12345678901234 + 1 =` then `* 2` — the intermediate `firstOperand` set from `displayText` loses precision that `Double(result)` would have preserved.

Fix: after `compute()`, don't re-assign `firstOperand` from display — `compute()` already sets it to the exact result.

---

**[P1] Code [Calculator]: `backspace()` doesn't handle negative-sign-only state**

If user enters `5`, presses `+/-` to get `-5`, then backspaces twice:
1. Backspace: displayText = "-" (single character, count > 1, so it drops the "5" → "-")
2. Backspace: displayText.count == 1, so displayText = "0"

Step 1 leaves `displayText = "-"`, which is not a valid number. Subsequent operations calling `Double(displayText)` return `nil`, and the `?? 0` fallback silently uses 0. This means typing `-5 backspace backspace +3 =` gives 3 instead of 3.

Fix: add a check: if result of dropLast is "-" or ".", set to "0".

---

**[P1] Code [Calculator]: `formatResult` crashes on `Int(val)` for very large doubles**

```swift
if val == Double(Int(val)) && !val.isInfinite && !val.isNaN {
    return String(Int(val))
}
```

`Int(val)` will crash with a runtime exception (EXC_BAD_INSTRUCTION) if `val` is outside `Int.min...Int.max` range (e.g., `9999999999999999.0 * 9999999999999999.0`). The `!val.isInfinite` guard does not protect against values that are finite but exceed Int64 range.

Fix:
```swift
if !val.isInfinite && !val.isNaN && val >= Double(Int.min) && val <= Double(Int.max) && val == val.rounded() {
    return String(Int(val))
}
```

---

**[P1] Code [Solitaire]: Drag drop uses predicted end location but position math assumes fixed geometry**

`handleDrop(at: val.predictedEndLocation)` uses SwiftUI's predicted end location (extrapolated). The column hit-testing in `handleDrop`:
```swift
let colX = padding + CGFloat(toCol) * (cardWidth + spacing) + cardWidth / 2
if abs(location.x - colX) < cardWidth / 2 {
```
This math (`padding=8, spacing=6, cardWidth=60`) places column centers at x = 8 + col*(66) + 30. But this assumes the drop is in the absolute coordinate space of the ZStack root. `val.predictedEndLocation` is in the coordinate space of the DragGesture's view (the waste card or tableau card), NOT the root ZStack. The coordinate spaces don't match — all tableau drops will be systematically wrong by the card's position offset.

This is a fundamental geometry bug. Drops to tableau columns are unreliable; the waste → foundation path that doesn't use location works correctly only because it doesn't use the location at all (it calls `moveWasteToFoundation()` first regardless of drop location).

Fix: use named coordinate spaces with `coordinateSpace(name:)` and `DragGesture(coordinateSpace:)` to get location in a consistent space, or use `GeometryReader` + `PreferenceKey` to capture column frames.

---

**[P1] Code [Solitaire]: `TableauColumn` drag `.onEnded` doesn't call `handleDrop` — moves are never executed**

In `TableauColumn`:
```swift
.onEnded { _ in
    draggedCards = []
    dragSource = nil
    dragOffset = .zero
}
```

The `.onEnded` just clears state. It never calls `handleDrop`. The actual `handleDrop` is only called from the waste card's drag `.onEnded` in `SolitaireView`. Dragging from tableau to tableau or tableau to foundation never triggers a move — cards snap back to their original position every time.

Fix: pass a `handleDrop` closure into `TableauColumn` or observe `dragSource`/`dragOffset` changes in the parent and call `handleDrop` from `SolitaireView`'s overlay gesture.

---

**[P2] Code [Solitaire]: Win animation timer captures `self` as struct — `[self]` captures a copy**

```swift
winTimer = Timer.scheduledTimer(withTimeInterval: 1.0/30.0, repeats: true) { [self] _ in
    DispatchQueue.main.async {
        updateWinAnimation()
    }
}
```

`SolitaireView` is a struct. `[self]` in a closure captures a VALUE COPY of the struct at the time of capture. `updateWinAnimation()` mutates `winBalls` via `self`, but since `self` is a copy, those mutations don't affect the actual rendered state. The win animation balls will never move.

Fix: move `winBalls`, `winTimer`, and animation logic into `SolitaireGame` (the `ObservableObject`) where reference semantics apply, or use a separate `@StateObject` animation controller.

---

**[P2] Code [Solitaire]: `moveCards` doesn't score when moving tableau-to-tableau face-up cards**

`moveCards` appends cards and removes from source, but the only scoring is in `flipTopCard` (+5 for flipping a face-down card). Windows 98 Solitaire awards points for tableau-to-foundation moves (already done) but this is correct as-is. However, there's no penalty for time or undo. Not a bug per spec, but noting for completeness.

---

**[P2] Code [Minesweeper]: Expert grid (16×30 = 480 cells × 18pt = 540pt wide) overflows window**

Expert difficulty is 16 rows × 30 cols. Each cell is 18×18pt. Grid width = 30 × 18 = 540pt. The default Minesweeper window size is `CGSize(width: 200, height: 240)`. The grid is 2.7× wider than the window — it will be clipped and unplayable. There's no ScrollView on the grid.

Fix: either (a) dynamically size the window to match the grid + chrome padding, or (b) wrap `mineGrid` in a `ScrollView([.horizontal, .vertical])`, or (c) cap minimum window size per difficulty.

---

**[P2] Code [Minesweeper]: Flag cycling skips `initialized` check — can flag before first reveal**

`toggleFlag` doesn't check `!initialized`. On a fresh board (before the first reveal), the user can flag cells, revealing the fact that no mines are placed yet (all flags are technically wrong). This isn't exploitable for cheating since mines haven't been placed, but it's an inconsistency: flagged cells show `🚩` but the cell has `isMine = false`. Win/loss logic isn't affected. Still, Win98 Minesweeper doesn't allow flagging before the first click.

---

**[P2] Code [Notepad]: "Save" and "Save As" mark `isDirty = false` without actually saving content**

```swift
private func saveFile() {
    // Save implementation
    isDirty = false
}
private func saveFileAs() {
    isDirty = false
}
```

Both functions stub out saving by only clearing the dirty flag. The user gets no feedback that save did nothing. More importantly, `isDirty` becomes false, so the "unsaved changes" alert won't trigger on New — user's content can be silently lost.

This is P2 for the retro context (real file I/O isn't expected), but the dirty flag should NOT be cleared if no actual save occurred, or a visual toast/indicator should communicate the stub state.

---

**[P2] Code [Notepad]: "Exit" menu item does nothing — doesn't close the window**

```swift
Win98MenuBarItem("Exit") {},
```

On Win98, File > Exit closes the application (here: closes the Notepad window). This is wired to an empty closure. The window manager is accessible via `@EnvironmentObject` — it's just unwired.

---

**[P2] Code [Notepad]: Find dialog "Find Next" button does nothing**

```swift
Win98Button(title: "Find Next") {}
```

The Find Next action in the dialog is a no-op. The `findText` binding is wired to the text field but no search logic runs. The menu item "Find Next" is also no-op. Low priority given retro toy scope but noted.

---

**[P2] Code [Win98Window]: Title bar drag and double-tap-maximize conflict**

The title bar has both a `DragGesture` AND a `.onTapGesture(count: 2)` for maximize. On iOS, a double-tap that moves slightly will be interpreted as drag+drag rather than double-tap, silently ignoring the maximize intent. Conversely, a slow double-tap may trigger the drag gesture instead. SwiftUI's gesture disambiguation on iOS prefers longer gestures. This is inherent to combining these gestures on the same view without `.exclusively(before:)`.

---

**[P2] Code [DesktopIcon]: Single-tap and double-tap race on iOS**

```swift
.onTapGesture(count: 2) { onOpen() ... }
.onTapGesture(count: 1) { isSelected = true }
```

On iOS, SwiftUI processes `count: 1` immediately without waiting to see if a second tap follows. Both gestures fire on double-tap: first the `count: 1` (selects), then the `count: 2` (opens). This is the documented SwiftUI behavior. The result is correct (icon opens), but there's a brief flash of selection state before open. More importantly, on desktop (macOS) behavior is correct, but since this targets iOS, `.onTapGesture` doesn't have a built-in "wait for second tap" delay.

Fix for cleaner iOS behavior: use a single `.onTapGesture` with a manual timer-based double-tap detection, or use `@GestureState` with `SequencedGesture`.

---

**[P3] Code [BevelModifier]: Canvas `drawLine` creates a new Path per line call — 8 Path allocations per bevel**

Each of the 8 `drawLine` calls in `drawRaised`/`drawSunken`/`drawWell` creates a new `Path()`, moves, adds a line, and strokes. This is 8 heap allocations per bevel render. Given that bevel is used on every button, cell, and window border, this compounds. 

Fix: batch all lines for a bevel style into a single Path with multiple subpaths and stroke once, or pre-build static Path templates.

---

**[P3] Code [Calculator]: `computeSqrt` of negative number shows "Invalid input for function" but leaves `justCalculated = false` — inconsistent**

Actually on re-read: `computeSqrt` DOES set `justCalculated = true` (line 194). But it does NOT reset `firstOperand` or `currentOperator`. So after sqrt of negative, the calculator is in an error state with `displayText = "Invalid input..."` but `firstOperand` still holds the previous value and `currentOperator` the previous op. Pressing a digit will start a new number correctly (since `justCalculated = true`), and pressing `=` will try to compute with the old `firstOperand` against the new number, which may be surprising.

Win98 Calculator's actual behavior: error state clears to require CE/C before new operation. This isn't enforced here.

---

**[P3] Code [Win98Font]: Uses Menlo as the Win98 system font — wrong typeface**

Win98 used "MS Sans Serif" (a proportional sans-serif) for UI text and "Courier New" / "MS Gothic" for terminals. Menlo is a macOS monospace font with different metrics. The proportional vs. monospace difference is visible everywhere (menus look spaced-out, title bars look off).

Workaround within iOS constraints: "Arial" or "Helvetica" is closer to MS Sans Serif proportionally. This is a P3 since the project may intentionally use Menlo for aesthetic consistency, but noting for fidelity.

---

**[P3] Code [Win98MenuBarButton]: `foregroundColor` set twice — redundant modifier**

```swift
Text(title)
    .foregroundColor(Win98Color.darkText)   // ← first
    ...
    .foregroundColor(isOpen ? Win98Color.titleText : Win98Color.darkText)  // ← second (redundant first)
```

The first `.foregroundColor` is overridden by the second. Dead code.

---

**[P3] Code [DesktopView]: `windowContent(for:)` uses `default:` in switch on exhaustive enum — hides future cases**

```swift
default:
    Text("Not implemented")
```

`Win98AppType` is exhaustive and all cases are handled above the `default`. The `default` branch catches nothing today but will silently produce "Not implemented" if a new case is ever added to the enum without updating the switch. Use explicit case matching with no default.

---

**[P3] Code [TaskbarView]: Timer fires every 30 seconds — clock updates are visibly stale**

```swift
let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
```

Win98's taskbar clock updates every minute, but updates at the :00 second boundary, not 30s after app launch. Using a 30s interval means the displayed time can be up to 30 seconds stale and never aligns to real minute boundaries. The initial time is set in `.onAppear`, so at worst 30s drift is visible.

Fix: use a 1-minute timer triggered at the next :00 boundary (Calendar-based), or simply use 60s interval aligned to `.nextDate(after: Date(), matching: DateComponents(second: 0))`.

---

**[P3] Code [Solitaire]: `winBalls` seeded with `prefix(20)` from foundations — may show fewer than 20 cards**

```swift
winBalls = game.foundations.flatMap { $0 }.prefix(20).map { ... }
```

At win time, all 52 cards are in foundations. `flatMap` gives 52 cards, `prefix(20)` picks the first 20. This is fine as-is. Minor note: the original Win98 Solitaire win animation bounces all cards, one suit column per pile. P3 cosmetic only.

---

**[P3] Code [ShutDownDialog]: "OK" and "Cancel" both dismiss with same action — no differentiation**

```swift
Win98Button(title: "OK") { windowManager.showShutDownDialog = false }
Win98Button(title: "Cancel") { windowManager.showShutDownDialog = false }
```

Both OK and Cancel do identical things. Win98 "Shut Down" dialog's OK would trigger shutdown; here since there's no real shutdown, OK should perhaps present a "shutting down" animation or at minimum be visually distinct.

---

### SECURITY

**[PASS] Security: No hardcoded credentials, API keys, or tokens found in any file.**

**[PASS] Security: No network requests, URL loading, or external data exfiltration. Fully local app.**

**[PASS] Security: No file I/O to arbitrary paths. `openFile()` loads a hardcoded sample string only.**

**[PASS] Security: No use of `eval`-equivalent, dynamic code execution, or unsafe Swift features.**

**[PASS] Security: `Color(hex:)` extension handles malformed hex gracefully (default case returns nearly-transparent black — not a crash).**

---

## Issue Count Summary

| Priority | Count |
|----------|-------|
| P0       | 0     |
| P1       | 5     |
| P2       | 12    |
| P3       | 10    |
| **Total**| **27**|

---

## Top 5 Most Critical Fixes

1. **[P1] Solitaire tableau drag `.onEnded` never calls `handleDrop`** — tableau-to-tableau drags are completely non-functional.
2. **[P1] Solitaire win animation timer captures struct copy `[self]`** — win animation balls never move.
3. **[P1] Calculator `formatResult` Int overflow crash** — reproducible with large multiplication results.
4. **[P1] Calculator backspace leaves `"-"` in display** — subsequent arithmetic silently uses 0.
5. **[P2] Minesweeper Expert grid (540pt) overflows 200pt window** — expert mode unplayable.
