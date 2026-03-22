# Ollama — Intel GPU Edition

Run large language models **locally** on your Intel GPU (Arc, Iris Xe, integrated graphics).

## Features

- **Intel GPU acceleration** via Intel oneAPI OpenCL/SYCL runtime
- **Minimal image** — no model bundled in the image, downloaded on first start
- **Mistral auto-pulled by default** — well-rounded general model (~4.1 GB)
- **OpenAI-compatible API** — works with Open WebUI, Enchanted, and other frontends
- **Persistent model storage** — models survive container restarts and updates

## Getting Started

1. Install the app from the Runtipi store
2. **Mistral is pulled automatically** on first start (change or clear the field to use a different model)
3. Once ready, chat via the API or pair with Open WebUI

### Pull a different model via API

```bash
curl http://<your-server>:11434/api/pull \
  -d '{"name": "llama3.2:1b"}'
```

### Pull via docker exec

```bash
docker exec -it ollama ollama pull llama3.2:1b
```

### Chat via API

```bash
curl http://<your-server>:11434/api/generate \
  -d '{"model": "mistral", "prompt": "Hello!", "stream": false}'
```

## Recommended Models (smallest first)

| Model | Size | Best For |
|---|---|---|
| `llama3.2:1b` | ~770 MB | Quick tasks, low VRAM |
| `llama3.2:3b` | ~2.0 GB | General purpose |
| `phi3:mini` | ~2.3 GB | Balanced performance |
| `mistral` | **~4.1 GB** | **Default — well-rounded general model** |
| `codellama:7b` | ~3.8 GB | Code generation |
| `llama3.1:8b` | ~4.7 GB | High quality |

## Intel GPU Notes

- Requires `/dev/dri` device nodes on the host (standard on any Linux system with Intel graphics)
- The container is added to the `video` and `render` groups automatically
- Performance depends on your Intel GPU generation — Arc GPUs perform best
- Integrated graphics will work but may be slower than discrete GPUs

## Pairing with Open WebUI

Install **Open WebUI** from the Runtipi store and point it at:
```
http://ollama:11434
```
(use the internal service name when both apps run on the same Runtipi instance)
