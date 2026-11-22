param([string]$Target = "")
switch ($Target.ToLower()) {
  "ex"    { Start-Process (Join-Path $PSScriptRoot "ex.html") }
  "guide" { Start-Process (Join-Path $PSScriptRoot "DeltaV_Study_Guide.html") }
  "pdf"   { Start-Process (Join-Path $PSScriptRoot "DeltaV_Study_Guide.pdf") }
  default { Start-Process (Join-Path $PSScriptRoot "index.html") }
}
