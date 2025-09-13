Thanks! Great start. For consistency with our portal conventions, could you please make these adjustments?

1) Port & Procfile
   - Default port: 8005 for apps/ai_orchestrator
   - Expose PORT env, use process.env.PORT || 8005

2) API contract alignment
   - POST /ai/assist
     - Request keys: { "lang", "domain", "prompt" }  (rename language→lang, message→prompt)
     - Response: include { "model", "answer", "lang" }
   - Health: GET /__ok  (rename /health)

3) Language handling
   - Accept ko/ko-KR, zh/zh-CN/zh-TW (case-insensitive, trim)
   - Mapping: ko*→korean-llm, zh*→deepseek, else→gpt-4o-mini

4) Validation & errors
   - 422 on missing/empty prompt or invalid lang/domain
   - JSON error shape: { "error": { "code":"VALIDATION_ERROR", "message":"..." } }

5) Tests
   - Update tests for new keys/endpoints & add cases:
     - ko, zh, fallback
     - invalid lang/domain, empty prompt
     - GET /__ok

6) Docs
   - README: curl examples with /ai/assist (lang/prompt) and port 8005
   - Mention CORS, body size limit, basic rate limit

If you agree, please update the PR. Thanks!
