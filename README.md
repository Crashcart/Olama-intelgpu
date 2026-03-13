# Olama — Intel GPU Docker

Run [Ollama](https://ollama.com) in Docker with Intel GPU acceleration.
Supports **Intel Arc**, **Iris Xe**, and **integrated Intel graphics** via Intel's oneAPI runtime.

> **Minimal by design** — the Docker image contains no LLM models.
> **Mistral** is pulled as the default model on first start (well-rounded, ~4.1 GB).
> Download only what you use.

---

## Quick Install (CLI)

```bash
curl -fsSL https://raw.githubusercontent.com/Crashcart/Olama-intelgpu/main/scripts/install.sh | bash
```

Or with options:

```bash
bash install.sh --port 11434 --data-dir /opt/olama --version latest
```

### Then pull a model (mistral is the default)

```bash
bash scripts/pull-model.sh           # interactive menu, Enter for mistral
bash scripts/pull-model.sh mistral   # pull directly
```

---

## Manual Docker Compose

```bash
git clone https://github.com/Crashcart/Olama-intelgpu.git
cd Olama-intelgpu/docker
docker compose up -d
```

Then pull the default model:

```bash
docker exec -it olama ollama pull mistral
```

---

## Runtipi App Store

To add Olama to a self-hosted [Runtipi](https://runtipi.io) instance:

### Option A — Add as a custom app store

1. In Runtipi settings → **App Stores**, add:
   ```
   https://github.com/Crashcart/Olama-intelgpu
   ```
2. **Olama (Intel GPU)** will appear in your store.
3. Install it — `mistral` is pulled automatically on first start.

### Option B — Copy files manually

Copy `runtipi/apps/olama/` into your Runtipi `apps/` directory and refresh the store.

---

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `OLLAMA_PORT` | `11434` | Host port |
| `OLLAMA_VERSION` | `latest` | Ollama image tag |
| `OLLAMA_DATA_DIR` | `/opt/olama` | Host model storage path |
| `OLLAMA_PULL_MODEL` | `mistral` | Model pulled on first start |

---

## Model Size Reference

| Model | Download Size | Notes |
|---|---|---|
| `llama3.2:1b` | ~770 MB | Fastest |
| `gemma2:2b` | ~1.6 GB | Google |
| `llama3.2:3b` | ~2.0 GB | Meta |
| `phi3:mini` | ~2.3 GB | Microsoft |
| `codellama:7b` | ~3.8 GB | Code |
| `mistral` | **~4.1 GB** | **Default — well-rounded general model** |
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
│   └── pull-model.sh        # Deferred model downloader (default: mistral)
└── runtipi/
    └── apps/
        └── olama/
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
docker exec olama clinfo | grep -i "device name"
```
