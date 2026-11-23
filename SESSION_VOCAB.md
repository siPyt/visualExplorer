# DeltaV Control Studio Vocabulary & Verified Rules — `EM_TANK_CHARGE` & `EM_XFER_HDR`

Strictly native Emerson DeltaV Control Studio vocabulary, architecture rules, and verified behaviors (cross-checked against `DELTAV_VERIFIED_FACTS.md` and `pdf reference/`).

---

## 1. The Three Equipment Levels (Who Talks to Whom)

| Term | Full Name & Source | Plain-English Job |
| :--- | :--- | :--- |
| **Unit Phase ("EPH")** | Phase Class / Unit Phase (*7016* p. 70) | **The Recipe Boss.** ISA-88 calls this an `EPH`; DeltaV Explorer calls it a Phase Class / Unit Phase containing `RUN_LOGIC`, `HOLD_LOGIC`, `RESTART_LOGIC`, `STOP_LOGIC`, `ABORT_LOGIC`, and `FAIL_MONITOR`. |
| **EM** | Equipment Module (*7009* p. 436) | **The Team Coordinator** (`EM_TANK_CHARGE`, `EM_XFER_HDR`). Coordinates multiple CMs via `A_COMMAND` (`255 = Idle`), `A_TARGET`, and `A_PV`. DeltaV offers 7 EM algorithm types. |
| **CM** | Control Module (*7016* pp. 37–40) | **Single-Device Controller** (`CM_FEED_XV`, `CM_TANK_WT`, `CM_AGIT_MTR`). Standard discrete CM wiring connects module `CAS_SP` → `DC1/CAS_IN_D` and `DC1/PV_D` → `PV`. |
| **Scan & `#1..#N`** | Module Scan Cycle (*PDS* p. 3) | **One Heartbeat** (e.g., 500 ms or 1 s). Reads inputs, solves FBD blocks strictly in bottom-right `#1 → #2 → #3` order, and updates outputs. |

---

## 2. Core Function Blocks & Pin Reality

| Block | Full Name & Source | Verified Pins & Controller Behavior |
| :--- | :--- | :--- |
| **SFC** | Sequential Function Chart (*7009-8*) | Double-bordered Initial Step (`S0_IDLE`), Steps (green border + elapsed seconds under **every** step On-Line), Transitions (`┼`), and Termination (`═╧═`). `[P]` = first scan only; `[N]` = every active scan and **retains written `:=` value after step ends**. |
| **CND** | Condition Block (*FBR* pp. 413–416) | **`OUT_D` output pin ONLY (zero input pins — `:=` is illegal!).** Reads operands inside its expression; sets `OUT_D = True` after staying True for `TIME_DURATION` seconds. |
| **ACT** | Action Block (*FBR* pp. 400–402) | **`IN_D` input pin ONLY (zero output pins!).** Evaluates its `:=` assignment expression **every scan while `IN_D = True`**; target retains last value when `IN_D` goes False. |
| **CALC** | Calculation/Logic Block (*FBR* p. 179, *CONFIG* p. 81) | Pins `IN1..IN16` and `OUT1..OUT16` (no underscore). **Status gotcha:** `OUT` status defaults to `GOOD (128)` unless you write `'OUT1.ST' := 'IN2.ST'`! |
| **XFR** | Transfer Block (*FBR* pp. 453–455) | Real DeltaV 2-input switch (there is **no `"BSEL"` block** in DeltaV!): `SELECTOR = False` selects `IN_1`; `SELECTOR = True` selects `IN_2` (ramps over `BAL_TIME`). |
| **DC** | Device Control Block (*FBR* pp. 417–436) | Discrete valve/motor block. **Supports ONLY `AUTO` and `CAS` target modes (no `MAN` mode!).** `CAS` copies `CAS_IN_D`; `AUTO` gives operator faceplate control; interlocks force `LO`. Built-in `CFM_ACT1_TIME` / `CFM_PASS_TIME` set `FAIL_ACTIVE`. |
| **AI** | Analog Input Block | Sensor reader inside `CM_TANK_WT` / `CM_HDR_PT` outputting engineering units (`OUT.CV`) plus signal quality (`OUT.ST`). |

---

## 3. Operating Modes, Status & Expression Rules

- **Mode Constants in Expressions (*CONFIG* p. 82):** `OS` (**not** `OOS`!), `MAN` (on `PID`/`AO`/`DO`), `AUTO`, `CAS`, `RCAS`, `LO`, `IMAN`. Always write to `MODE.TARGET` and test `MODE.ACTUAL`.
- **Status Constants (*CONFIG* p. 81):** `BAD (<= 63)` shows Red `✕`, `UNC (64..127)` shows Blue `?`, `GOOD (128..191)` = `GoodNonCascade` only, `192..255` = `GoodCascade`. Always test **`>= GOOD`** so `GoodCascade` is included!
- **Named-Set Constants (*7016* pp. 37–39):** Single-quoted `'SetName:Value'`, e.g., `'//CM_FEED_XV/CAS_SP.CV' := 'vlvnc-sp:OPEN'` and `'//CM_FEED_XV/PV.CV' = 'vlvnc-pv:CLOSED'`.
- **On-Line Wire Rules (*CONFIG* p. 368):** **Bold wire** = non-zero value; **Dashed wire** = **feedback wire** (source `#N` > destination `#N`, arrives next scan). Solid vs. dashed does **not** mean analog vs. discrete!

---

## 4. Command-Driven vs. State-Driven Equipment Modules

- **Command-Driven (`EM_TANK_CHARGE` — *7009* p. 440):** Hierarchy contains `COMMAND_00001`, `COMMAND_00002`, … (each an SFC). Driven by `A_COMMAND` (`255 = Idle`); SFC Termination sets `A_PV` to the command name.
- **State-Driven (`EM_XFER_HDR` — *7016* p. 140):** Configured in Control Studio as an **`Items × States` table** (no SFCs!). Each item maps a module-level **Write parameter path** and **Readback parameter path**; also driven by `A_COMMAND` (`255 = Idle`), and `A_PV` stays `Idle` until every row's Readback matches its target cell.
