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
