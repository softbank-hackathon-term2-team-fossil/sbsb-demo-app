FROM python:3.11-slim

# Set environment
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    APP_USER=app \
    APP_HOME=/app \
    PORT=8000

# Create application user and directory
RUN adduser --disabled-password --gecos "" --home "${APP_HOME}" "${APP_USER}"
WORKDIR ${APP_HOME}

# Install build dependencies, install python packages, then remove build deps to keep image small
# Use deterministic pip install from requirements.txt (versions pinned in file)
COPY requirements.txt ./

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        gcc \
        libffi-dev \
        ca-certificates \
    && python -m pip install --upgrade pip setuptools wheel \
    && pip install --no-cache-dir --disable-pip-version-check -r requirements.txt \
    && apt-get purge -y --auto-remove build-essential gcc libffi-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy application code
COPY --chown=${APP_USER}:${APP_USER} . ${APP_HOME}

# Expose inferred app port and switch to non-root user
EXPOSE ${PORT}
USER ${APP_USER}

# Run the app binding to 0.0.0.0
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--proxy-headers"]
