from __future__ import annotations

import gc
import threading
from collections.abc import Callable

from .generation.image_generator import ImageGenerator


class ModelManager:
    def __init__(self, keep_loaded: bool) -> None:
        self._keep_loaded = keep_loaded
        self._model_name: str | None = None
        self._provider: ImageGenerator | None = None
        self._lock = threading.Lock()

    def generate(
        self,
        model_name: str,
        provider_factory: Callable[[], ImageGenerator],
        **parameters: object,
    ) -> object:
        with self._lock:
            if self._provider is None or self._model_name != model_name:
                self._unload()
                self._provider = provider_factory()
                self._model_name = model_name
            try:
                return self._provider.generate(**parameters)
            finally:
                if not self._keep_loaded:
                    self._unload()

    def close(self) -> None:
        with self._lock:
            self._unload()

    def _unload(self) -> None:
        if self._provider is not None:
            self._provider.unload()
        self._provider = None
        self._model_name = None
        gc.collect()