FROM python:3.12-slim-bookworm

# Create a non-root user and group
ARG APP_USER=app
ARG APP_UID=1000
RUN groupadd --gid ${APP_UID} ${APP_USER} \
    && useradd --uid ${APP_UID} --gid ${APP_UID} --home /home/${APP_USER} --create-home --shell /bin/bash ${APP_USER}

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    VENV_PATH=/opt/venv \
    PATH=/opt/venv/bin:$PATH \
    PORT=8000

# Install a contained virtualenv for deterministic installs
RUN python -m venv $VENV_PATH \
    && $VENV_PATH/bin/python -m pip install --upgrade pip setuptools wheel

WORKDIR /app

# Copy and install only dependencies first to leverage layer caching
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy application source
COPY main.py ./

# Ensure app directory is owned by non-root user
RUN chown -R ${APP_USER}:${APP_USER} /app

EXPOSE 8000

USER ${APP_USER}

# Bind to 0.0.0.0 and use PORT env var; keep single worker for predictable resource usage
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--loop", "auto", "--proxy-headers", "--workers", "1"]
