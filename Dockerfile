FROM python:3.11-slim

# Install system deps required to build some Python packages (uvloop, httptools, etc.)
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       build-essential \
       gcc \
       libffi-dev \
       libssl-dev \
       ca-certificates \
       curl \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user and working directory
ENV APP_USER=app
ENV APP_HOME=/app
RUN useradd --system --create-home --home-dir ${APP_HOME} ${APP_USER}
WORKDIR ${APP_HOME}

# Ensure pip is up-to-date and use deterministic installs from requirements.txt
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip setuptools wheel \
    && pip install --no-cache-dir -r requirements.txt

# Copy application source and set permissions
COPY --chown=${APP_USER}:${APP_USER} . ${APP_HOME}

# Drop build tools to reduce image size
USER root
RUN apt-get update \
    && apt-get purge -y --auto-remove build-essential gcc \
    && rm -rf /var/lib/apt/lists/*

# Switch to non-root user
USER ${APP_USER}

# Expose the application port and run the app bound to 0.0.0.0
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
