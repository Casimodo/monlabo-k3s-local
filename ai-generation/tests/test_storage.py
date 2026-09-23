from pathlib import Path

import pytest

from server.storage import GenerationStorage


def test_storage_rejects_path_traversal(tmp_path: Path) -> None:
    storage = GenerationStorage(tmp_path)
    with pytest.raises(ValueError, match="generation id"):
        storage.get("image", "../../etc/passwd")