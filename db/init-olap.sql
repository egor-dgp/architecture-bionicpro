-- Create reporting schema
CREATE SCHEMA IF NOT EXISTS reporting;

-- CRM customers dimension table
CREATE TABLE IF NOT EXISTS crm_customers (
    customer_id     SERIAL PRIMARY KEY,
    email           TEXT NOT NULL UNIQUE,
    full_name       TEXT NOT NULL,
    prosthesis_id   BIGINT NOT NULL UNIQUE,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Telemetry events fact table (raw data source)
CREATE TABLE IF NOT EXISTS telemetry_events (
    event_id        SERIAL PRIMARY KEY,
    prosthesis_id   BIGINT NOT NULL,
    event_ts        TIMESTAMP NOT NULL,
    duration_sec    INTEGER DEFAULT 0,
    error_flag      BOOLEAN DEFAULT FALSE,
    event_type      TEXT DEFAULT 'usage',
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert test customers
INSERT INTO crm_customers (email, full_name, prosthesis_id) VALUES
    ('ivan@example.com', 'Иванов Иван Иванович', 1001),
    ('petr@example.com', 'Петров Петр Петрович', 1002),
    ('sidor@example.com', 'Сидоров Сидор Сидорович', 1003),
    ('anna@example.com', 'Анна Смирнова', 1004),
    ('alex@example.com', 'Алексей Козлов', 1005)
ON CONFLICT (email) DO NOTHING;

-- Insert test telemetry events
INSERT INTO telemetry_events (prosthesis_id, event_ts, duration_sec, error_flag, event_type) VALUES
    (1001, '2026-02-25 08:00:00', 300, FALSE, 'walking'),
    (1001, '2026-02-25 09:00:00', 600, FALSE, 'walking'),
    (1001, '2026-02-25 10:00:00', 150, TRUE, 'error'),
    (1001, '2026-02-26 08:00:00', 450, FALSE, 'walking'),
    (1001, '2026-02-26 09:30:00', 200, FALSE, 'running'),
    (1002, '2026-02-25 07:00:00', 900, FALSE, 'walking'),
    (1002, '2026-02-25 11:00:00', 120, TRUE, 'error'),
    (1002, '2026-02-25 14:00:00', 600, FALSE, 'walking'),
    (1002, '2026-02-26 08:00:00', 300, FALSE, 'walking'),
    (1003, '2026-02-25 06:00:00', 1200, FALSE, 'walking'),
    (1003, '2026-02-25 12:00:00', 450, TRUE, 'error'),
    (1003, '2026-02-25 18:00:00', 300, FALSE, 'walking'),
    (1003, '2026-02-26 07:00:00', 600, FALSE, 'walking'),
    (1003, '2026-02-26 10:00:00', 150, FALSE, 'running'),
    (1004, '2026-02-25 09:00:00', 180, FALSE, 'walking'),
    (1004, '2026-02-26 09:00:00', 240, FALSE, 'walking'),
    (1005, '2026-02-25 08:30:00', 600, TRUE, 'error'),
    (1005, '2026-02-25 15:00:00', 300, FALSE, 'walking'),
    (1005, '2026-02-26 08:00:00', 450, FALSE, 'walking'),
    (1005, '2026-02-26 12:00:00', 200, FALSE, 'running');
