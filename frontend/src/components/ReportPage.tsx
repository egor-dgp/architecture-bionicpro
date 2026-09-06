import React, { useState } from "react";
import { useKeycloak } from "@react-keycloak/web";

type Report = {
  snapshot_date: string;
  customer_id: number | string;
  prosthesis_id: number;
  full_name: string;
  total_usage_sec: number;
  sessions_count: number;
  error_events_count: number;
  last_event_ts: string | null;
};

const API_URL = "http://localhost:8000";

const ReportPage: React.FC = () => {
  const { keycloak, initialized } = useKeycloak();

  const [report, setReport] = useState<Report | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleGetReport = async () => {
    setLoading(true);
    setError(null);
    setReport(null);

    try {
      if (!initialized) {
        setError("Авторизация ещё не инициализирована");
        setLoading(false);
        return;
      }

      if (!keycloak.authenticated) {
        setError("Пользователь не авторизован");
        setLoading(false);
        return;
      }

      // Обновляем токен перед запросом
      await keycloak.updateToken(30);
      const token = keycloak.token;
      if (!token) {
        setError("Не удалось получить токен");
        setLoading(false);
        return;
      }

      // Берём идентификатор пользователя из токена
      const username =
        (keycloak.tokenParsed?.preferred_username as string | undefined) ||
        (keycloak.tokenParsed?.sub as string | undefined);

      if (!username) {
        setError("Не удалось определить пользователя из токена");
        setLoading(false);
        return;
      }

      const customerId = username; // если у тебя customer_id другой — адаптируй маппинг здесь

      const resp = await fetch(`${API_URL}/reports`, {
        method: "GET",
        headers: {
          Accept: "application/json",
          Authorization: `Bearer ${token}`,
        },
      });

      if (!resp.ok) {
        const text = await resp.text();
        setError(`Ошибка ${resp.status}: ${text}`);
        setLoading(false);
        return;
      }

      const data: Report = await resp.json();
      setReport(data);
    } catch (e: any) {
      setError(e.message ?? "Неизвестная ошибка");
    } finally {
      setLoading(false);
    }
  };

  if (!initialized) {
    return <div className="container">Загрузка авторизации...</div>;
  }

  const username =
    (keycloak.tokenParsed?.preferred_username as string | undefined) ||
    (keycloak.tokenParsed?.sub as string | undefined);

  const email = keycloak.tokenParsed?.email as string | undefined;

  return (
    <div className="container">
      <h1>Отчёт по использованию протеза</h1>

      {username && <p>Вы вошли как: {username}</p>}

      <button onClick={handleGetReport} disabled={loading}>
        {loading ? "Получаем отчёт..." : "Получить отчёт"}
      </button>

      {error && (
        <p style={{ color: "red", marginTop: "1rem" }}>
          {error}
        </p>
      )}

      {report && (
        <div className="report-card" style={{ marginTop: "1rem" }}>
          <p>
            <strong>Дата среза:</strong> {report.snapshot_date}
          </p>
          <p>
            <strong>Пользователь:</strong> {report.full_name} (ID{" "}
            {report.customer_id})
          </p>
          <p>
            <strong>ID протеза:</strong> {report.prosthesis_id}
          </p>
          <p>
            <strong>Общее время использования (сек):</strong>{" "}
            {report.total_usage_sec}
          </p>
          <p>
            <strong>Количество сессий:</strong> {report.sessions_count}
          </p>
          <p>
            <strong>Ошибок:</strong> {report.error_events_count}
          </p>
          <p>
            <strong>Последнее событие:</strong>{" "}
            {report.last_event_ts ?? "нет данных"}
          </p>
        </div>
      )}
    </div>
  );
};

export default ReportPage;