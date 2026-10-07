FROM python:3.12-slim

# Set environment
ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PORT=8000

# Create app directory
WORKDIR /app

# Install system build deps required to build any wheels (will be removed after)
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       build-essential \
       gcc \
       libffi-dev \
       libssl-dev \
       ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy dependency specification first for better caching
COPY requirements.txt ./requirements.txt

# Upgrade pip, install wheel and pinned dependencies
RUN python -m pip install --upgrade pip setuptools wheel \
    && pip install --no-cache-dir -r requirements.txt

# Remove build dependencies to keep image slim
RUN apt-get purge -y --auto-remove build-essential gcc libffi-dev libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy application code
COPY . /app

# Create a non-root user and give ownership of the app directory
RUN groupadd --gid 1000 appgroup \
    && useradd --uid 1000 --gid appgroup --home-dir /home/appuser --create-home --shell /bin/bash appuser \
    && chown -R appuser:appgroup /app

USER appuser

# Expose expected FastAPI/Uvicorn port
EXPOSE 8000

# Run the app, binding to 0.0.0.0
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--proxy-headers"]
