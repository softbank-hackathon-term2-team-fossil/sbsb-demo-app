FROM python:3.11-slim-bullseye

# Set a deterministic working directory
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PATH=/home/app/.local/bin:$PATH

WORKDIR /app

# Install runtime dependencies required to build any wheels, then cleanup after pip install
# Use apt only where necessary and remove build deps afterwards to keep image small
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential \
      gcc \
      libffi-dev \
      ca-certificates \
      curl && \
    rm -rf /var/lib/apt/lists/*

# Create a non-root user and ensure ~/.local exists for --user installs if needed
RUN useradd --create-home --shell /bin/bash app && \
    mkdir -p /app && chown -R app:app /app

# Copy dependency manifest first for better layer caching
COPY --chown=app:app requirements.txt /app/requirements.txt

# Install Python dependencies as the non-root user to avoid needing root at runtime
USER app
RUN python -m pip install --upgrade pip setuptools wheel && \
    python -m pip install --no-cache-dir -r /app/requirements.txt

# Switch back to root to remove build deps and cleanup apt caches
USER root
RUN apt-get update && \
    apt-get remove -y --purge build-essential gcc libffi-dev && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Copy application code
COPY --chown=app:app . /app

# Use non-root user for runtime
USER app

# FastAPI default port
EXPOSE 8000

# Bind to 0.0.0.0 so container is reachable from outside
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
