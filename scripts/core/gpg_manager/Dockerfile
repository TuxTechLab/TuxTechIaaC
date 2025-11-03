# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gnupg2 \
    gnupg-agent \
    scdaemon \
    pcscd \
    git \
    pinentry-tty \
    socat \
    && rm -rf /var/lib/apt/lists/*

# Copy the requirements file first to leverage Docker cache
COPY scripts/core/gpg_manager/requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code
COPY . .

# Make port 5000 available to the world outside this container
EXPOSE 5000

# Set environment variables
ENV FLASK_APP=scripts.utils.gpgManager:app
ENV FLASK_ENV=production
ENV PYTHONPATH=/app

# Create a non-root user and switch to it
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser

# Set GNUPGHOME to a writable directory
ENV GNUPGHOME=/home/appuser/.gnupg

# Create required directories and set permissions
RUN mkdir -p /home/appuser/.gnupg \
    && chmod 700 /home/appuser/.gnupg \
    && touch /home/appuser/.gnupg/dirmngr.conf \
    && chmod 600 /home/appuser/.gnupg/dirmngr.conf \
    && echo 'disable-ipv6' >> /home/appuser/.gnupg/dirmngr.conf \
    && echo 'use-agent' > /home/appuser/.gnupg/gpg.conf \
    && echo 'pinentry-mode loopback' >> /home/appuser/.gnupg/gpg.conf \
    && echo 'allow-loopback-pinentry' > /home/appuser/.gnupg/gpg-agent.conf \
    && echo 'pinentry-mode loopback' >> /home/appuser/.gnupg/gpg-agent.conf \
    && echo 'allow-loopback-pinentry' >> /home/appuser/.gnupg/gpg-agent.conf \
    && chown -R appuser:appuser /home/appuser/.gnupg \
    && chmod 600 /home/appuser/.gnupg/*

# Run the application
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "scripts.utils.gpgManager:app"]
