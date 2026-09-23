from __future__ import annotations

import json
import re
from pathlib import Path
from typing import Any


GENERATION_ID = re.compile(r"^[0-9a-f]{32}$")


class GenerationStorage:
    def __init__(self, root: Path) -> None:
        self.root = root.resolve()
        self.images = self.root / "images"
        self.videos = self.root / "videos"
        self.images.mkdir(parents=True, exist_ok=True)
        self.videos.mkdir(parents=True, exist_ok=True)

    def save_image(self, generation_id: str, image: Any, metadata: dict[str, Any]) -> dict[str, Any]:
        directory = self._type_directory("image")
        self._validate_id(generation_id)
        image_path = directory / f"{generation_id}.png"
        metadata_path = directory / f"{generation_id}.json"
        image.save(image_path)
        metadata_path.write_text(json.dumps(metadata, indent=2, ensure_ascii=True), encoding="utf-8")
        return metadata

    def list(self, generation_type: str) -> list[dict[str, Any]]:
        directory = self._type_directory(generation_type)
        items: list[dict[str, Any]] = []
        for metadata_path in directory.glob("*.json"):
            try:
                value = json.loads(metadata_path.read_text(encoding="utf-8"))
                if isinstance(value, dict):
                    items.append(value)
            except (json.JSONDecodeError, OSError):
                continue
        return sorted(items, key=lambda item: str(item.get("createdAt", "")), reverse=True)

    def get(self, generation_type: str, generation_id: str) -> dict[str, Any] | None:
        self._validate_id(generation_id)
        path = self._type_directory(generation_type) / f"{generation_id}.json"
        if not path.is_file():
            return None
        value = json.loads(path.read_text(encoding="utf-8"))
        return value if isinstance(value, dict) else None

    def _type_directory(self, generation_type: str) -> Path:
        if generation_type == "image":
            return self.images
        if generation_type == "video":
            return self.videos
        raise ValueError("unsupported generation type")

    @staticmethod
    def _validate_id(generation_id: str) -> None:
        if not GENERATION_ID.fullmatch(generation_id):
            raise ValueError("invalid generation id")