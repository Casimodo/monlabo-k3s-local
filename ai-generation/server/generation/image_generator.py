from __future__ import annotations

from abc import ABC, abstractmethod
from typing import Any


class ImageGenerator(ABC):
    @abstractmethod
    def generate(
        self,
        prompt: str,
        width: int,
        height: int,
        steps: int,
        seed: int | None = None,
    ) -> Any:
        raise NotImplementedError

    def unload(self) -> None:
        return None


class MfluxImageProvider(ImageGenerator):
    def __init__(self, quantization: int) -> None:
        from mflux.models.z_image import ZImageTurbo

        self._model = ZImageTurbo(quantize=quantization)

    def generate(
        self,
        prompt: str,
        width: int,
        height: int,
        steps: int,
        seed: int | None = None,
    ) -> Any:
        if seed is None:
            raise ValueError("seed must be resolved before generation")
        return self._model.generate_image(
            prompt=prompt,
            seed=seed,
            num_inference_steps=steps,
            width=width,
            height=height,
        )

    def unload(self) -> None:
        self._model = None
        try:
            import mlx.core as mx

            mx.clear_cache()
        except ImportError:
            pass