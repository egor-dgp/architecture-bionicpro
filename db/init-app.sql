-- App database initialization
-- This database is used by the backend application

CREATE TABLE IF NOT EXISTS users (
    id              SERIAL PRIMARY KEY,
    email           TEXT NOT NULL UNIQUE,
    full_name       TEXT NOT NULL,
    prosthesis_id   BIGINT NOT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS device_logs (
    id              SERIAL PRIMARY KEY,
    prosthesis_id   BIGINT NOT NULL,
    log_date        DATE NOT NULL DEFAULT CURRENT_DATE,
    status          TEXT DEFAULT 'active',
    firmware_version TEXT,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert test users
INSERT INTO users (email, full_name, prosthesis_id) VALUES
    ('ivan@example.com', 'Иванов Иван Иванович', 1001),
    ('petr@example.com', 'Петров Петр Петрович', 1002),
    ('sidor@example.com', 'Сидоров Сидор Сидорович', 1003),
    ('anna@example.com', 'Анна Смирнова', 1004),
    ('alex@example.com', 'Алексей Козлов', 1005)
ON CONFLICT (email) DO NOTHING;

-- Insert test device logs
INSERT INTO device_logs (prosthesis_id, log_date, status, firmware_version) VALUES
    (1001, CURRENT_DATE, 'active', 'v2.1.0'),
    (1002, CURRENT_DATE, 'active', 'v2.1.0'),
    (1003, CURRENT_DATE, 'warning', 'v2.0.5'),
    (1004, CURRENT_DATE, 'active', 'v2.1.0'),
    (1005, CURRENT_DATE, 'error', 'v1.9.8');
