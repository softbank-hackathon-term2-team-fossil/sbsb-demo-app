FROM python:3.12-slim-bookworm

# Prevent Python from writing .pyc files and enable stdout/stderr buffering
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8000

# Create a non-root user and app directory
RUN useradd --no-log-init --home /app --create-home app
WORKDIR /app

# Install pip dependencies deterministically from requirements.txt
# Copy only requirements first to leverage Docker cache
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Ensure app directory ownership for non-root user
RUN chown -R app:app /app

# Switch to non-root user
USER app

# Expose the application's port
EXPOSE 8000

# Start the app with uvicorn, binding to 0.0.0.0
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
