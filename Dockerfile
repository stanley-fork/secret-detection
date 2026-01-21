FROM python:3-slim

# Set working directory
WORKDIR /app

# Copy application files
COPY secret-detection.py .
COPY pattern.json .

# Make the script executable
RUN chmod +x secret-detection.py

# Set the entrypoint
ENTRYPOINT ["python3", "secret-detection.py"]

# Default command (can be overridden)
CMD ["--help"]
