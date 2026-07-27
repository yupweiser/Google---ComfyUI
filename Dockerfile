FROM nvidia/cuda:12.4.1-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# Install system dependencies (including google-cloud-sdk/gcloud storage tools if needed, or rely on base image)
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    git \
    curl \
    ffmpeg \
    libgl1 \
    libglib2.0-0 \
 && rm -rf /var/lib/apt/lists/*

# Install Google Cloud SDK for 'gcloud storage' commands
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
 && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - \
 && apt-get update && apt-get install -y google-cloud-cli

WORKDIR /app

# Copy requirements first to leverage Docker layer caching
COPY requirements.txt .

RUN python3 -m pip install --upgrade pip

# Install PyTorch with CUDA 12.4 support
RUN pip3 install --extra-index-url https://download.pytorch.org/whl/cu124 \
    torch torchvision torchaudio

# Install remaining requirements
RUN pip3 install -r requirements.txt

# Copy the rest of your ComfyUI application code and entrypoint script
COPY . .
RUN chmod +x /app/entrypoint.sh

# Cloud Run passes the port via the PORT environment variable
EXPOSE 8080

# Use entrypoint script to sync bucket nodes and launch
ENTRYPOINT ["/app/entrypoint.sh"]