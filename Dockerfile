# Этап 1: builder
FROM python:3.9-buster AS builder

WORKDIR /app

# apt + requirements как раньше...

COPY requirements.txt .

RUN pip install --prefix=/install --no-cache-dir -r requirements.txt

# Этап 2: runner
FROM python:3.9-slim-buster AS runner

WORKDIR /app

COPY --from=builder /install /usr/local

# ВАЖНО: правильный путь к коду
COPY ./avs_dockerlab/app ./app
COPY manage.py .
COPY entrypoint.sh .

ENV FLASK_APP=manage.py

RUN chmod +x /app/entrypoint.sh

EXPOSE 5555

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["gunicorn", "--bind", "0.0.0.0:5555", "manage:app"]
