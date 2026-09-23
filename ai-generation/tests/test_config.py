import json
from pathlib import Path

import pytest

from server.config import load_settings


def write_config(path: Path, **overrides: object) -> Path:
    values = {"host": "127.0.0.1", "port": 8180, **overrides}
    path.write_text(json.dumps(values), encoding="utf-8")
    return path


def test_load_settings_accepts_loopback(tmp_path: Path) -> None:
    settings = load_settings(write_config(tmp_path / "config.json"))
    assert settings.host == "127.0.0.1"
    assert settings.port == 8180


def test_load_settings_rejects_network_binding(tmp_path: Path) -> None:
    with pytest.raises(ValueError, match="host"):
        load_settings(write_config(tmp_path / "config.json", host="0.0.0.0"))


def test_load_settings_rejects_invalid_port(tmp_path: Path) -> None:
    with pytest.raises(ValueError, match="port"):
        load_settings(write_config(tmp_path / "config.json", port=70000))