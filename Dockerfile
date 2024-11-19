# syntax = docker/dockerfile:1.0-experimental
FROM pytorch/pytorch:2.5.1-cuda12.1-cudnn9-devel

# working directory
WORKDIR /workspace

RUN \
    # Install System Dependencies
    apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        wget \
        unzip \
        psmisc \
        vim \
        git \
        ssh \
        curl && \
    rm -rf /var/lib/apt/lists/*

# Create Virtual Environment
# https://pythonspeed.com/articles/activate-virtualenv-dockerfile/
RUN python3 -m venv /opt/venv-ttt
RUN python3 -m venv /opt/venv-inference

# Build Python depencies and utilize caching
COPY ./requirements.txt /workspace/main/requirements.txt

RUN . /opt/venv-ttt/bin/activate && \
    pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir \
        tqdm \
        numpy \
        scipy \
        matplotlib \
        torchtune@git+https://github.com/ekinakyurek/torchtune.git@ekin/llama32 && \
    pip install --no-cache-dir \
        torch \
        torchao \
        --pre --upgrade --index-url https://download.pytorch.org/whl/nightly/cu121

RUN . /opt/venv-inference/bin/activate && \
    pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir \
        tqdm \
        numpy \
        scipy \
        matplotlib \
        vllm@git+https://github.com/ekinakyurek/vllm.git@ekin/torchtunecompat

# upload everything
COPY . /workspace/main/

# Set HOME
ENV HOME="/workspace/main"

# Reset Entrypoint from Parent Images
# https://stackoverflow.com/questions/40122152/how-to-remove-entrypoint-from-parent-image-on-dockerfile/40122750
ENTRYPOINT []

# load bash
CMD /bin/bash