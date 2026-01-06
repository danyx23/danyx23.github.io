# Dev Container for Jekyll site with pi-coding-agent
FROM ruby:3.2

# Install build dependencies and Node.js
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    curl \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install pi-coding-agent globally
RUN npm install -g @mariozechner/pi-coding-agent

# Install just (command runner)
RUN curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin

# Set the working directory
WORKDIR /workspace

# Create a non-root user for VS Code
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Set default user
USER $USERNAME

# Expose Jekyll port
EXPOSE 4000
