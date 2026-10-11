FROM python:3.11-slim-bookworm

# Metadata
LABEL org.opencontainers.image.description="banchan Workspace FastAPI app"
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PORT=8000

# Create app user and directory
RUN useradd --create-home --no-log-init --shell /usr/sbin/nologin appuser
WORKDIR /app

# Install dependencies deterministically
COPY requirements.txt .
RUN pip install --upgrade pip setuptools wheel \
    && pip install --no-cache-dir --require-hashes -r requirements.txt

# Copy application code
COPY --chown=appuser:appuser . .

# Use non-root user
USER appuser

# Expose port and default command
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1"]
