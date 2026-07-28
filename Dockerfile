FROM nvidia/cuda:12.4.1-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# 1. Added nginx, ttyd, and procps to your dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    git \
    curl \
    unzip \
    ffmpeg \
    libgl1 \
    libglib2.0-0 \
    nginx \
    ttyd \
    procps \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN python3 -m pip install --upgrade pip

RUN pip3 install --extra-index-url https://download.pytorch.org/whl/cu124 \
    torch torchvision torchaudio

RUN pip3 install -r requirements.txt

# --- INSTALL COMFYUI MANAGER VIA PIP ---
RUN pip3 install -U --pre comfyui-manager

# --- CLONE COMFYUI CORE ---
WORKDIR /app
RUN git clone https://github.com/comfy-org/comfyui.git .

# --- BAKE CUSTOM NODES DIRECTLY VIA GIT CLONE ---
WORKDIR /app/custom_nodes
RUN git clone https://github.com/city96/ComfyUI-GGUF
RUN git clone https://github.com/kijai/ComfyUI-KJNodes.git

# Go back to root app directory
WORKDIR /app

# 2. Copy your Nginx config and startup script into the container
COPY nginx.conf /etc/nginx/nginx.conf
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Cloud Run strictly uses port 8080 for the entrypoint web server (Nginx)
EXPOSE 8080

# 3. Hand over execution to the startup script
CMD ["/start.sh"]