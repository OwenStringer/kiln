$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root
New-Item -ItemType Directory -Force -Path "$root\bin", "$root\models" | Out-Null

$exe = Get-ChildItem -Path "$root\bin" -Filter "llama-server.exe" -Recurse -ErrorAction SilentlyContinue |
  Select-Object -First 1
if (-not $exe) { throw "Run .\start-work.ps1 once first so llama.cpp is downloaded. Stop that server before starting this one." }

$model = "$root\models\Qwen2.5-Coder-7B-Instruct-Q8_0.gguf"
if (-not (Test-Path $model)) {
  Write-Host "Downloading the 7B model."
  $url = "https://huggingface.co/bartowski/Qwen2.5-Coder-7B-Instruct-GGUF/resolve/main/Qwen2.5-Coder-7B-Instruct-Q8_0.gguf"
  curl.exe -L --fail -o $model $url
}

Write-Host "Fast model on the 4090. Do not run this while the work model is still up."
& $exe.FullName `
  -m $model `
  --host 127.0.0.1 --port 8088 `
  -ngl 99 --fit off `
  -fa on `
  -c 32768 `
  -ctk f16 -ctv f16 `
  -t 8 -tb 16 -np 1 `
  -b 2048 -ub 512 `
  --jinja `
  --temp 0.3 --top-p 0.9
