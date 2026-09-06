from datetime import datetime, timedelta

from airflow import DAG
from airflow.providers.postgres.operators.postgres import PostgresOperator

default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

with DAG(
    dag_id="prosthetic_report_dag",
    default_args=default_args,
    start_date=datetime(2026, 2, 25),
    schedule_interval="*/5 * * * *",  # каждые 5 минут
    catchup=False,
    tags=["bionicpro", "etl", "reports"],
) as dag:

    create_fact_table = PostgresOperator(
        task_id="create_fact_prosthetic_usage",
        postgres_conn_id="olap_postgres",
        sql="""
        CREATE SCHEMA IF NOT EXISTS reporting;

        CREATE TABLE IF NOT EXISTS reporting.fact_prosthetic_usage (
            snapshot_date       date        NOT NULL,
            email               text        NOT NULL,
            prosthesis_id       bigint      NOT NULL,
            full_name           text        NOT NULL,
            total_usage_sec     integer     NOT NULL,
            sessions_count      integer     NOT NULL,
            error_events_count  integer     NOT NULL,
            last_event_ts       timestamp   NULL,
            PRIMARY KEY (snapshot_date, email, prosthesis_id)
        );
        """,
    )

    truncate_partition = PostgresOperator(
        task_id="truncate_fact_partition",
        postgres_conn_id="olap_postgres",
        sql="""
        DELETE FROM reporting.fact_prosthetic_usage
        WHERE snapshot_date = '{{ ds }}'::date;
        """,
    )

    load_fact = PostgresOperator(
        task_id="load_fact_prosthetic_usage",
        postgres_conn_id="olap_postgres",
        sql="""
        INSERT INTO reporting.fact_prosthetic_usage (
            snapshot_date,
            email,
            prosthesis_id,
            full_name,
            total_usage_sec,
            sessions_count,
            error_events_count,
            last_event_ts
        )
        SELECT
            '{{ ds }}'::date AS snapshot_date,
            c.email,
            c.prosthesis_id,
            c.full_name,
            COALESCE(SUM(t.duration_sec), 0) AS total_usage_sec,
            COALESCE(COUNT(t.event_id), 0) AS sessions_count,
            COALESCE(SUM(CASE WHEN t.error_flag THEN 1 ELSE 0 END), 0) AS error_events_count,
            COALESCE(MAX(t.event_ts), '{{ ds }}'::date) AS last_event_ts
        FROM
            crm_customers c
        LEFT JOIN
            telemetry_events t
            ON t.prosthesis_id = c.prosthesis_id
           AND t.event_ts >= '{{ ds }}'::date
           AND t.event_ts < ('{{ ds }}'::date + INTERVAL '1 day')
        GROUP BY
            c.email,
            c.prosthesis_id,
            c.full_name;
        """,
    )

    create_fact_table >> truncate_partition >> load_fact