FROM mcr.microsoft.com/devcontainers/typescript-node:1-20-bookworm

USER node

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash

# Install Foundry
RUN curl -L https://foundry.paradigm.xyz | bash \
  && /bin/bash -c "source ~/.bashrc && ~/.foundry/bin/foundryup"
