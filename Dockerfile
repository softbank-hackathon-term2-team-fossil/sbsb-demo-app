FROM python:3.11-slim

# Set environment
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8000

# Create a non-root user and app directory
RUN groupadd --gid 1000 appgroup \
    && useradd --uid 1000 --gid appgroup --shell /bin/false --create-home appuser

WORKDIR /app

# Install runtime and build dependencies required for some uvicorn extras (then clean)
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       build-essential \
       gcc \
       libc-dev \
       libssl-dev \
       libffi-dev \
       ca-certificates \
       wget \
    && rm -rf /var/lib/apt/lists/*

# Install pip packages deterministically from requirements.txt
# Copy only requirements first to leverage Docker layer caching
COPY requirements.txt /app/requirements.txt
RUN pip install --upgrade pip setuptools wheel \
    && pip install --no-cache-dir -r /app/requirements.txt

# Copy application code
COPY --chown=appuser:appgroup . /app

# Switch to non-root user
USER appuser

# Expose application port and run Uvicorn, binding to 0.0.0.0
EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
