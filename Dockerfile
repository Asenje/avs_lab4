# Этап 1: builder
FROM python:3.9-buster AS builder

WORKDIR /app

# Обновление реп и базовые пакеты для сборки (в т.ч. psycopg2)
RUN echo "deb http://archive.debian.org/debian/ buster main" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security buster/updates main" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends build-essential libpq-dev && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN pip install --prefix=/install --no-cache-dir -r requirements.txt

# Этап 2: runner
FROM python:3.9-slim-buster AS runner

WORKDIR /app

# Скопировать установленные зависимости из builder
COPY --from=builder /install /usr/local

# Скопировать код приложения
COPY ./app ./app
COPY manage.py .
COPY entrypoint.sh .

# Flask переменная для скрипта
ENV FLASK_APP=manage.py

# Сделать entrypoint.sh исполняемым
RUN chmod +x /app/entrypoint.sh

# Открываем порт приложения
EXPOSE 5555

# Точка входа + команда по заданию
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["gunicorn", "--bind", "0.0.0.0:5555", "manage:app"]
