# Regenerates DeltaV_Study_Guide.pdf from DeltaV_Study_Guide.html using headless Chrome/Edge
$ErrorActionPreference = "Stop"

$dir = Split-Path -Parent $MyInvocation.MyCommand.Path
$htmlPath = Join-Path $dir "DeltaV_Study_Guide.html"
$pdfPath  = Join-Path $dir "DeltaV_Study_Guide.pdf"

$browser = @(
  "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
  "$env:ProgramFiles (x86)\Google\Chrome\Application\chrome.exe",
  "$env:ProgramFiles (x86)\Microsoft\Edge\Application\msedge.exe",
  "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $browser) {
  throw "Neither Chrome nor Edge was found to render the PDF."
}

$fileUri = ([System.Uri]$htmlPath).AbsoluteUri
$tmpProfile = Join-Path $env:TEMP "deltav-pdf-profile"
if (Test-Path $pdfPath) { Remove-Item $pdfPath -Force }

$argsList = @(
  "--headless=new",
  "--disable-gpu",
  "--no-first-run",
  "--no-default-browser-check",
  "--user-data-dir=`"$tmpProfile`"",
  "--no-pdf-header-footer",
  "--print-to-pdf=`"$pdfPath`"",
  "`"$fileUri`""
)

$proc = Start-Process -FilePath $browser -ArgumentList $argsList -Wait -PassThru -NoNewWindow
Remove-Item $tmpProfile -Recurse -Force -ErrorAction SilentlyContinue

if (Test-Path $pdfPath) {
  $info = Get-Item $pdfPath
  Write-Output "Generated: $($info.FullName) ($($info.Length) bytes, exit=$($proc.ExitCode))"
} else {
  throw "PDF generation did not produce $pdfPath (exit=$($proc.ExitCode))"
}
