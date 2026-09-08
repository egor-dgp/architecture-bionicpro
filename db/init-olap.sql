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

-- Insert test customers (legacy)
INSERT INTO crm_customers (email, full_name, prosthesis_id) VALUES
    ('ivan@example.com', 'Иванов Иван Иванович', 1001),
    ('petr@example.com', 'Петров Петр Петрович', 1002),
    ('sidor@example.com', 'Сидоров Сидор Сидорович', 1003),
    ('anna@example.com', 'Анна Смирнова', 1004),
    ('alex@example.com', 'Алексей Козлов', 1005)
ON CONFLICT (email) DO NOTHING;

-- Insert Keycloak users (matching realm-export.json)
INSERT INTO crm_customers (email, full_name, prosthesis_id) VALUES
    ('user1@example.com', 'User One', 2001),
    ('user2@example.com', 'User Two', 2002),
    ('admin1@example.com', 'Admin One', 2003),
    ('prothetic1@example.com', 'Prothetic One', 2010),
    ('prothetic2@example.com', 'Prothetic Two', 2011),
    ('prothetic3@example.com', 'Prothetic Three', 2012)
ON CONFLICT (email) DO NOTHING;

-- Insert test telemetry events (legacy)
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
    (1005, '2026-02-26 12:00:00', 200, FALSE, 'running'),
    -- prothetic1 (prosthesis_id 2010)
    (2010, '2026-02-25 08:00:00', 500, FALSE, 'walking'),
    (2010, '2026-02-25 10:00:00', 300, FALSE, 'walking'),
    (2010, '2026-02-25 12:00:00', 100, TRUE, 'error'),
    (2010, '2026-02-26 08:00:00', 600, FALSE, 'walking'),
    (2010, '2026-02-26 14:00:00', 250, FALSE, 'running'),
    -- prothetic2 (prosthesis_id 2011)
    (2011, '2026-02-25 07:30:00', 800, FALSE, 'walking'),
    (2011, '2026-02-25 09:00:00', 200, TRUE, 'error'),
    (2011, '2026-02-25 15:00:00', 400, FALSE, 'walking'),
    (2011, '2026-02-26 07:00:00', 550, FALSE, 'walking'),
    (2011, '2026-02-26 11:00:00', 150, FALSE, 'running'),
    -- prothetic3 (prosthesis_id 2012)
    (2012, '2026-02-25 06:00:00', 1000, FALSE, 'walking'),
    (2012, '2026-02-25 10:00:00', 350, FALSE, 'walking'),
    (2012, '2026-02-25 14:00:00', 200, TRUE, 'error'),
    (2012, '2026-02-26 08:30:00', 700, FALSE, 'walking'),
    (2012, '2026-02-26 16:00:00', 300, FALSE, 'running');
