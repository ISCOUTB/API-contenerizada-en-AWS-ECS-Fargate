import logging
import os
import time

from fastapi import FastAPI, Request

SERVICE_NAME = "domusnet-api"
TEAM_NAME = "DOMUSNET"
APP_VERSION = os.getenv("APP_VERSION", "1.0.0")

logging.basicConfig(
    level=os.getenv("LOG_LEVEL", "INFO"),
    format="%(asctime)s %(levelname)s %(name)s %(message)s",
)
logger = logging.getLogger(SERVICE_NAME)

app = FastAPI(title=SERVICE_NAME, version=APP_VERSION)


@app.middleware("http")
async def log_requests(request: Request, call_next):
    started_at = time.perf_counter()
    response = await call_next(request)
    elapsed_ms = (time.perf_counter() - started_at) * 1000
    logger.info(
        "Solicitud %s %s completada con estado %s en %.2f ms",
        request.method,
        request.url.path,
        response.status_code,
        elapsed_ms,
    )
    return response


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/info")
def info():
    return {
        "service": SERVICE_NAME,
        "version": APP_VERSION,
        "team": TEAM_NAME,
    }


@app.get("/")
def welcome():
    return {"message": "API de DOMUSNET lista, esto es una prueba para validar que funciona"}
