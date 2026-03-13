# Ollama — Intel GPU Edition

Run large language models **locally** on your Intel GPU (Arc, Iris Xe, integrated graphics).

## Features

- **Intel GPU acceleration** via Intel oneAPI OpenCL/SYCL runtime
- **Minimal image** — no model bundled, download only what you need
- **OpenAI-compatible API** — works with Open WebUI, Enchanted, and other frontends
- **Persistent model storage** — models survive container restarts and updates

## Getting Started

1. Install the app from the Runtipi store
2. (Optional) Enter a model name in the **"Model to auto-pull"** field to download it on first start
3. If you skipped step 2, pull a model later via the **API** or the model pull helper

### Pull a model via API

```bash
curl http://<your-server>:11434/api/pull \
  -d '{"name": "llama3.2:1b"}'
```

### Pull via docker exec

```bash
docker exec -it ollama-intel ollama pull llama3.2:1b
```

### Chat via API

```bash
curl http://<your-server>:11434/api/generate \
  -d '{"model": "llama3.2:1b", "prompt": "Hello!", "stream": false}'
```

## Recommended Models (smallest first)

| Model | Size | Best For |
|---|---|---|
| `llama3.2:1b` | ~770 MB | Quick tasks, low VRAM |
| `phi3:mini` | ~2.3 GB | Balanced performance |
| `llama3.2:3b` | ~2.0 GB | General purpose |
| `mistral` | ~4.1 GB | High quality responses |
| `codellama:7b` | ~3.8 GB | Code generation |

## Intel GPU Notes

- Requires `/dev/dri` device nodes on the host (standard on any Linux system with Intel graphics)
- The container is added to the `video` and `render` groups automatically
- Performance depends on your Intel GPU generation — Arc GPUs perform best
- Integrated graphics will work but may be slower than discrete GPUs

## Pairing with Open WebUI

Install **Open WebUI** from the Runtipi store and point it at:
```
http://ollama-intel:11434
```
(use the internal service name when both apps run on the same Runtipi instance)
