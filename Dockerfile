FROM python:3.12-slim-bookworm

# Set environment
ENV PYTHONUNBUFFERED=1 \
    POETRY_VIRTUALENVS_CREATE=false \
    PATH=/home/app/.local/bin:$PATH

# Create non-root user
RUN useradd --create-home --home-dir /home/app --shell /bin/bash app

WORKDIR /app

# Install Python dependencies deterministically from requirements.txt
# Copy only requirements first to leverage layer caching
COPY requirements.txt ./

# Use pip to install pinned dependencies without caches
RUN python -m pip install --upgrade pip setuptools wheel \
 && python -m pip install --no-cache-dir --require-hashes -r requirements.txt || \
    (python -m pip install --no-cache-dir -r requirements.txt)

# Copy application files
COPY . /app

# Ensure correct ownership
RUN chown -R app:app /app

USER app

# Expose the typical FastAPI/uvicorn port and run the server binding to 0.0.0.0
EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--loop", "auto", "--http", "auto"]
