# Ollama — Intel GPU Docker

Run [Ollama](https://ollama.com) in Docker with Intel GPU acceleration.
Supports **Intel Arc**, **Iris Xe**, and **integrated Intel graphics** via Intel's oneAPI runtime.

> **Minimal by design** — the Docker image contains no LLM models.
> Models are downloaded on-demand so you only store what you use.

---

## Quick Install (CLI)

```bash
curl -fsSL https://raw.githubusercontent.com/Crashcart/Olama-intelgpu/main/scripts/install.sh | bash
```

Or with options:

```bash
bash install.sh --port 11434 --data-dir /opt/ollama --version latest
```

### Then pull a model

```bash
bash scripts/pull-model.sh           # interactive menu
bash scripts/pull-model.sh llama3.2  # specific model
```

---

## Manual Docker Compose

```bash
git clone https://github.com/Crashcart/Olama-intelgpu.git
cd Olama-intelgpu/docker
docker compose up -d
```

Then pull a model:

```bash
docker exec -it ollama-intel ollama pull llama3.2:1b
```

---

## Runtipi App Store

To add this app to a self-hosted [Runtipi](https://runtipi.io) instance:

### Option A — Add as a custom app store

1. In Runtipi settings → **App Stores**, add:
   ```
   https://github.com/Crashcart/Olama-intelgpu
   ```
2. The **Ollama (Intel GPU)** app will appear in your store.
3. Install it — optionally set a model to auto-download on first start.

### Option B — Copy files manually

Copy `runtipi/apps/ollama-intel/` into your Runtipi `apps/` directory and refresh the store.

---

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `OLLAMA_PORT` | `11434` | Host port |
| `OLLAMA_VERSION` | `latest` | Ollama image tag |
| `OLLAMA_DATA_DIR` | `/opt/ollama` | Host model storage path |
| `OLLAMA_PULL_MODEL` | *(empty)* | Model to pull on first start |

---

## Model Size Reference

| Model | Download Size | Notes |
|---|---|---|
| `llama3.2:1b` | ~770 MB | Fastest |
| `gemma2:2b` | ~1.6 GB | Google |
| `phi3:mini` | ~2.3 GB | Microsoft |
| `llama3.2:3b` | ~2.0 GB | Meta |
| `mistral` | ~4.1 GB | Strong general |
| `codellama:7b` | ~3.8 GB | Code |
| `llama3.1:8b` | ~4.7 GB | High quality |

---

## Directory Structure

```
Olama-intelgpu/
├── docker/
│   ├── Dockerfile           # Minimal Ollama image with Intel GPU drivers
│   └── docker-compose.yml   # Standalone compose for CLI use
├── scripts/
│   ├── install.sh           # One-command installer
│   └── pull-model.sh        # Deferred model downloader
└── runtipi/
    └── apps/
        └── ollama-intel/
            ├── config.json          # Runtipi app metadata & form fields
            ├── docker-compose.yml   # Runtipi-compatible compose
            └── metadata/
                └── description.md  # App store description
```

---

## Intel GPU Verification

After pulling a model and running inference, check GPU usage:

```bash
# Check Intel GPU utilization
sudo intel_gpu_top

# Verify OpenCL device is detected inside the container
docker exec ollama-intel clinfo | grep -i "device name"
```
