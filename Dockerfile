FROM python:3.11-slim

# Set environment
ENV PYTHONUNBUFFERED=1 \
    POETRY_VIRTUALENVS_CREATE=false \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Create a non-root user and app directory
RUN groupadd --gid 1000 appgroup \
 && useradd --uid 1000 --gid appgroup --shell /bin/bash --create-home appuser \
 && mkdir -p /app \
 && chown appuser:appgroup /app

WORKDIR /app

# Install Python dependencies deterministically
# Copy only requirements first for layer caching
COPY requirements.txt /app/requirements.txt

# Use --no-cache-dir and constrained installs from pinned requirements.txt
RUN pip install --upgrade pip setuptools wheel \
 && pip install --no-cache-dir --upgrade -r /app/requirements.txt

# Copy application code
COPY --chown=appuser:appgroup . /app

# Switch to non-root user
USER appuser

# Expose inferred port and run the app bound to 0.0.0.0
EXPOSE 8000

# Use uvicorn as the entrypoint; keep a single worker for predictable memory usage in slim image
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1"]
