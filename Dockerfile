FROM python:3.12-slim-bookworm

# Metadata
LABEL org.opencontainers.image.title="banchan Workspace (FastAPI)"
LABEL org.opencontainers.image.description="FastAPI app serving a static homepage and /health endpoint"
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PORT=8000

# Create app user and group
RUN groupadd --gid 1000 app && useradd --uid 1000 --gid app --create-home --shell /bin/false app

WORKDIR /app

# Copy only dependencies first for layer caching
COPY requirements.txt /app/requirements.txt

# Install Python dependencies deterministically from requirements.txt
# Avoid installing extra OS packages; rely on prebuilt wheels where possible.
RUN python -m pip install --upgrade pip setuptools && \
    python -m pip install --no-cache-dir -r /app/requirements.txt

# Copy application code
COPY --chown=app:app main.py /app/

# Use non-root user
USER app

# Expose inferred app port and bind to 0.0.0.0 in CMD
EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--loop", "auto", "--workers", "1"]
