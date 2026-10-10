FROM python:3.12-slim-bookworm

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Create app user and directory
RUN addgroup --system app && adduser --system --group --home /app app
WORKDIR /app
COPY --chown=app:app requirements.txt /app/

# Install runtime dependencies deterministically from pinned requirements
RUN python -m pip install --upgrade pip setuptools wheel \
 && pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY --chown=app:app . /app

USER app

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--proxy-headers"]
