@echo off
if /I "%~1"=="ex" (
  start "" "%~dp0ex.html"
) else if /I "%~1"=="guide" (
  start "" "%~dp0DeltaV_Study_Guide.html"
) else if /I "%~1"=="pdf" (
  start "" "%~dp0DeltaV_Study_Guide.pdf"
) else (
  start "" "%~dp0index.html"
)
