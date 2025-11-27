FROM python:3.9-slim-buster AS runner

WORKDIR /app

# добавить client, чтобы появился pg_isready
RUN apt-get update && \
    apt-get install -y --no-install-recommends postgresql-client && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /install /usr/local

COPY ./avs_dockerlab/app ./app
COPY manage.py .
COPY entrypoint.sh .

ENV FLASK_APP=manage.py

RUN chmod +x /app/entrypoint.sh

EXPOSE 5555

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["gunicorn", "--bind", "0.0.0.0:5555", "manage:app"]
