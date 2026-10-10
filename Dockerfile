FROM python:3.12-slim-bookworm

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/opt/venv/bin:$PATH"

WORKDIR /app

# Create a lightweight virtual environment for deterministic installs and isolation
RUN python -m venv /opt/venv \
    && /opt/venv/bin/pip install --upgrade pip setuptools wheel \
    && adduser --disabled-password --gecos "" appuser \
    && chown -R appuser:appuser /opt/venv

# Install Python dependencies deterministically from requirements.txt
COPY requirements.txt /app/requirements.txt
RUN /opt/venv/bin/pip install --no-cache-dir --disable-pip-version-check -r /app/requirements.txt

# Copy application code
COPY . /app
RUN chown -R appuser:appuser /app

USER appuser

EXPOSE 8000

# Bind to 0.0.0.0 so the server is accessible from outside the container
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
