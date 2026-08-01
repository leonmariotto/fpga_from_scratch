FROM ubuntu:noble

# Install common tools
RUN apt-get update \
	&& apt-get install -y wget software-properties-common curl \
	poppler-utils python3.12-venv sudo make bubblewrap libatomic1 \
    git gcc bc

# Gran ubuntu user passwordless sudo
RUN echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ubuntu \
    && chmod 0440 /etc/sudoers.d/ubuntu

ENV DEBIAN_FRONTEND=noninteractive

# Create a user with UID/GID 1000
# RUN groupadd --gid 1000 useragent \
#     && useradd --uid 1000 --gid 1000 --create-home --shell /bin/bash useragent \
#     && echo 'useragent ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/useragent \
#     && chmod 0440 /etc/sudoers.d/useragent

# Install ripgrep
RUN wget https://github.com/BurntSushi/ripgrep/releases/download/15.1.0/ripgrep_15.1.0-1_amd64.deb
RUN apt install ./ripgrep_15.1.0-1_amd64.deb

RUN mkdir /workspace && chown -R ubuntu:ubuntu /workspace

RUN mkdir /home/ubuntu/.codex && chown -R ubuntu:ubuntu /home/ubuntu/.codex
RUN mkdir /home/ubuntu/.cache && chown -R ubuntu:ubuntu /home/ubuntu/.cache

USER ubuntu

WORKDIR /workspace

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Install codex
RUN curl -LsSf https://github.com/openai/codex/releases/download/rust-v0.146.0/install.sh | STANDALONE_ROOT="/home/ubuntu/codex_standalone_package" bash

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
