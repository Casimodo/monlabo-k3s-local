from __future__ import annotations

import time
from pathlib import Path

from fastapi.testclient import TestClient

from server.app import create_app
from server.config import Settings
from server.generation.image_generator import ImageGenerator


class FakeImage:
    def save(self, path: Path) -> None:
        path.write_bytes(b"fake-png")


class FakeProvider(ImageGenerator):
    def generate(
        self,
        prompt: str,
        width: int,
        height: int,
        steps: int,
        seed: int | None = None,
    ) -> FakeImage:
        return FakeImage()


def make_client(tmp_path: Path) -> TestClient:
    settings = Settings(outputs_directory=tmp_path, keep_model_loaded=False)
    return TestClient(create_app(settings, FakeProvider))


def test_health_and_models(tmp_path: Path) -> None:
    with make_client(tmp_path) as client:
        assert client.get("/api/health").json()["status"] == "ok"
        models = client.get("/api/models").json()
        assert models["images"][0]["negativePrompt"] is False
        assert models["videos"] == []


def test_image_job_lifecycle_and_metadata(tmp_path: Path) -> None:
    with make_client(tmp_path) as client:
        response = client.post(
            "/api/images/generate",
            json={"prompt": "A local laboratory", "width": 512, "height": 512, "steps": 9},
        )
        assert response.status_code == 202
        job_id = response.json()["id"]

        deadline = time.monotonic() + 3
        job = client.get(f"/api/jobs/{job_id}").json()
        while job["status"] not in {"completed", "failed"} and time.monotonic() < deadline:
            time.sleep(0.01)
            job = client.get(f"/api/jobs/{job_id}").json()

        assert job["status"] == "completed"
        metadata = client.get(f"/api/images/{job_id}").json()
        assert metadata["prompt"] == "A local laboratory"
        assert metadata["url"] == f"/outputs/images/{job_id}.png"
        assert client.get(metadata["url"]).content == b"fake-png"
        assert client.get("/api/images").json()[0]["id"] == job_id


def test_validation_and_path_security(tmp_path: Path) -> None:
    with make_client(tmp_path) as client:
        invalid_dimension = client.post(
            "/api/images/generate",
            json={"prompt": "test", "width": 513, "height": 512},
        )
        assert invalid_dimension.status_code == 422
        negative_prompt = client.post(
            "/api/images/generate",
            json={"prompt": "test", "negative_prompt": "blurry"},
        )
        assert negative_prompt.status_code == 422
        assert client.get("/api/images/not-a-valid-id").status_code == 400


def test_video_provider_is_explicitly_disabled(tmp_path: Path) -> None:
    with make_client(tmp_path) as client:
        response = client.post("/api/videos/generate", json={"prompt": "test"})
        assert response.status_code == 501