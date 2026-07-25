FROM nvidia/cuda:12.4.1-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    git \
    ffmpeg \
    libgl1 \
    libglib2.0-0 \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy requirements first to leverage Docker layer caching
COPY requirements.txt .

RUN python3 -m pip install --upgrade pip

# Install PyTorch with CUDA 12.4 support
RUN pip3 install --extra-index-url https://download.pytorch.org/whl/cu124 \
    torch torchvision torchaudio

# Install remaining requirements
RUN pip3 install -r requirements.txt

# Copy the rest of your ComfyUI application code
COPY . .

# Cloud Run passes the port via the PORT environment variable
EXPOSE 8080

# Run ComfyUI listening on all interfaces and the designated port
CMD ["sh", "-c", "python3 main.py --listen 0.0.0.0 --port ${PORT:-8080}"]