FROM python:3.11-slim

# Install system dependencies required by SWE-agent
RUN apt-get update && apt-get install -y \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install pipx
RUN python -m pip install --no-cache-dir pipx
ENV PATH="/root/.local/bin:${PATH}"

# Install mini-swe-agent via pipx
RUN pipx install mini-swe-agent

# Set up working directory
WORKDIR /app

# The default command runs the mini CLI
ENTRYPOINT ["mini"]
