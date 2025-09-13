from fastapi import FastAPI
from pydantic import BaseModel, field_validator
app = FastAPI(title="AI Orchestrator")

class AssistIn(BaseModel):
    lang: str = "en"
    domain: str = "general"
    prompt: str
    @field_validator("lang")
    @classmethod
    def norm_lang(cls, v): return (v or "en").strip().lower()

def choose_model(lang: str, domain: str) -> str:
    if lang.startswith("ko"): return "korean-llm"
    if lang.startswith("zh"): return "deepseek"
    return "gpt-4o-mini"

@app.get("/__ok")
def ok(): return {"ok": True}

@app.post("/ai/assist")
def assist(body: AssistIn):
    model = choose_model(body.lang, body.domain)
    return {"model": model, "answer": "(stub)", "lang": body.lang}
