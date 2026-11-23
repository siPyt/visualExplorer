# DeltaV Control Studio — Verified Facts (from `pdf reference/`)

Every line below was read directly in the Emerson PDFs in `pdf reference/` and `additionalPDFs/`. Page numbers are **PDF page numbers**.
Doc keys (`pdf reference/`): **FBR** = Function Block Reference · **CONFIG** = DeltaV Configuration · **7009** = Implementation I (v15.LTS) ·
**7009-8** = 7009 SFC chapter · **7017** = Implementation II · **7016** = Batch · **PDS** = Control Studio On-line data sheet.
Doc keys (`additionalPDFs/`): **LIVE** = Hatch/Lakeside DeltaV Live Training (`837038695`) · **GS22** = Getting Started with Your DeltaV Software Feb 2022 (`684095348`) · **TIPS** = Users Exchange Tips & Tricks (`256307806`) · **PID4** = DeltaV PID Function Block (`406981499`) · **PLAN** = Planning & Designing DeltaV 2015 (`409873456`) · **COURSE** = DeltaV DCS Course (`782854867`) · **VIM** = Virtual I/O Module (`235392189`).

Anything NOT in this file is either our own training design (labeled as such in Visual Explorer) or unverified.

---

## 1. Control Studio On-Line — what you actually see

| What | Meaning | Source |
|---|---|---|
| **Bold connection line** | Wire is carrying a **non-zero value** | CONFIG p368 |
| **Dashed connection line** | **Feedback wire**: source block executes *after* the destination block, so the value arrives **next scan** | CONFIG p368 |
| Red **X** | Status of that parameter is **Bad** | CONFIG p368, PDS p3 |
| Blue **?** | Status of that parameter is **Uncertain** | CONFIG p368, PDS p3 |
| Yellow highlighted **?** | Block's **BLOCK_ERR** is non-zero | CONFIG p368 |
| White value box beside pin | Live value of that pin | PDS p3 |
| `#1 #2 #3 #4` bottom-right of block | Execution order | PDS p3 |
| Active SFC step | Bright **green border**; elapsed seconds shown under **every** step | PDS p5 |
| Transition | Cross symbol, name, and `True` / `False` underneath | PDS p5 |
| Transition drill-down | Expression tree: green ✓ = evaluated OK, red X = not satisfied, ? = parameter error | CONFIG p371 |
| Disabled step | Red X through the step | CONFIG p372 |
| Stopped FBD | Yellow arrow on next block to execute | CONFIG p369 |

> Solid vs. dashed in DeltaV does **NOT** mean analog vs. discrete. Dashed = feedback wire (execution order). (CONFIG p368)

## 2. Function blocks used in our modules

**Condition (CND)** — FBR p413–416
- Evaluates an expression; **no input pins** (operands are references written inside the expression). Output **OUT_D**.
- `OUT_D` sets only after the expression is True for **TIME_DURATION** seconds; also `PRE_OUT_D`, `DISABLE`, `TIMER`.
- Assignment `:=` is **not** allowed in a CND (CONFIG p62).
- Statuses normally GoodNonCascade; unresolved reference → Bad: Configuration Error (FBR p414).

**Action (ACT)** — FBR p400–402
- Input **IN_D** only. **No outputs.** Evaluates its expression **whenever IN_D is True**; result goes to an external reference.
- Requires the assignment operator `:=` (CONFIG p62). No modes, alarms or status handling.

**Calculation/Logic (CALC)** — FBR p179–181
- `IN1`…`IN16`, `OUT1`…`OUT16` (default 2 in / 2 out, extensible). Temporary variables allowed (CONFIG p65).

**Transfer (XFR)** — FBR p453–455
- `IN_1`, `IN_2`, `SELECTOR`, `OUT`. `SELECTOR` False → `IN_1`; True → `IN_2`; ramps over `BAL_TIME` (0 = instant).
- There is **no "BSEL" block** in the Function Block Reference. Selector blocks that do exist: Transfer, Signal Selector, Input Selector, Control Selector, Multiplexer (FBR contents p6–13).

**Device Control (DC)** — FBR p417–436
- Pins: `CAS_IN_D`, `SHUTDOWN_D`, `PERMISSIVE_D`, `INTERLOCK_D`, `TRK_IN_D`, `SIMULATE_IN_D` → `OUT_D`.
- Key params: `SP_D` (requested state), `FV_D` (field feedback), `PV_D` (normally = FV_D), `DC_STATE`, `FAIL`, `FAIL_ACTIVE`,
  `CFM_PASS_TIME`, `CFM_ACT1_TIME`, `CFM_ACT2_TIME`, `TRAVEL_TIMER`, `CRACK_TIME`, `TRIP_TIME`, `DEVICE_OPTS`.
- **Modes: Auto and Cas only** (actual mode goes to **LO** on track/shutdown/interlock/no-permit). FBR p427.
  - **Cas:** `SP_D` is copied from `CAS_IN_D`. **Auto:** `SP_D` stays where the operator left it (FBR p419).
- The block itself raises `FAIL_ACTIVE` when DC_STATE doesn't match the setpoint within the confirm time (FBR p422).

**Modes in general** — FBR p30–35: OOS, IMan, LO, Man, Auto, Cas, RCas, ROut. TARGET = what it's trying to reach,
ACTUAL = current mode, PERMITTED, NORMAL. IMan and LO are never selectable targets. OOS is always permitted.

## 3. Expression syntax — CONFIG p61–83

| Rule | Example |
|---|---|
| External reference (another module) | `'//LIC-549/PID1/PV.CV'` |
| Module-relative | `'/SYRUP'` |
| Block-relative (up one level) | `'^/PARAM1'` |
| Phase-relative | `'/+/WDOG_STATE.CV'` |
| Named-set constant | `'mtr2-sp:START'` (quoted `SetName:value`) — 7016 p37–39, 7017 p245 |
| Assignment / test | `:=` assigns, `=` tests |
| Not equal | `!=` or `<>` or `~=` (all valid, CONFIG p76) |
| Comments | `(* ... *)` or `REM ` |
| IF | `IF ... THEN ... ELSE ... END_IF;` (ENDIF also accepted) |
| Mode constants | `OS`, `MAN`, `AUTO`, `CAS`, `RCAS`, `LO`, `IMAN` — compare to `.ACTUAL`, assign to `.TARGET` (CONFIG p82) |
| Status constants | `GOOD` (=128…191 GoodNonCascade only!), `>= GOOD` for all Good incl. GoodCascade, `BAD` (<=63), `UNC` (64–127) (CONFIG p81) |

Note: the OOS mode constant in expressions is **`OS`**, not `OOS` (CONFIG p82).

## 4. Equipment Modules — 7009 p436–465, 7017 p229–247, 7016 p124–166

- **Seven** algorithm types: FBD, SFC, Command-Driven, State-Driven, Phase Algorithm, Phase with command-driven run logic,
  Phase with state-driven run logic.
- **Both** Command-Driven and State-Driven EMs are driven by **`A_COMMAND`** (named-set type). The named set needs a
  mandatory **255** entry (undefined/idle).
- Standard EM parameters: **`A_COMMAND`**, **`A_TARGET`** (command currently executing), **`A_PV`** (command/state
  completed without error; anything other than the 255 word), `A_ABT_ON_NEW_CMD`, `A_CMD_CHANGED`, `A_RESTART`,
  `A_RESTART_REQ` (7009 p462–464).
- **Command-Driven:** hierarchy shows `COMMAND_00001`, `COMMAND_00002`, … each an **SFC** (7009 p440). EM-TANK201 also lists
  `MONITOR` (contents not described in the docs we have). Faceplate shows State (e.g. Complete), Time, Error (7009 p469).
- **State-Driven:** configured as an **Items × States table**. Each item has a **Write parameter path** and a
  **Readback parameter path** (module-level parameters only), e.g. `PRODUCT_VLV/CAS_SP.CV` → `PRODUCT_VLV/PV.CV`;
  each state column holds the value to write (e.g. `= CLOSE`, `= Cascade/`). (7016 p140)
- Subordinate CMs dragged into an EM can be referenced as internal parameters, e.g. `'^/MTR_403/SP.CV' := 'mtr2-sp:STOP'`
  (7017 p237, p245).

**How logic commands a valve/motor CM (7016 p37–40):**
```
'//XV-101/CAS_SP.CV'       := 'vlvnc-sp:OPEN'     (* module-level CAS_SP, wired into DC1/CAS_IN_D *)
'//XV-101/MODE.TARGET'     := CAS
'//XV-101/PV.CV'            = 'vlvnc-pv:OPEN'      (* readback *)
'//MTR-505/DC1/PV_D.CV'     = 'mtr2-pv:RUNNING'
```
"When the DC1 block is in the CAS mode the block will use the module level CAS_SP parameter. Return the block to AUTO …
to return control of the module to the operator." (7016 p40)

## 5. SFC — 7009-8 p4–24, CONFIG p84–90

- Step, Transition, Termination. Initial step = double border (7009 p440).
- Qualifiers — Non-stored: **N, L, D, P**; Stored: **S, SD, DS, SL**; plus **R** (reset).
- **N assignment:** evaluated every scan while step active; destination **keeps** the value after the step ends.
- **P assignment:** evaluated on the **first scan** only.
- Action **Delay** does not hold the step. Actions in a step execute effectively in parallel.
- Confirms: `CONFIRM_FAIL`, `FAILED_CONFIRMS`, `PENDING_CONFIRMS` (transition typically `'.../PENDING_CONFIRMS.CV' = 0`).
- SFC states: IDLE, ACTIVE, STOPPED, COMPLETED, BLOCKED. Commands: Start / Stop / Reset Sequence.

## 6. Phases — 7016, FILL

- Phase logic = one SFC per composite state: `RUN_LOGIC`, `HOLD_LOGIC`, `RESTART_LOGIC`, `STOP_LOGIC`, `ABORT_LOGIC`, plus
  `FAIL_MONITOR` (7016 p70, p108–113, p202–211). Non-zero failure → phase goes to **Holding** (7016 p202).
- Batch input parameters (green) / report parameters (yellow) (FILL p6). Aliases: `'//#TANK_LEVEL#'` (7016 p36).
- The abbreviation **"EPH" does not appear** in these docs; they say phase class, unit phase, phase logic.
- **Hold / Restart / Abort are phase states**, not EM states.

## 7. Known items we could NOT verify (do not teach as fact)

- Exact On-Line watch text for MODE values (e.g. `CAS` vs `Cascade`) — the state table shows `= Cascade/` (7016 p140).
- Whether the calculator icon beside a transition means "currently evaluating" (seen only next to the active transition, PDS p5).
- Version/theme differences beyond the screenshots in these PDFs.

---

## 8. DeltaV Live (Standard HMI — v14.3+) — LIVE, GS22

- **Suite applications (GS22 p91):** **DeltaV Live Administration** (workstations, health, SQL databases), **Graphics Studio** (editor, replaces Operate Configure; runs side-by-side with DeltaV Live), **DeltaV Live** (operator runtime, replaces Operate Run). Supported on ProfessionalPLUS & Operator Stations (and Remote Client sessions) — NOT Application Stations (GS22 p98).
- **Nomenclature vs. legacy Operate (LIVE p4, GS22 pp93–97):** `GEM` (Graphical Element, class-based Linked vs. Unlinked) = Dynamo; `Contextual Displays` = Faceplates/Detail/Popups; `Library Functions` (`F_...`) = Lookup/Animation Tables; `Standards` (`S_...`) = Global Variables; `Publishing` = Download; `TypeScript` = VBA scripting (LIVE p75).
- **Data source path notation (LIVE pp16, 51, 63; GS22 p111):**
  - Static: `DLSYS["MTR-102/DC1/SP_D.CV"]`
  - Inside a GEM: `DLSYS[Gem.ModName + "/DC1/SP_D.CV"]`
  - Inside a Contextual Display / Faceplate: `DLSYS[Dsp.Tag + "/PID1/SP.CV"]`
- **High-Performance GEM Status Icons & Masking Priority (LIVE p46):**
  - **Mode:** PID `MODE.ACTUAL ≠ MODE.NORMAL` or `MODE.TARGET`; DC `MODE.TARGET` or `MODE.ACTUAL ≠ MODE.NORMAL` **or Permissive is active**.
  - **Not Running:** `MSTATUS` is `Out of Service`, `Breakpoint Set`, or `Not Running`.
  - **Bad IO:** `BLOCK_ERR` has `Out of Service`, `Readback Failed`, `Output Failure`, `Input Failure`, or `Other Error` (**hidden** when Not Running is visible).
  - **Simulate Active:** Block is simulated (**hidden** when Not Running or Bad IO is visible).
  - **No Permit:** Permissive condition is active.
  - **Interlock Bypassed:** `BYPASSED` parameter is active.
  - **Interlocked:** `DC_STATE` is `Shutdown/Interlocked`.
- **Three critical DeltaV Live operational rules:**
  1. **Quick Online View is LIVE, NOT simulated** — parameter writes hit the real controller (LIVE p22)!
  2. **Manual Refresh Rule:** Already-open displays do NOT change automatically on Publish; the operator must click **Refresh Configuration** (GS22 p127).
  3. **Backup/Restore vs. Export/Import:** SQL Backup/Restore is disaster recovery **only on the exact same DeltaV version + hotfix bundle**; moving across versions/systems MUST use **XML Export/Import** (GS22 p93).

## 9. Alarms (`ALARMS[1-5]`), Priorities & Consolidation — COURSE pp277–293, GS22 pp47–48

- **Priorities:** Up to 12 alarm levels (`4` lowest … `15` highest) + `LOG (3)` log-only. Defaults: **CRITICAL = 15**, **WARNING = 11**, **ADVISORY = 7**, **LOG = 3**. Time-stamped in the controller (COURSE pp277–278).
- **Exact 4-tier Ranking Tie-Breaker (COURSE p279):** (1) Unacknowledged > Acknowledged → (2) Active > Inactive → (3) Higher numeric priority → (4) Newer timestamp.
- **Alarm Fields (COURSE pp285–290):** `CUALM` (current alarm), `LAALM` (latched alarm, same as `CV`), `NALM` (new unack), `PRI`, `ENAB`, `INV`, `OPSUP` (suppression), `SUPTMO` / `SUPTMR` (timeout/timer). **`ALARMS[1]`** holds the highest-priority active alarm on the module; **`ALARMS.F_MACK`** (=1) acknowledges all alarms in the module (auto-resets to 0); **`ALARMS.F_ENAB`** (=0) disables all module alarms; **`ALARMS.F_PRIAD`** adjusts priority (0–12).
- **Workstation Alarm Consolidation (COURSE p291):** An alarm appears on a workstation's banner only for the **intersection** of (Plant Areas configured on the workstation's Alarms & Events subsystem) **AND** (Plant Areas where `THISUSER` has any attribute security write keys).
- **`AREA_A` System Area (GS22 pp47–48):** Default system area cannot be deleted (may be renamed); must be assigned to Alarms & Events on workstations/remote sessions so system-wide events (logins, downloads) record properly.

## 10. Download / Upload / Cold Restart & Class Traps — COURSE pp272–273, 317–319; TIPS pp4, 21–24, 40

- **Partial Download Behavior (COURSE p273):** Three module-property choices govern what happens to online `Mode` (critical block param) and `SP` (user-defined param) during a partial download:
  - *Preserve critical block values* → keeps online `Mode`, **overwrites** user-defined `SP` with config DB default!
  - *Preserve user-defined and critical block values* → keeps **both** online `Mode` and online `SP`.
  - *Use configured values* → **overwrites both** with config DB defaults!
- **Upload-Before-Download "Select None" Trap (COURSE pp318–319):** Clicking **OK** on the Download Upload prompt uploads **zero parameters by default** (`Select None`) — you must explicitly select parameters if you want online tuning/setpoint changes saved back to the config database!
- **Cold Restart NVM Persistence (COURSE p272):** To keep the current operating value across a controller **Cold Restart** (stored in NVM instead of resetting to Default), you must check **BOTH** the parameter-level *Restore parameter value after restart* **AND** the module-level *Restore parameter values after restart*.
- **Class Module Parameter Rename Trap (TIPS pp21–24):** Renaming a parameter inside a Module Class leaves the old **Parameter Shortcut** name visible in DeltaV Explorer until you open the module Configuration → **Parameters** tab at the **class level**, select the parameter, and click **`Default Name`**.
- **Dynamic Reference CPU-Killer Rule (TIPS p40):** Do **not** build more than **3 simultaneous Dynamic References** in a single action (can drop controller Free Time to ~0%); stagger in groups of 3. Also beware cross-controller dynamic references if a remote controller drops comms.
- **Control Studio Max Sessions (TIPS p4):** Default limit is **4** concurrent Control Studio sessions; changeable via registry key `MaxMdeApp`.
- **Promoted Parameters (GS22 pp60, 63):** Dragging an Output parameter from the `Special Items` palette promotes a block output to the module level (e.g., `LI-101/PV` instead of `LI-101/AI1/OUT`).

## 11. PID Internals, `DC` `STATE_MASKS` & `BFI` — PID4 pp2–3; COURSE pp300, 304; GS22 p62; TIPS pp17, 50–52

- **PID Equation & Anti-Kick (PID4 pp2–3):** Supports **Standard** and **Series** forms, external reset `L(s)` (`BKCAL_IN` or `OUT`), feedforward `F(s)`, and `Direct_Acting` in `CONTROL_OPTS` (`+` reverse / `-` direct). **`STRUCTURE`** + **`BETA`** / **`GAMMA`** weight proportional & derivative action on SP changes (eliminating SP kick). **`GAINa`** is normalized from `PV` scale to `OUT` scale. **`Use_Nonlinear_Gain_Modification`** in `FRSIPID_OPTS` applies nonlinear gain `KNL` (error-squared / notched gain) to **P + I only, NOT D** (key for pH loops!).
- **AI Scaling & Field Traps:** `L_TYPE` must remain **`Indirect`** to define Engineering Units in `OUT_SCALE` (GS22 p62). A HART transmitter can be re-ranged from DeltaV; set EU to null/`-` when using `HART_FIELD_VAL` (`OUT_SCALE` for Direct, `XD_SCALE` for Indirect — TIPS p17). Replacing a **Fisher DVC** whose input units default to `4–20 mA` instead of `%` causes **`Bad ConfigErr`** and stops valve control (TIPS pp50–52).
- **`DC` `STATE_MASKS` Decoder (COURSE p300):** Empty box = `0` on I/O channel; Check mark = `1`; Light-gray stippled check = *don't care*; Dark-gray stippled check = *not available*. (`Passive = 0`, `Active1 = 1` in named set.)
- **`BFI` (Boolean Fan Input) First-Out Trap (COURSE p304):** Standard motor/interlock templates pair `CND` blocks with **`BFI`** for first-out trip indication and an `OR` block for bypassed-interlock indication.
- **Pulse Action Confirmation (AGITATE 7016 pp9–12):** Only the **`P` (Pulse)** SFC qualifier supports the **Confirm** option (`CONFIRM_FAIL`, `FAILED_CONFIRMS`, `PENDING_CONFIRMS`).

## 12. Modern Plant I/O (`CHARMs`, `EIOC`, `VIM`) & DST Licensing — PLAN pp30–33, 61–67; VIM pp1–15; COURSE p309

- **DST Licensing Hierarchy (PLAN pp30–33, COURSE p309):** Signal-bearing I/O parameters consume one DST license per channel/dataset regardless of how many modules reference it. Cost hierarchy (highest → lowest): **`AO > AI > DO > DI`** (higher-tier DSTs substitute downward).
- **CHARMs / CIOC (PLAN pp61–64):** Electronic marshalling for S-series controllers (`SD Plus`/`SX`+). Up to **8 baseplates × 12 CHARMs = 96 CHARMs per CIOC**; default update rate **50 ms** (300 ms terminal-to-terminal at 100 ms module scan). One CHARM belongs to one controller, but one CIOC can split CHARMs across up to **4 controllers**; max 16 remote I/O nodes per controller.
- **EIOC — Ethernet I/O Card (PLAN pp65–67):** Network node for **Modbus TCP/IP**, **EtherNet/IP**, and **IEC 61850 MMS**. Runs control modules directly on the EIOC (max **26 PIDs**, **4 State Transition**, **4 Step Sequence**, **256 `DCC`**, **256 `EDC`**; does **NOT** support the standard `DC` block!).
- **VIM / VIMNet (VIM pp1–15, 22):** Virtual I/O Module interfaces S-series controllers to Modbus TCP/IP or EtherNet/IP PLCs/MCCs/scales. Each VIM simulates **4 serial cards** (slots `57–60` / `61–64`, max 128 datasets × 100 16-bit registers; floats/32-bit ints take 2 registers → max 50 values/dataset). **Addressing trap:** DeltaV serial registers are **1-based** (`R1..R100`) while PLC registers are **0-based**; **Special Data 1 (`0..3`)** controls 32-bit float byte/word swapping.
