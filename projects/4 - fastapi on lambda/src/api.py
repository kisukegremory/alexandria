import httpx


def google() -> dict:
    res = httpx.get("https://www.google.com")
    return {"code": res.status_code}
