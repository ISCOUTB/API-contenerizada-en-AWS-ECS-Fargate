from fastapi.testclient import TestClient

from main import app

client = TestClient(app)


def test_health():
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_info():
    response = client.get("/info")

    assert response.status_code == 200
    assert response.json() == {
        "service": "domusnet-api",
        "version": "1.0.0",
        "team": "DOMUSNET",
    }


def test_welcome():
    response = client.get("/")

    assert response.status_code == 200
    assert response.json() == {"message": "API de DOMUSNET lista, esto es una prueba para validar que funciona"}
