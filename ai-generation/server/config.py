from __future__ import annotations

import json
from dataclasses import dataclass
from pathlib import Path
from typing import Any


MODULE_DIR = Path(__file__).resolve().parents[1]
DEFAULT_CONFIG_PATH = MODULE_DIR / ".env-temp.json"
LOCAL_CONFIG_PATH = MODULE_DIR / ".env.json"


@dataclass(frozen=True)
class Settings:
    host: str = "127.0.0.1"
    port: int = 8180
    image_model: str = "Tongyi-MAI/Z-Image-Turbo"
    image_quantization: int = 8
    max_concurrent_jobs: int = 1
    outputs_directory: Path = MODULE_DIR / "outputs"
    keep_model_loaded: bool = True


def _read_json(path: Path) -> dict[str, Any]:
    if not path.exists():
        return {}
    with path.open(encoding="utf-8") as config_file:
        value = json.load(config_file)
    if not isinstance(value, dict):
        raise ValueError(f"Configuration must be a JSON object: {path}")
    return value


def load_settings(config_path: Path | None = None) -> Settings:
    path = config_path or (LOCAL_CONFIG_PATH if LOCAL_CONFIG_PATH.exists() else DEFAULT_CONFIG_PATH)
    values = _read_json(path)
    host = str(values.get("host", "127.0.0.1"))
    if host not in {"127.0.0.1", "localhost"}:
        raise ValueError("host must be 127.0.0.1 or localhost")

    port = int(values.get("port", 8180))
    if not 1 <= port <= 65535:
        raise ValueError("port must be between 1 and 65535")

    quantization = int(values.get("imageQuantization", 8))
    if quantization not in {4, 8}:
        raise ValueError("imageQuantization must be 4 or 8")

    max_jobs = int(values.get("maxConcurrentJobs", 1))
    if not 1 <= max_jobs <= 4:
        raise ValueError("maxConcurrentJobs must be between 1 and 4")

    outputs_value = Path(str(values.get("outputsDirectory", "./outputs"))).expanduser()
    outputs_directory = outputs_value if outputs_value.is_absolute() else (MODULE_DIR / outputs_value).resolve()

    return Settings(
        host=host,
        port=port,
        image_model=str(values.get("imageModel", "Tongyi-MAI/Z-Image-Turbo")),
        image_quantization=quantization,
        max_concurrent_jobs=max_jobs,
        outputs_directory=outputs_directory,
        keep_model_loaded=bool(values.get("keepModelLoaded", True)),
    )