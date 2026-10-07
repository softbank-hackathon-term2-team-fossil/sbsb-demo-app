FROM python:3.11-slim

# Metadata
LABEL org.opencontainers.image.source="local"
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    POETRY_VIRTUALENVS_CREATE=false

# Create app user and directory
RUN useradd --create-home --home-dir /home/app --shell /bin/bash app
WORKDIR /home/app/app

# Install system deps required to build some Python packages, then clean up
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       build-essential \
       gcc \
       libffi-dev \
       ca-certificates \
       curl \
    && rm -rf /var/lib/apt/lists/*

# Copy only requirements first for better caching
COPY requirements.txt .

# Install Python deps deterministically from requirements.txt
RUN python -m pip install --upgrade pip setuptools wheel \
    && pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY main.py .

# Ensure correct ownership
RUN chown -R app:app /home/app

USER app
EXPOSE 8000

# Run the FastAPI app with Uvicorn, binding to 0.0.0.0
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1"]
