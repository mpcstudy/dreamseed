from fastapi import FastAPI
from .routers import paths
app = FastAPI(title="Career API")
@app.get("/__ok")
def ok(): return {"ok": True}
app.include_router(paths.router, prefix="/career")
