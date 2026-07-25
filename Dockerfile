FROM nvidia/cuda:12.4.1-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV PORT=8080

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    git \
    ffmpeg \
    libgl1 \
    libglib2.0-0 \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . .

RUN python3 -m pip install --upgrade pip

RUN pip3 install --extra-index-url https://download.pytorch.org/whl/cu124 \
    torch torchvision torchaudio

RUN pip3 install -r requirements.txt

EXPOSE 8080

CMD ["python3", "main.py", "--listen", "0.0.0.0", "--port", "8080"]
