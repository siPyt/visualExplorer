# DeltaV Control Studio — Verified Facts (from `pdf reference/`)

Every line below was read directly in the Emerson PDFs in `pdf reference/`. Page numbers are **PDF page numbers**.
Doc keys: **FBR** = Function Block Reference · **CONFIG** = DeltaV Configuration · **7009** = Implementation I (v15.LTS) ·
**7009-8** = 7009 SFC chapter · **7017** = Implementation II · **7016** = Batch · **PDS** = Control Studio On-line data sheet.

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

- What the `MONITOR` item in a command-driven EM contains.
- Exact On-Line watch text for MODE values (e.g. `CAS` vs `Cascade`) — the state table shows `= Cascade/` (7016 p140).
- Whether the calculator icon beside a transition means "currently evaluating" (seen only next to the active transition, PDS p5).
- Version/theme differences beyond the screenshots in these PDFs.
