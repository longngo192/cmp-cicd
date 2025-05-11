# Use a lightweight Python image
FROM python:3.9-slim

WORKDIR /app

# Copy dependency files first
COPY requirements.txt requirements.txt
RUN apt-get update && apt-get install -y libpq-dev gcc && \
    pip install --no-cache-dir -r requirements.txt

COPY . .

# Ensure migrations folder is created
RUN mkdir -p /app/migrations

# Set environment variables for Flask
ENV FLASK_APP=app.py
ENV FLASK_ENV=development

# Expose port 5000 for API access
EXPOSE 5000

# Run Flask inside the container
CMD ["flask", "db", "init"]
CMD ["flask", "db", "migrate"]
CMD ["flask", "run", "--host=0.0.0.0"]
