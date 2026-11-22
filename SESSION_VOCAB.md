# DeltaV Equipment Module Study Guide — `EM_TANK_CHARGE`

Strictly native DeltaV Control Studio vocabulary, architecture rules, and study notes for `EM_TANK_CHARGE`.

---

## 1. The Three Equipment Levels (Who Talks to Whom)

| Term | Full Name | Plain-English Job in `EM_TANK_CHARGE` |
| :--- | :--- | :--- |
| **EPH** | Equipment Phase | **The Recipe Boss.** Sits above the EM, acquires it, says "Charge 500 kg of solvent now," and watches until the EM reports Done (or Held/Aborted). |
| **EM** | Equipment Module | **The Team Coordinator** (`EM_TANK_CHARGE`). Coordinates the feed valve, tank scale, and agitator together as one task. Never wires directly to physical field terminals. |
| **CM** | Control Module | **The Single-Device Controller.** Owns one physical device: `CM_FEED_XV` (supply valve), `CM_TANK_WT` (scale), or `CM_AGIT_MTR` (agitator motor). |
| **Scan** | Module Scan Cycle | **One Heartbeat.** How often (e.g., 500 ms or 1 s) a module wakes up, reads inputs, solves FBD blocks in `#1 → #2 → #3` execution order, and updates outputs. |

---

## 2. Core Function Blocks (Boxes on the Control Studio Sheet)

| Block | Full Name | Plain-English Job |
| :--- | :--- | :--- |
| **SFC** | Sequential Function Chart | **Step-by-Step Checklist.** Runs one active Step at a time (`S0_IDLE` → `S10_CHARGE_OPEN` → `S20_TRIM_CLOSE` → `S30_AGITATE`) and waits on a Transition (`┼`) before moving on. |
| **CND** | Condition Block | **Yes/No Question Box.** Checks an expression (e.g., "Is weight at cutoff?" or "Did the scale go Bad?") and turns `OUT_D` ON when true. |
| **ACT** | Action Block | **"Write It Once" Stamp.** When triggered by an SFC step or CND block, writes a command or value and leaves it there until another ACT writes something new. |
| **CALC** | Calculation Block | **Scratchpad Calculator.** Runs every Scan to do math (like `DELIVERED_WT := CURRENT_WT - START_WT`) or combine logic. |
| **BSEL** | Selector Block | **Value Switch.** Picks one winning value from multiple inputs (such as Recipe Weight vs. Operator Local Weight). |
| **DC** | Device Control Block | **On/Off Equipment Driver.** Lives inside a valve or motor CM (`CM_FEED_XV`, `CM_AGIT_MTR`) to drive Open/Close or Start/Stop and check limit switches. |
| **AI** | Analog Input Block | **Sensor Reader.** Lives inside `CM_TANK_WT` to turn a raw sensor reading into engineering units (kg) plus a signal health tag (`.ST`). |

---

## 3. Operating Modes (Who Has the Steering Wheel?)

| Mode / Term | Full Name | Plain-English Meaning |
| :--- | :--- | :--- |
| **OOS** | Out of Service | **Locked Out in Software.** Stops normal control and marks wire `.ST` as Bad so upstream modules know not to trust it. |
| **MAN** | Manual | **Operator Has the Wheel.** A human sets the output directly; automated commands are ignored. |
| **AUTO** | Automatic | **Self-Driven.** Follows its own local target entered on its faceplate. |
| **CAS** | Cascade | **Following the Boss Upstairs.** When `CM_FEED_XV` is in `CAS`, it obeys Open/Close commands sent from `EM_TANK_CHARGE`. |
| **MODE.TARGET** | Target Mode | The mode you *request* a block to enter. |
| **MODE.ACTUAL** | Actual Mode | The mode the block is *truly* in right now (a local interlock can hold `MODE.ACTUAL` out of `CAS` even if `MODE.TARGET` asks for `CAS`). |

---

## 4. Wire Endings, Pins & Safety Words

| Term | Full Name | Plain-English Meaning |
| :--- | :--- | :--- |
| **Named Set** | Named Set Enumeration | **Word Labels for Numbers.** Lets logic read `Close / Open` or `Idle / Charge / Hold` instead of raw integers. |
| **Permissive** | Start Permissive | **Pre-Start Gate.** Must be true before leaving `S0_IDLE`. If false, the EM waits peacefully without tripping an emergency stop. |
| **Interlock (Trip)** | Active Interlock | **Mid-Run Safety Brake.** Watched every Scan while running. If violated (High-High level or scale `.ST = BAD`), immediately closes the valve and forces Hold/Abort. |
| **.CV** | Current Value | The live number or state on a pin right now (e.g., `340.5 kg` or `Open`). |
| **.ST** | Status | The health grade riding beside `.CV` (`GOOD`, `UNCERTAIN`, `BAD`). |
| **CAS_IN_D** | Cascade Input (Discrete) | The command inbox on a CM's `DC` block where the EM writes Open/Close or Start/Stop. |
| **PV_D** | Process Variable (Discrete) | Confirmed physical state on a `DC` block showing what field limit switches prove the device is actually doing. |

---

## 5. How to Decode Any DeltaV Path in 5 Seconds

Read slashes and dots left-to-right like a mailing address: **`Module / Block / Parameter.Detail`**

- `'CM_FEED_XV/DC1/MODE.ACTUAL' = CAS`
  - `CM_FEED_XV` → Feed Valve Control Module
  - `/DC1` → Its Device Control block
  - `/MODE.ACTUAL` → True current operating mode
  - `= CAS` → Listening to the EM
- `'^/TARGET_WT.CV'`
  - `^/` → Shortcut meaning "right here inside this module (`EM_TANK_CHARGE`)"
  - `TARGET_WT.CV` → Live value of Target Weight

---

## 6. 1 Outer Algorithm vs. 4 Inner Patterns

- **1 Outer Algorithm (DeltaV Menu Choice):** Pick **one** container when creating an EM:
  1. **Command-Driven** *(used by `EM_TANK_CHARGE`)* — Runs a multi-step SFC for each command in `A_COMMAND` (`255` = Idle).
  2. **State-Driven** — Single-step snap per state (common for valve headers).
  3. **Function Block Diagram (FBD)** — Continuous wire sheet every Scan, zero steps.
  4. **Sequential Function Chart (SFC)** — One standalone sequence chart.
- **4 Inner Patterns (Reading Checklist Inside the EM):**
  1. **Command, State & Step Progression (SFC — Top-to-Bottom):** *The only pattern that steps through time.*
  2. **Permissives & Interlocks (FBD — Always On):** Runs every Scan. Separates start gates (`CND1`) from active mid-run trips (`CND2` → `ACT1`).
  3. **Mode & Setpoint Routing (FBD — Always On):** Runs every Scan. Picks active weight (`BSEL1`), calculates net/remaining mass (`CALC1`), checks cutoff (`CND3`), pushes `MODE.TARGET := CAS` (`ACT2`).
  4. **CM Command & Feedback (FBD — Always On):** Runs every Scan. Pairs outbound `CAS_IN_D` commands with inbound `PV_D` limit-switch proof (`CND4`, `CND5`).

---

## 7. Control Studio Visual Rules

- **Execution Order (`#1`, `#2`, `#3`):** Bottom-right corner of each FBD block sets exact solve order during each Scan (math `CALC` must run before cutoff `CND`, which must run before close `ACT`).
- **Solid Orthogonal Wires:** Analog numeric `.CV` values (kg).
- **Dashed Orthogonal Wires:** Discrete True/False signals, mode checks, and status paths.
- **Pointed Margin Flags:** Left edge brings signals *into* the sheet; right edge writes commands/modes *out* to CMs.
- **SFC Shapes:** Double-bordered box = Initial Step (`S0_IDLE`); single-bordered box = Step (`S10`, `S20`, `S30`); horizontal crossbar (`┼`) = Transition (`T10`, `T20`, `T30`).

---

## 8. Next-Level `EM_TANK_CHARGE` Behavior

### Hold, Restart & Abort (and the Golden Tare Rule)
- **Tare Snapshot (`START_WT.CV`):** Captured **once** when transitioning `S0_IDLE → S10_CHARGE_OPEN`.
  - `DELIVERED_WT := 'CM_TANK_WT/AI1/OUT.CV' - '^/START_WT.CV'`
  - `REMAINING_WT := '^/TARGET_WT.CV' - '^/DELIVERED_WT.CV'`
- **HOLD (Safe Pause):** Triggered by operator or Pattern 2 interlock (`OUT.ST = BAD` or `HI_HI_LVL`). Immediately stamps `Close` onto `'CM_FEED_XV/DC1/CAS_IN_D'`, pauses step progression, and **preserves `START_WT.CV`**.
- **RESTART (Resume from Hold):** Once the fault clears and permissives are healthy again, resumes charging **without overwriting `START_WT.CV`**. (If you re-tared on Restart, the EM would forget the solvent already delivered and overfill the tank!)
- **ABORT (Full Emergency Stop):** Immediately closes `CM_FEED_XV`, stops `CM_AGIT_MTR`, exits the active charge command, and requires a Reset back to `S0_IDLE` before starting fresh.

### The Top Boundary (`EPH` → `EM` Handshake)
The Equipment Phase (`EPH`, Recipe Boss) coordinates with `EM_TANK_CHARGE` through three clean signals:
1. **Acquisition (Ownership):** The `EPH` acquires `EM_TANK_CHARGE` so no other phase or operator fights over the same tank header.
2. **Command & Recipe Parameters (Downward):** The `EPH` writes the command Named Set (`A_COMMAND := Charge`) into Pattern 1 and passes `RECIPE_WT` into Pattern 3 (`BSEL1`).
3. **State & Completion Feedback (Upward):** `EM_TANK_CHARGE` reports its live state (`IDLE`, `RUNNING`, `HELD`, `COMPLETE`, `ABORTED`) back up to the `EPH` so the recipe knows when to advance—or when to hold the whole batch.
