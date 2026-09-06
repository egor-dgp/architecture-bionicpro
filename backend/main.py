from fastapi import FastAPI, HTTPException, Query, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import jwt
from typing import Optional
from datetime import date
from fastapi.middleware.cors import CORSMiddleware
import psycopg2
import os



app = FastAPI(title="BionicPro Reports API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

security = HTTPBearer()

DB_HOST = os.getenv("OLAP_DB_HOST", "olap_db")
DB_PORT = int(os.getenv("OLAP_DB_PORT", "5432"))
DB_NAME = os.getenv("OLAP_DB_NAME", "olap_db")
DB_USER = os.getenv("OLAP_DB_USER", "olap_user")
DB_PASS = os.getenv("OLAP_DB_PASS", "olap_password")

def get_connection():
    return psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASS,
    )

def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
):
    token = credentials.credentials
    try:
        payload = jwt.decode(
            token,
            key="",
            options={"verify_signature": False, "verify_aud": False},
        )
    except Exception:
        raise HTTPException(status_code=401, detail="Invalid token")

    # НЕ трогаем username, НЕ подменяем его email'ом
    username = payload.get("preferred_username") or payload.get("sub")
    email = payload.get("email")
    if not email:
        raise HTTPException(status_code=401, detail="Email is missing in token")

    return {
        "username": username,
        "email": email,
        "raw": payload,
    }

from datetime import date
from typing import Optional
from fastapi import Query, Depends, HTTPException

@app.get("/reports")
def get_report(
    snapshot_date: Optional[date] = Query(
        None,
        description="Дата среза отчёта; если не указана — берём последний доступный срез",
    ),
    current_user=Depends(get_current_user),
):
    email = current_user["email"]

    conn = get_connection()
    try:
        cur = conn.cursor()

        if snapshot_date is None:
            cur.execute(
                """
                SELECT
                    snapshot_date,
                    email,
                    prosthesis_id,
                    full_name,
                    total_usage_sec,
                    sessions_count,
                    error_events_count,
                    last_event_ts
                FROM reporting.fact_prosthetic_usage
                WHERE email = %s
                ORDER BY snapshot_date DESC
                LIMIT 1
                """,
                (email,),
            )
        else:
            cur.execute(
                """
                SELECT
                    snapshot_date,
                    email,
                    prosthesis_id,
                    full_name,
                    total_usage_sec,
                    sessions_count,
                    error_events_count,
                    last_event_ts
                FROM reporting.fact_prosthetic_usage
                WHERE email = %s AND snapshot_date = %s
                """,
                (email, snapshot_date),
            )

        row = cur.fetchone()
        if row is None:
            raise HTTPException(status_code=404, detail="Report not found")

        (
            snapshot_date_value,
            email_value,
            prosthesis_id,
            full_name,
            total_usage_sec,
            sessions_count,
            error_events_count,
            last_event_ts,
        ) = row

        return {
            "snapshot_date": snapshot_date_value.isoformat(),
            "email": email_value,
            "prosthesis_id": prosthesis_id,
            "full_name": full_name,
            "total_usage_sec": total_usage_sec,
            "sessions_count": sessions_count,
            "error_events_count": error_events_count,
            "last_event_ts": last_event_ts.isoformat() if last_event_ts else None,
        }
    finally:
        conn.close()
