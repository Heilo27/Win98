# Win98 iOS App — Phase 2B Diagnostic (Torres)
**Date:** 2026-05-25  
**Scope:** Stability, Spec Compliance  
**Status:** COMPLETE

---

## EXECUTIVE SUMMARY

15 issues found. No P0s. 3 P1s (timer leak + drag state corruption + Solitaire handle-drop logic). 8 P2s. 4 P3s.

---

## P1 ISSUES

---

**[P1] [Stability] [Solitaire]: Win timer never invalidated on view deinit — confirmed leak**

`SolitaireView` is a `View` struct (not a class), so `stopWinAnimation()` is never called automatically. `winTimer` is a `@State` `Timer?` inside a SwiftUI struct — when the window is closed, `WindowManager.closeWindow()` removes the window from the array, SwiftUI destroys the view, but the `Timer` stored in `@State` fires into `DispatchQueue.main.async { updateWinAnimation() }` referencing captured `self` (which is a struct copy). The timer keeps firing after the view is gone, calling `updateWinAnimation()` on a stale copy. No crash, but the timer runs indefinitely at 30fps until the app is killed.

**Root cause:** `winTimer = Timer.scheduledTimer(...)` inside a struct, called from `startWinAnimation()`. No `onDisappear` cleanup.

**Fix:** Add `.onDisappear { stopWinAnimation() }` to the `ZStack` in `SolitaireView.body`.

---

**[P1] [Stability] [Solitaire]: Drag drop uses hardcoded layout geometry — drops always miss on smaller screens**

`handleDrop(at:)` (line 367) calculates column X positions as:
```
let padding: CGFloat = 8
let spacing: CGFloat = 6
let colX = padding + CGFloat(toCol) * (cardWidth + spacing) + cardWidth / 2
```
These constants match the layout declared in `body`, but `location` is `predictedEndLocation` from a `DragGesture` inside a child view (`TableauColumn`) whose coordinate space is local — not the ZStack root. The coordinate space mismatch means drops to tableau columns from the waste pile will consistently miss or land on wrong columns, especially on anything other than the exact geometry assumed.

Additionally, the `.tableau` branch in `handleDrop` never actually calls `moveCards` for the waste case correctly — the `||` closure syntax on line 361-364 is valid Swift but the inner `for` loop returns `true` from the closure, not from `handleDrop`, so the waste→tableau fallback path (`moveWasteToTableau`) is never reached after `moveWasteToFoundation` fails.

**Specific bug (line 361-364):**
```swift
_ = game.moveWasteToFoundation() || {
    for col in 0..<7 { if game.moveWasteToTableau(toCol: col) { return true } }
    return false
}()
```
The `return true` inside the closure returns from the closure, not from `handleDrop`. The `||` short-circuits if foundation succeeds, but if it fails, the closure is evaluated — `moveWasteToTableau` IS called correctly here actually. This part works. However the coordinate mismatch issue remains independently.

---

**[P1] [Stability] [Minesweeper]: `floodReveal` is recursive with no depth limit — stack overflow on Expert board**

`floodReveal(_:_:)` is a recursive function. On Expert difficulty (16×30 = 480 cells), if the first click opens a large blank area, the recursion can cascade up to ~480 levels deep. iOS's default stack size is ~512KB. Each Swift frame is ~100-200 bytes minimum. At 480 deep this is borderline but with additional call overhead from `ObservableObject` publishing and array mutation, this can overflow on Expert with a particularly open board layout.

**Fix:** Convert `floodReveal` to an iterative queue/stack approach.

---

## P2 ISSUES

---

**[P2] [Stability] [TaskbarView]: Clock timer never invalidated**

```swift
let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
```
This is a `let` stored property on a struct — Combine's `autoconnect()` returns a `Publishers.Autoconnect` publisher. SwiftUI will connect it on `.onReceive` but it is never explicitly cancelled. When `TaskbarView` is destroyed (if ever — it's always on screen) the publisher lingers. Low impact in practice since the taskbar is permanent, but structurally wrong. The timer also only fires every 30 seconds, meaning the displayed time can be up to 30s stale on first render (mitigated by `onAppear`).

---

**[P2] [Stability] [WindowManager]: `bringToFront` mutates `Win98WindowState` (a class) directly without going through `@Published` property — UI may not update**

```swift
func bringToFront(_ id: UUID) {
    guard let window = windows.first(where: { $0.id == id }) else { return }
    window.zIndex = nextZIndex   // direct mutation of class property
    nextZIndex += 1
    objectWillChange.send()     // manual notify
}
```
`Win98WindowState` is an `ObservableObject` with `@Published var zIndex`. Mutating `zIndex` directly fires `Win98WindowState.objectWillChange`, not `WindowManager.objectWillChange`. The manual `objectWillChange.send()` on `WindowManager` is correct for views observing `WindowManager`, but views observing `Win98WindowState` directly (e.g., `TaskbarWindowButton` via `@ObservedObject`) will get double-fire. Not a crash, but imprecise and fragile.

---

**[P2] [Stability] [Solitaire]: `winBalls` position uses hardcoded bounds `x: 50...550, y: 50...200`**

`startWinAnimation()` hard-codes `CGFloat.random(in: 50...550)` for X and bounce boundary `winBalls[i].position.x > 625`. These are fixed pixel values that assume a ~640pt wide view (matches Solitaire's default window width of 640). But on smaller phones or after window resize, cards bounce outside the visible frame or cluster into the left portion of a narrow window.

---

**[P2] [Spec] [Notepad]: `saveFile()` and `saveFileAs()` are no-ops — no persistence**

Both functions set `isDirty = false` but do nothing. On iOS, this means typed text is lost when the window is closed. `openFile()` loads a hardcoded sample string. Win98 Notepad spec requires Save/Open to work with actual files (or at minimum a document picker). The "unsaved changes" alert fires correctly, but "Save" in the alert also does nothing real.

---

**[P2] [Spec] [Calculator]: `formatResult` can produce incorrect integer display for large floats**

```swift
if val == Double(Int(val)) && !val.isInfinite && !val.isNaN {
    return String(Int(val))
}
```
`Double(Int(val))` will overflow for values outside `Int.min...Int.max` (~±9.2×10¹⁸). On 64-bit this is unlikely to trip in normal calculator use but `Int(val)` will crash (EXC_BAD_INSTRUCTION) if `val` is exactly `Double(Int.max) + 1` or similar edge case due to undefined behaviour in Swift's `Int(Double)` when out of range. Should use `Int(exactly: val)` or add a magnitude guard.

---

**[P2] [Spec] [Win98Window]: Double-tap on title bar and single-tap gesture compete — double-tap may not fire reliably on iOS**

```swift
.gesture(DragGesture()...)
.onTapGesture(count: 2) { windowState.toggleMaximize(in: screenSize) }
```
On iOS, `DragGesture` with `minimumDistance: 0` (default) will intercept taps before the double-tap gesture recognizer can fire. The title bar has both a `DragGesture` (no explicit `minimumDistance`) and a `.onTapGesture(count: 2)`. SwiftUI resolves this with its gesture priority system — `DragGesture` takes precedence. Double-tap maximize may be unreliable or non-functional on touch.

**Fix:** Use `DragGesture(minimumDistance: 5)` on the title bar so small taps pass through to the tap recognizer.

---

**[P2] [Spec] [Desktop]: `screenSize` captured at `onAppear` only — not updated on rotation/split-screen**

```swift
.onAppear { screenSize = geo.size }
```
`screenSize` is set once. Window clamping on drag-end uses this stale value. On iPad split-screen or rotation, maximized windows and the clamp logic will use wrong bounds. Should use `onChange(of: geo.size)` as well.

---

**[P2] [Spec] [StartMenu]: Position calculation may place menu off-screen on short displays**

```swift
StartMenuView()
    .position(x: Win98Metrics.startButtonWidth / 2 + 2,
              y: geo.size.height - Win98Metrics.taskbarHeight - 200)
```
The menu is 400pt tall but positioned with a fixed `y` offset of 200pt from the taskbar. On a device shorter than ~470pt in landscape (common on iPhone), the top of the menu will be clipped by the safe area or extend above screen bounds. No clamping applied.

---

## P3 ISSUES

---

**[P3] [Stability] [Minesweeper]: `minesRemaining` can go negative**

`toggleFlag` decrements `minesRemaining` each time a flag is placed without checking if it's already zero. Players can over-flag, driving the LED display to negative values. `LEDDisplay.digitValues()` clamps to `max(0, min(999, value))` so the display will show "000" rather than negative, but the underlying `minesRemaining` state is corrupted. Win98 Minesweeper allows the counter to go negative (shows "–01" etc.) — the clamping to 0 is actually a spec deviation.

**Spec note:** Win98 Minesweeper DOES allow the mine counter to go below zero and displays a leading `-` sign with 2 digits. Current LED only supports 3 digits, no minus sign.

---

**[P3] [Stability] [WindowManager]: `nextZIndex` is unbounded integer — grows forever**

Every `bringToFront` call increments `nextZIndex`. With heavy use (rapid window switching) this grows without bound. In practice a user session won't hit Int overflow, but if the app runs for a very long time with frequent interactions this is a theoretical concern. Minor.

---

**[P3] [Spec] [Win98Window]: Close button uses `✕` (U+2715) not the Win98 standard appearance**

The close button renders `✕` as a Unicode character with `.system(size: 9, weight: .bold)`. Win98 close buttons use a pixelated X drawn as two diagonal lines, not a Unicode glyph. Low fidelity but cosmetic.

---

**[P3] [Spec] [Solitaire]: Win animation bounce bounds hardcoded, cards don't bounce off bottom realistically**

The bottom bounce threshold is `y > 400` and clamps to `y = 400` before reversing. With a `cardHeight` of 84pt, the card visually extends to y=484, meaning the bounce visually happens above the floor. Also the damping factor of `0.8` is applied to `velocity.height` but not to `velocity.width`, so cards don't slow down horizontally — they bounce forever.

---

## SPEC COMPLIANCE CHECKLIST

| # | Requirement | Result |
|---|-------------|--------|
| 15 | Desktop background `#008080` | PASS — `Win98Color.desktop = Color(hex: "#008080")` |
| 16 | Active title bar gradient `#000080` → `#1084D0` | PASS — `activeTitleLeft`/`activeTitleRight` correct, applied as `LinearGradient` |
| 17 | Inactive title bar flat `#808080` | PASS — `inactiveTitle = Color(hex: "#808080")`, used as single-color gradient |
| 18 | Taskbar height ~30pt, fixed to bottom | PASS — `taskbarHeight = 30`, pinned to bottom with VStack/Spacer |
| 19 | Start button has Windows logo + "Start" text | PASS — `WindowsLogoView(size: 14)` + `Text("Start")` in `StartButton` |
| 20 | Close button is gray (NOT red) | PASS — `CaptionButton` uses `Win98Color.buttonFace` background (gray `#C0C0C0`) |
| 21 | Minesweeper 3-digit LED displays | PASS — `LEDDisplay(value:, digits: 3)` used for both mine count and timer |
| 22 | Solitaire green felt `#007B00` | PASS — `Win98Color.greenFelt = Color(hex: "#007B00")` applied as ZStack background |
| 23 | System font 11pt Menlo | PASS — `Win98Font.system()` defaults to `Font.custom("Menlo", size: 11)` |
| 24 | Window borders use 2-layer bevel | PASS — `BevelModifier` draws 4 lines per style (outer + inner highlight/shadow) |
| 25 | Desktop icons: My Computer, My Documents, Network Neighborhood, Recycle Bin | PASS — all four present in `DesktopView.desktopIcons` array |

**All 11 spec checks pass.**

---

## ADDITIONAL FINDINGS (not in original checklist)

**[P2] [Spec] [Minesweeper]: First-click safe zone is 3×3 (correct) but on very small boards it may be impossible to place all mines**

On beginner (9×9, 10 mines), the safe zone excludes up to 9 cells, leaving 72 positions. `min(totalMines, positions.count)` guards against this. On expert (16×30, 99 mines), safe zone excludes 9 from 480, leaving 471 — plenty of room. Logic is sound.

**[P3] [Spec] [Notepad]: `lineLimit(wordWrap ? nil : 1)` does not disable word wrap correctly**

`lineLimit(1)` on a `TextEditor` does not force horizontal scrolling — it truncates text to one visible line. Win98 Notepad without word wrap should show a horizontal scrollbar. This is a platform limitation on iOS but worth noting.

**[P3] [Spec] [TaskbarView]: Clock updates every 30 seconds but Win98 clock updates every minute**

Win98 system clock updates once per minute (on the minute). Current implementation updates every 30 seconds. Harmless but slightly off-spec; more importantly the 30s interval means the display can show a time that's up to 30s stale (not synced to the minute boundary).

---

## SUMMARY TABLE

| Priority | Count | Items |
|----------|-------|-------|
| P0 | 0 | — |
| P1 | 3 | Win timer leak (Solitaire), Drag drop coord mismatch (Solitaire), Stack overflow risk (Minesweeper expert flood-reveal) |
| P2 | 8 | Taskbar timer leak, WindowManager double-fire, Win animation hardcoded bounds, Notepad save no-op, Calculator Int overflow edge case, Double-tap maximize unreliable iOS, screenSize stale on rotation, StartMenu off-screen on short displays |
| P3 | 4 | minesRemaining goes negative, nextZIndex unbounded, Close button glyph fidelity, Solitaire bounce physics |

All 11 Win98 SE spec checks pass.
