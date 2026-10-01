$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

$exe = Get-ChildItem -Path "$root\bin" -Filter "llama-server.exe" -Recurse -ErrorAction SilentlyContinue |
  Select-Object -First 1
if (-not $exe) { throw "Run .\start-work.ps1 once first so llama.cpp is downloaded." }

$model = Get-ChildItem -Path "$root\models" -Filter "*Coder-Next*Q4*.gguf" -ErrorAction SilentlyContinue |
  Select-Object -First 1
if (-not $model) {
  throw "Put the Q4_K_M GGUF of Qwen3-Coder-Next in the models folder, then run this again. Stop the work server first."
}

Write-Host "Deep model. Experts stay in system RAM. Attention stays on the 4090."
& $exe.FullName `
  -m $model.FullName `
  --host 127.0.0.1 --port 8088 `
  -ngl 99 --fit off `
  -fa on `
  -c 65536 `
  -ctk q4_0 -ctv q4_0 `
  -t 8 -tb 16 -np 1 `
  -b 4096 -ub 512 `
  --n-cpu-moe 64 `
  --jinja `
  --temp 0.3 --top-p 0.9
