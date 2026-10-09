FROM python:3.12-slim-bookworm

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=off

# Create a non-root user for running the app
RUN groupadd --gid 1000 appgroup \
    && useradd --uid 1000 --gid appgroup --home-dir /home/appuser --create-home --shell /bin/false appuser

WORKDIR /app

# Copy dependency declaration first to leverage Docker layer caching
COPY requirements.txt /app/

# Install Python dependencies deterministically from requirements.txt
RUN python -m pip install --upgrade pip setuptools \
    && pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY main.py /app/

# Ensure files are owned by non-root user
RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 8000

# Run the FastAPI app with Uvicorn, listening on all interfaces
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
