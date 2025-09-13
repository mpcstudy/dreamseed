from fastapi import FastAPI
app = FastAPI(title="API Gateway")
@app.get("/__ok")
def ok(): return {"ok": True}
