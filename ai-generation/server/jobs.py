from __future__ import annotations

import queue
import secrets
import threading
import time
import uuid
from dataclasses import asdict, dataclass
from datetime import UTC, datetime
from typing import Any

from .config import Settings
from .generation.image_generator import ImageGenerator, MfluxImageProvider
from .model_manager import ModelManager
from .storage import GenerationStorage


@dataclass(frozen=True)
class ImageRequest:
    prompt: str
    width: int
    height: int
    steps: int
    seed: int | None
    model: str


@dataclass
class Job:
    id: str
    type: str
    status: str = "queued"
    error: str | None = None
    result_id: str | None = None


class GenerationService:
    def __init__(
        self,
        settings: Settings,
        storage: GenerationStorage,
        provider_factory: Any | None = None,
    ) -> None:
        self.settings = settings
        self.storage = storage
        self._provider_factory = provider_factory or (
            lambda: MfluxImageProvider(settings.image_quantization)
        )
        self._manager = ModelManager(settings.keep_model_loaded)
        self._jobs: dict[str, Job] = {}
        self._jobs_lock = threading.Lock()
        self._queue: queue.Queue[tuple[str, ImageRequest] | None] = queue.Queue()
        self._workers = [
            threading.Thread(target=self._worker, name=f"generation-worker-{index}", daemon=True)
            for index in range(settings.max_concurrent_jobs)
        ]
        for worker in self._workers:
            worker.start()

    def submit_image(self, request: ImageRequest) -> Job:
        job = Job(id=uuid.uuid4().hex, type="image")
        with self._jobs_lock:
            self._jobs[job.id] = job
        self._queue.put((job.id, request))
        return job

    def get_job(self, job_id: str) -> Job | None:
        with self._jobs_lock:
            job = self._jobs.get(job_id)
            return Job(**asdict(job)) if job else None

    def close(self) -> None:
        for _ in self._workers:
            self._queue.put(None)
        for worker in self._workers:
            worker.join(timeout=5)
        self._manager.close()

    def _worker(self) -> None:
        while True:
            item = self._queue.get()
            try:
                if item is None:
                    return
                job_id, request = item
                self._run_image(job_id, request)
            finally:
                self._queue.task_done()

    def _run_image(self, job_id: str, request: ImageRequest) -> None:
        self._update_job(job_id, status="running")
        started = time.monotonic()
        seed = request.seed if request.seed is not None else secrets.randbelow(2**32)
        try:
            image = self._manager.generate(
                request.model,
                self._provider_factory,
                prompt=request.prompt,
                width=request.width,
                height=request.height,
                steps=request.steps,
                seed=seed,
            )
            elapsed = round(time.monotonic() - started, 3)
            metadata = {
                "id": job_id,
                "type": "image",
                "status": "completed",
                "prompt": request.prompt,
                "model": request.model,
                "seed": seed,
                "width": request.width,
                "height": request.height,
                "steps": request.steps,
                "generationTime": elapsed,
                "createdAt": datetime.now(UTC).isoformat(),
                "url": f"/outputs/images/{job_id}.png",
            }
            self.storage.save_image(job_id, image, metadata)
            self._update_job(job_id, status="completed", result_id=job_id)
        except Exception as exc:
            self._update_job(job_id, status="failed", error=str(exc))

    def _update_job(self, job_id: str, **values: str | None) -> None:
        with self._jobs_lock:
            job = self._jobs[job_id]
            for key, value in values.items():
                setattr(job, key, value)