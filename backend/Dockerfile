FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .

# Увеличиваем таймаут и ставим быстрый зеркальный репозиторий PyPI
RUN pip install --no-cache-dir --default-timeout=300 \
    -i https://pypi.tuna.tsinghua.edu.cn/simple \
    -r requirements.txt

COPY main.py .

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]