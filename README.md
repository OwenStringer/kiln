# Kiln

Local coding model server for this PC: RTX 4090, 128 GB DDR5, i9-14900K.

The desk in the browser is the control panel. This repo is the part that runs on the GPU.

## Load it

You are already in `C:\Users\Adrian\Desktop\RTX4090`. Typing `git` by itself does nothing. Paste this:

```powershell
git clone https://github.com/OwenStringer/kiln.git .
Set-ExecutionPolicy -Scope Process Bypass
.\start-work.ps1
```

The first run downloads llama.cpp and a 19 GB model. Leave the window open. The server listens on port 8088.

Run one model at a time. The 7B and the 30B do not fit on the 4090 together.

## Profiles

| Script | Model | Where it lives |
| --- | --- | --- |
| `start-work.ps1` | Qwen3-Coder 30B-A3B Q4_K_M, 64k context | Entirely on the 4090. Use this every day. |
| `start-fast.ps1` | Qwen2.5-Coder 7B Q8 | Entirely on the GPU. Short edits only. |
| `start-deep.ps1` | Your 80B Q4 GGUF, if you put the file in `models\` | Experts in DDR5, attention on the 4090. |

Threads stay at 8 for generation and 16 for the prompt. That is the 8 P-cores. Do not raise it to 32. The E-cores make this slower.

## Point a coding CLI at it

llama-server speaks chat completions, not the Anthropic Messages API. A Claude-style CLI needs a local translator in front of port 8088. Until that gateway is running, talk to the server directly at `http://127.0.0.1:8088`.

If `start-work.ps1` fails on a missing CUDA DLL, install the current NVIDIA driver for the 4090 and run it again. The script uses the CUDA 12.4 Windows build, which a current 4090 driver can run.
