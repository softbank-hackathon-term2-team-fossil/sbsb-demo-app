FROM python:3.11-slim-bookworm

# Create app user and directory
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    APP_HOME=/app \
    PORT=8000

RUN addgroup --system app && adduser --system --ingroup app --home ${APP_HOME} app

WORKDIR ${APP_HOME}

# Copy only requirements first for better caching
COPY requirements.txt .

# Use deterministic, cached-less pip install; prefer binary wheels when available
RUN python -m pip install --upgrade pip setuptools wheel \
    && python -m pip install --no-cache-dir --prefer-binary -r requirements.txt

# Copy application source
COPY . .

# Ensure app directory ownership is correct for non-root user
RUN chown -R app:app ${APP_HOME}

USER app

EXPOSE 8000

# Use uvicorn to bind to 0.0.0.0; keep single worker for lightweight SQLite usage
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1"]
