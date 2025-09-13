#!/usr/bin/env bash
set -euo pipefail
mkdir -p apps/{learner_frontend,api_gateway,career_api,ai_orchestrator} packages/{shared-types,shared-ui} .github/workflows db/{migrations,seeds} scripts docs

# 루트 파일들
cat > package.json <<'J'
{ "name":"dreamseed","private":true,"workspaces":["apps/*","packages/*"],
  "devDependencies":{"turbo":"^2.0.0","typescript":"^5.4.0"},
  "scripts":{"dev":"turbo run dev --parallel"} }
J

cat > .gitignore <<'G'
node_modules/
dist/
build/
.venv/
.DS_Store
.env
G

cat > .cursorrules <<'C'
version: 1
priority:
  - include: "apps/**"
  - include: "packages/**"
  - exclude: "node_modules/**"
  - exclude: "dist/**"
  - exclude: ".venv/**"
C

# CI
mkdir -p .github/workflows
cat > .github/workflows/ci.yml <<'Y'
name: CI
on:
  push: { branches: [ "main" ] }
  pull_request: { branches: [ "main" ] }
jobs:
  node:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20' }
      - run: |
          set -e
          if [ -f package.json ]; then npm i; fi
          for d in apps/* packages/*; do
            [ -f "$d/package.json" ] && (cd "$d"; npm i || true; npm run build || true)
          done
  python:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: { python-version: '3.11' }
      - run: echo "no python projects yet"
Y

# Learner (아주 최소: 정적 HTML + fetch)
mkdir -p apps/learner_frontend/src
cat > apps/learner_frontend/package.json <<'P'
{ "name":"learner_frontend","private":true,"type":"module",
  "scripts":{"dev":"npx serve -l 5178"},
  "dependencies":{},"devDependencies":{} }
P
cat > apps/learner_frontend/src/index.html <<'H'
<!doctype html><meta charset="utf-8"><div id="root"></div>
<script type="module">
const base = location.origin.replace(':5178', ':8000');
fetch(`${base}/career/paths?interest=ai&locale=ko`).then(r=>r.json()).then(list=>{
  document.getElementById('root').innerHTML =
    '<h1>추천 진로</h1>' + list.map(p=>`<div>${p.title}</div>`).join('');
}).catch(()=>{ document.getElementById('root').textContent='API 연결 대기'; });
</script>
H

# API Gateway (FastAPI)
mkdir -p apps/api_gateway/app
cat > apps/api_gateway/app/main.py <<'M'
from fastapi import FastAPI
app = FastAPI(title="API Gateway")
@app.get("/__ok")
def ok(): return {"ok": True}
M
cat > apps/api_gateway/pyproject.toml <<'T'
[project] name="api_gateway"; version="0.0.1"; dependencies=["fastapi","uvicorn[standard]"]
T

# Career API (FastAPI)
mkdir -p apps/career_api/app/routers
cat > apps/career_api/app/main.py <<'M2'
from fastapi import FastAPI
from .routers import paths
app = FastAPI(title="Career API")
@app.get("/__ok")
def ok(): return {"ok": True}
app.include_router(paths.router, prefix="/career")
M2
cat > apps/career_api/app/routers/paths.py <<'R'
from fastapi import APIRouter, Query
router = APIRouter()
@router.get("/paths")
def list_paths(interest: str | None = Query(None), locale: str = "ko"):
    data = [
      {"id":"ai_dev","title":"AI 개발자","summary":"모델/인프라/데이터"},
      {"id":"data_analyst","title":"데이터 분석가","summary":"SQL/통계/시각화"}
    ]
    if interest: data = [d for d in data if interest.lower() in (d["id"]+d["title"]).lower()]
    return data
R

# AI orchestrator (FastAPI)
mkdir -p apps/ai_orchestrator/app
cat > apps/ai_orchestrator/app/main.py <<'AO'
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
AO
cat > apps/ai_orchestrator/pyproject.toml <<'T2'
[project] name="ai_orchestrator"; version="0.0.1"; dependencies=["fastapi","uvicorn[standard]","pydantic"]
T2

# Shared 최소
mkdir -p packages/shared-types/src packages/shared-ui/src
cat > packages/shared-types/src/index.ts <<'S'
export type CareerPath = { id:string; title:string; summary?:string; outlook_score?:number };
S
cat > packages/shared-ui/src/index.ts <<'U'
export const noop = () => null;
U

# README 보강
cat > README.md <<'D'
# DreamSeed Portal V2 (scaffold)
- apps/api_gateway (FastAPI :8000)
- apps/career_api (FastAPI :8006)
- apps/ai_orchestrator (FastAPI :8005)
- apps/learner_frontend (:5178)
Run locally:
- Python APIs: uvicorn app.main:app --port 8006 (career), --port 8005 (orchestrator), --port 8000 (gateway)
- Frontend: npx serve -l 5178 apps/learner_frontend/src
D
