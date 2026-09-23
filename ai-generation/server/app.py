from __future__ import annotations

from collections.abc import Callable
from contextlib import asynccontextmanager
from pathlib import Path
from typing import Any

from fastapi import FastAPI, HTTPException, status
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel, Field, field_validator

from .config import MODULE_DIR, Settings, load_settings
from .generation.image_generator import ImageGenerator
from .generation.video_generator import DisabledVideoProvider
from .jobs import GenerationService, ImageRequest
from .storage import GenerationStorage


class ImageGenerationPayload(BaseModel):
    prompt: str = Field(min_length=1, max_length=2000)
    negative_prompt: str = Field(default="", max_length=1000)
    width: int = Field(default=1024, ge=256, le=2048)
    height: int = Field(default=1024, ge=256, le=2048)
    steps: int = Field(default=9, ge=1, le=50)
    seed: int | None = Field(default=None, ge=0, le=2**32 - 1)
    model: str | None = Field(default=None, max_length=200)

    @field_validator("width", "height")
    @classmethod
    def validate_dimension(cls, value: int) -> int:
        if value % 16:
            raise ValueError("dimensions must be multiples of 16")
        return value

    @field_validator("negative_prompt")
    @classmethod
    def reject_unsupported_negative_prompt(cls, value: str) -> str:
        if value.strip():
            raise ValueError("negative prompt is not supported by Z-Image-Turbo")
        return ""


def create_app(
    settings: Settings | None = None,
    provider_factory: Callable[[], ImageGenerator] | None = None,
) -> FastAPI:
    resolved_settings = settings or load_settings()
    storage = GenerationStorage(resolved_settings.outputs_directory)
    service = GenerationService(resolved_settings, storage, provider_factory)
    video_provider = DisabledVideoProvider()

    @asynccontextmanager
    async def lifespan(_: FastAPI):
        yield
        service.close()

    app = FastAPI(title="AI Generation Lab", version="1.0.0", lifespan=lifespan)
    app.state.generation_service = service

    @app.get("/api/health")
    def health() -> dict[str, Any]:
        return {
            "status": "ok",
            "host": resolved_settings.host,
            "imageProvider": "mflux",
            "videoProvider": "disabled",
        }

    @app.get("/api/models")
    def models() -> dict[str, list[dict[str, Any]]]:
        return {
            "images": [
                {
                    "id": resolved_settings.image_model,
                    "name": "Z-Image Turbo",
                    "quantization": resolved_settings.image_quantization,
                    "negativePrompt": False,
                }
            ],
            "videos": [],
        }

    @app.post("/api/images/generate", status_code=status.HTTP_202_ACCEPTED)
    def generate_image(payload: ImageGenerationPayload) -> dict[str, str]:
        model = payload.model or resolved_settings.image_model
        if model != resolved_settings.image_model:
            raise HTTPException(status_code=400, detail="Unsupported image model")
        job = service.submit_image(
            ImageRequest(
                prompt=payload.prompt.strip(),
                width=payload.width,
                height=payload.height,
                steps=payload.steps,
                seed=payload.seed,
                model=model,
            )
        )
        return {"id": job.id, "status": job.status}

    @app.get("/api/jobs/{job_id}")
    def get_job(job_id: str) -> dict[str, Any]:
        job = service.get_job(job_id)
        if job is None:
            raise HTTPException(status_code=404, detail="Job not found")
        return vars(job)

    @app.get("/api/images")
    def list_images() -> list[dict[str, Any]]:
        return storage.list("image")

    @app.get("/api/images/{generation_id}")
    def get_image(generation_id: str) -> dict[str, Any]:
        try:
            item = storage.get("image", generation_id)
        except ValueError as exc:
            raise HTTPException(status_code=400, detail=str(exc)) from exc
        if item is None:
            raise HTTPException(status_code=404, detail="Image not found")
        return item

    @app.post("/api/videos/generate", status_code=status.HTTP_501_NOT_IMPLEMENTED)
    def generate_video() -> None:
        raise HTTPException(status_code=501, detail=video_provider.reason)

    @app.get("/api/videos")
    def list_videos() -> list[dict[str, Any]]:
        return storage.list("video")

    @app.get("/api/videos/{generation_id}")
    def get_video(generation_id: str) -> dict[str, Any]:
        try:
            item = storage.get("video", generation_id)
        except ValueError as exc:
            raise HTTPException(status_code=400, detail=str(exc)) from exc
        if item is None:
            raise HTTPException(status_code=404, detail="Video not found")
        return item

    app.mount("/outputs", StaticFiles(directory=storage.root), name="outputs")
    app.mount("/", StaticFiles(directory=MODULE_DIR / "web", html=True), name="web")
    return app


app = create_app()


def main() -> None:
    import uvicorn

    settings = load_settings()
    uvicorn.run("server.app:app", host=settings.host, port=settings.port, log_level="info")


if __name__ == "__main__":
    main()