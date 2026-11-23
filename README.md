# DeltaV Control Studio — Visual Explorer

Interactive offline Control Studio trainer and running handbook for mastering **Emerson DeltaV Control Studio** using strictly native DeltaV terminology and plain-English mental models.

## Files in This Repository

- **`index.html` ("Visual Explorer")** — Standalone interactive **DeltaV Control Studio Visual Explorer** (launch with `run`, or open directly in Chrome/Edge). Switch live modules in the top-left picker:
  - **`EM_TANK_CHARGE` (Command-Driven EM):** All 4 Control Studio pattern tabs (Pattern 1 SFC + Patterns 2–4 FBD), Hold/Restart/Abort, Golden Tare Watch, EPH Handshake, and stuck-valve / bad-scale simulations.
  - **`EM_XFER_HDR` (State-Driven EM — Ch. 7):** Solvent transfer manifold header (`HEADER_CLOSED`, `ROUTE_TANK_A`, `ROUTE_TANK_B`, `CIP_FLUSH`) with authentic `Items × States` table, anti-cross-mix pump gate, overpressure override, and 8s alignment timeout.
  - **`EM_2STAGE_VLV` (State-Driven 2-Stage Valve — Course 7016 / Workshop 8):** 2-stage fill valve assembly (`Close`, `Dribble`, `Bulk`, `Auto Mode`, `Idle = 255`) demonstrating zero-SFC `Items × States` tables, `(not written)` cells, 4-Pattern folding (`1 + 3 + 4` in table, Pattern 2 watchdog & tank trip on FBD), and toggleable **4-Pattern Lens**.
- **`ex.html` ("Expression Forge")** — Standalone web & mobile-ready **DeltaV Expression & Parameter Trainer** (launch with `run ex`). Features 4 interactive modes:
  1. **Decode Cold:** Tap tokens in real DeltaV paths/expressions to inspect every piece + field comprehension checks.
  2. **Forge Builder:** Build real Control Studio Structured Text expressions with thumb-friendly mobile chips or keyboard + live DeltaV `Parse` diagnostics.
  3. **Fix the Bug:** 2:00 AM plant debugger catching classic DeltaV mistakes (`=` vs `:=`, `MODE.TARGET` vs `MODE.ACTUAL`, missing `'...'` quotes, `CAS_IN_D` vs `PV_D`).
  4. **On-Line Tree:** Live Control Studio On-Line expression tree evaluator (`✓` / `✗` sub-clauses) driven by real-time plant parameter sliders.
- **`WHERE_WE_ARE.txt`** — Running mastery tracker: where we came from, where we are right now, and our full Phase 1–5 Control Studio roadmap.
- **`DeltaV_Study_Guide.pdf`** — Print-ready running study handbook & master plain-English vocabulary guide (`v2.2`, Chapters 1–7 + 8 Hands-On Workshops).
- **`DeltaV_Study_Guide.html`** & **`build-pdf.ps1`** — Editable source and PowerShell script to regenerate `DeltaV_Study_Guide.pdf` as new chapters are added.
- **`SESSION_VOCAB.md`** — Quick-reference Markdown cheat sheet of DeltaV tiers, function blocks, operating modes, wire endings, and path syntax.

## Rebuilding the Study Guide PDF

```powershell
powershell -ExecutionPolicy Bypass -File .\build-pdf.ps1
```
