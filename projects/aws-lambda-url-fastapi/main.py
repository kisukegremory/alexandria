from fastapi import FastAPI
from src import api
from mangum import Mangum

app = FastAPI()
lambda_handler = Mangum(app)


@app.get("/")
def hello_world():
    return {"hello": "world"}


@app.get("/squared/{n}")
def squared(n: int, q: str = None):
    return {"squared": n * n, "context": q}


@app.get("/google/")
def google_health_check():
    return api.google()


if __name__ == "__main__":
    import uvicorn

    uvicorn.run("main:app", host="0.0.0.0", port=5000, workers=1)
