FROM nvidia/cuda:12.4.1-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    git \
    curl \
    unzip \
    ffmpeg \
    libgl1 \
    libglib2.0-0 \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN python3 -m pip install --upgrade pip

RUN pip3 install --extra-index-url https://download.pytorch.org/whl/cu124 \
    torch torchvision torchaudio

RUN pip3 install -r requirements.txt

# --- INSTALL COMFYUI MANAGER VIA PIP ---
RUN pip3 install -U --pre comfyui-manager

# --- BAKE CUSTOM NODES DIRECTLY VIA GIT CLONE ---
WORKDIR /app/custom_nodes

RUN git clone https://github.com/city96/ComfyUI-GGUF
RUN git clone https://github.com/kijai/ComfyUI-KJNodes.git

WORKDIR /app
COPY . .

EXPOSE 8080

CMD python3 main.py --listen 0.0.0.0 --port ${PORT:-8080} --enable-manager