$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root
New-Item -ItemType Directory -Force -Path "$root\bin", "$root\models" | Out-Null

function Get-LlamaServer {
  $found = Get-ChildItem -Path "$root\bin" -Filter "llama-server.exe" -Recurse -ErrorAction SilentlyContinue |
    Select-Object -First 1
  if ($found) { return $found.FullName }
  $zip = "$root\bin\llama-cuda.zip"
  $url = "https://github.com/ggml-org/llama.cpp/releases/download/b11146/llama-b11146-bin-win-cuda-12.4-x64.zip"
  Write-Host "Downloading llama.cpp CUDA build..."
  curl.exe -L --fail -o $zip $url
  Expand-Archive -Path $zip -DestinationPath "$root\bin" -Force
  $found = Get-ChildItem -Path "$root\bin" -Filter "llama-server.exe" -Recurse | Select-Object -First 1
  if (-not $found) { throw "llama-server.exe was not in the zip." }
  return $found.FullName
}

$model = "$root\models\Qwen3-Coder-30B-A3B-Instruct-Q4_K_M.gguf"
if (-not (Test-Path $model)) {
  Write-Host "Downloading the daily model (about 19 GB). Leave this window open."
  $url = "https://huggingface.co/unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF/resolve/main/Qwen3-Coder-30B-A3B-Instruct-Q4_K_M.gguf"
  curl.exe -L --fail -o $model $url
}

$exe = Get-LlamaServer
Write-Host "Work model on the 4090. Close this window to stop it."
& $exe `
  -m $model `
  --host 127.0.0.1 --port 8088 `
  -ngl 99 --fit off `
  -fa on `
  -c 65536 `
  -ctk q4_0 -ctv q4_0 `
  -t 8 -tb 16 -np 1 `
  -b 2048 -ub 512 `
  --jinja `
  --temp 0.3 --top-p 0.9
