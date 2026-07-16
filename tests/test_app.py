import os
import tempfile

os.environ["LOG_DIR"] = tempfile.mkdtemp()

from app import app


def test_health_endpoint_returns_ok():
    client = app.test_client()

    response = client.get("/health")

    assert response.status_code == 200
    assert response.data.strip() == b"OK"


def test_config_endpoint_returns_json():
    client = app.test_client()

    response = client.get("/config")
    data = response.get_json()

    assert response.status_code == 200
    assert "APP_MODE" in data
    assert "MESSAGE" in data
    assert "DATA_PATH" in data


def test_write_and_read_cycle(tmp_path, monkeypatch):
    data_file = tmp_path / "message.txt"

    monkeypatch.setenv("DATA_PATH", str(data_file))

    client = app.test_client()

    write_response = client.get("/write")
    read_response = client.get("/read")

    assert write_response.status_code == 200
    assert read_response.status_code == 200
    assert b"Hello from flask running on Kubernetes" in read_response.data
