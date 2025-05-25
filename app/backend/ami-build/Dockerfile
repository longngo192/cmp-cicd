# Use a lightweight Python image
FROM python:3.9-slim

# Define build arguments for repository URL and commit hash
ARG REPO_URL
ARG COMMIT_HASH

# Install git and other dependencies
RUN apt-get update && apt-get install -y \
    git \
    libpq-dev \
    gcc \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone the repository and checkout the specific commit
RUN git clone ${REPO_URL} . && git checkout ${COMMIT_HASH}

# Copy and install requirements
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Ensure migrations folder is created
RUN mkdir -p /app/migrations

# Set environment variables for Flask
ENV FLASK_APP=app.py
ENV FLASK_ENV=development

# Expose port 5000 for API access
EXPOSE 5000

# Run Flask migrations and start the server
CMD flask db init && flask db migrate && flask run --host=0.0.0.0