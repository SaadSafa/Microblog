FROM python:3.11-slim

# Install system dependencies (gcc, netcat for MySQL wait check, etc.)
RUN apt-get update && apt-get install -y \
    build-essential \
    default-libmysqlclient-dev \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python packages
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir gunicorn pymysql cryptography

# Copy application files
COPY app app
COPY migrations migrations
COPY microblog.py config.py boot.sh ./

# Ensure boot.sh is executable
RUN chmod +x boot.sh

# Environment variables
ENV FLASK_APP microblog.py

# Compile translations (safe to skip if none)
RUN flask translate compile || echo "No translations found, skipping"

# Expose the Flask port
EXPOSE 5000

# Run the app
ENTRYPOINT ["./boot.sh"]
