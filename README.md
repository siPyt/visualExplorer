# DeltaV Control Studio — Visual Explorer

Interactive offline Control Studio trainer and running handbook for mastering **Emerson DeltaV Control Studio** using strictly native DeltaV terminology and plain-English mental models.

## Files in This Repository

- **`index.html` ("Visual Explorer")** — Standalone interactive **DeltaV Control Studio Visual Explorer** (open directly in Chrome or Edge, 100% offline). Switch live modules in the top-left picker:
  - **`EM_TANK_CHARGE` (Command-Driven EM):** All 4 Control Studio pattern tabs (Pattern 1 SFC + Patterns 2–4 FBD), Hold/Restart/Abort, Golden Tare Watch, EPH Handshake, and stuck-valve / bad-scale simulations.
  - **`EM_XFER_HDR` (State-Driven EM — Ch. 7):** Solvent transfer manifold header (`HEADER_CLOSED`, `ROUTE_TANK_A`, `ROUTE_TANK_B`, `CIP_FLUSH`) with live Device Alignment Mask, anti-cross-mix pump gate, overpressure `FAIL_STATE` trip, and `FAIL_ACTIVE` timeout diagnostics.
- **`WHERE_WE_ARE.txt`** — Running mastery tracker: where we came from, where we are right now, and our full Phase 1–5 Control Studio roadmap.
- **`DeltaV_Study_Guide.pdf`** — Print-ready running study handbook & master plain-English vocabulary guide (`v1.1`, Chapters 1–7).
- **`DeltaV_Study_Guide.html`** & **`build-pdf.ps1`** — Editable source and PowerShell script to regenerate `DeltaV_Study_Guide.pdf` as new chapters are added.
- **`SESSION_VOCAB.md`** — Quick-reference Markdown cheat sheet of DeltaV tiers, function blocks, operating modes, wire endings, and path syntax.

## Rebuilding the Study Guide PDF

```powershell
powershell -ExecutionPolicy Bypass -File .\build-pdf.ps1
```
