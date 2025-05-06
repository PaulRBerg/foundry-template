FROM mcr.microsoft.com/devcontainers/typescript-node:1-20-bookworm

# Install Python feature
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
  && apt-get -y install --no-install-recommends python-dev-is-python3 build-essential python3 python3-pip python3-venv

USER node

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash

# Install Foundry
RUN curl -L https://foundry.paradigm.xyz | bash \
  && /bin/bash -c "source ~/.bashrc && ~/.foundry/bin/foundryup"
