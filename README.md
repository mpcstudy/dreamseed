# DreamSeed Portal V2 (scaffold)
- apps/api_gateway (FastAPI :8000)
- apps/career_api (FastAPI :8006)
- apps/ai_orchestrator (FastAPI :8005)
- apps/learner_frontend (:5178)
Run locally:
- Python APIs: uvicorn app.main:app --port 8006 (career), --port 8005 (orchestrator), --port 8000 (gateway)
- Frontend: npx serve -l 5178 apps/learner_frontend/src
