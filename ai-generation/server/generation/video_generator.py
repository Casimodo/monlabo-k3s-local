from __future__ import annotations

from abc import ABC, abstractmethod
from pathlib import Path
from typing import Any


class VideoGenerator(ABC):
    @abstractmethod
    def generate(
        self,
        prompt: str,
        image_path: str | None = None,
        duration: int = 5,
        seed: int | None = None,
    ) -> Any:
        raise NotImplementedError


class DisabledVideoProvider(VideoGenerator):
    reason = "Video generation is disabled until a provider is validated on this Apple Silicon machine."

    def generate(
        self,
        prompt: str,
        image_path: str | None = None,
        duration: int = 5,
        seed: int | None = None,
    ) -> Path:
        raise RuntimeError(self.reason)