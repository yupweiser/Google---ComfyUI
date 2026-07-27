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

# --- 1. INSTALL COMFYUI MANAGER VIA PIP AS REQUESTED BY THE ERROR ---
RUN pip3 install -U --pre comfyui-manager

# --- 2. BAKE CUSTOM NODES DIRECTLY INTO THE IMAGE ---
WORKDIR /app/custom_nodes

# Download and extract ComfyUI-GGUF
RUN curl -sL https://github.com/Kosinkadink/ComfyUI-GGUF/archive/refs/heads/main.zip -o gguf.zip && \
    unzip gguf.zip && mv ComfyUI-GGUF-main ComfyUI-GGUF && rm gguf.zip

# Download and extract ComfyUI-KJNodes
RUN curl -sL https://github.com/kijai/ComfyUI-KJNodes/archive/refs/heads/main.zip -o kjnodes.zip && \
    unzip kjnodes.zip && mv ComfyUI-KJNodes-main ComfyUI-KJNodes && rm kjnodes.zip
# --------------------------------------------------------------------

WORKDIR /app
COPY . .

EXPOSE 8080

# --- 3. START COMFYUI WITH THE --enable-manager FLAG ---
CMD python3 main.py --listen 0.0.0.0 --port ${PORT:-8080} --enable-manager