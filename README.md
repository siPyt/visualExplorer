# DeltaV Control Studio Visual Explorer (`EM_TANK_CHARGE`)

Interactive offline study app and running handbook for learning **Emerson DeltaV Control Studio** using strictly native DeltaV terminology and plain-English mental models.

## Files in This Repository

- **`index.html`** — Standalone interactive **DeltaV Control Studio Visual Explorer** for `EM_TANK_CHARGE` (`CM_FEED_XV`, `CM_TANK_WT`, `CM_AGIT_MTR`). Open directly in Chrome or Edge (100% offline). Includes:
  - All 4 Control Studio pattern tabs (Pattern 1 SFC + Patterns 2–4 FBD)
  - **Off-Line / On-Line** monitoring toggle
  - Interactive **Hold / Restart / Abort**, **Golden Tare Watch**, **EPH Handshake**, and field fault toggles
  - Built-in searchable **Session Vocab** overlay
- **`DeltaV_Study_Guide.pdf`** — Print-ready running study handbook & master plain-English vocabulary guide (with vector Control Studio diagrams and a self-check quiz).
- **`DeltaV_Study_Guide.html`** & **`build-pdf.ps1`** — Editable source and PowerShell script to regenerate `DeltaV_Study_Guide.pdf` as new chapters are added.
- **`SESSION_VOCAB.md`** — Quick-reference Markdown cheat sheet of DeltaV tiers, function blocks, operating modes, wire endings, and path syntax.

## Rebuilding the Study Guide PDF

```powershell
powershell -ExecutionPolicy Bypass -File .\build-pdf.ps1
```
