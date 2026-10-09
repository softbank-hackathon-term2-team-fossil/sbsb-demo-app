FROM python:3.12-slim-bookworm

# Set a working directory
WORKDIR /app

# Environment
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PATH="/home/app/.local/bin:${PATH}" \
    UVICORN_HOST=0.0.0.0 \
    UVICORN_PORT=8000 \
    UVICORN_WORKERS=1

# Create non-root user
RUN groupadd -g 1000 app \
 && useradd -m -u 1000 -g app -s /bin/bash app

# Copy only what we need for dependency installation first (layer caching)
COPY requirements.txt .

# Install dependencies as the non-root user into --user site to avoid needing root
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates \
 && rm -rf /var/lib/apt/lists/* \
 && pip install --no-cache-dir --upgrade pip setuptools wheel \
 && pip install --no-cache-dir --user -r requirements.txt \
 && find /root/.cache -type f -delete || true

# Copy application code
COPY --chown=app:app . .

# Switch to non-root user
USER app

# Expose inferred application port
EXPOSE 8000

# Run the app; allow overriding CMD at runtime
CMD ["sh", "-c", "exec uvicorn main:app --host ${UVICORN_HOST} --port ${UVICORN_PORT} --workers ${UVICORN_WORKERS} --loop auto --http auto"]
