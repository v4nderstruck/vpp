FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Install Dependencies
RUN apt-get update && apt-get install -y \
    build-essential cmake gdb clang clangd \
    git curl wget unzip tar gzip \
    python3 python3-pip python3-venv \
    ripgrep fd-find bear sudo \
    && rm -rf /var/lib/apt/lists/*

RUN ln -s $(which fdfind) /usr/local/bin/fd

# ---------------------------------------------------------
# 2. Install Pin-able Neovim Version
# ---------------------------------------------------------
ARG NEOVIM_VERSION=v0.11.5

# We use the 'releases/download' path which supports both 'stable' and tags like 'v0.10.0'
RUN curl -LO https://github.com/neovim/neovim/releases/download/${NEOVIM_VERSION}/nvim-linux-x86_64.tar.gz \
    && rm -rf /opt/nvim-linux-x86_64 \
    && tar -C /opt -xzf nvim-linux-x86_64.tar.gz \
    && rm nvim-linux-x86_64.tar.gz

# Add to PATH
ENV PATH="$PATH:/opt/nvim-linux-x86_64/bin"
# ---------------------------------------------------------

# ---------------------------------------------------------
# 2. Install Fzf latest
# ---------------------------------------------------------
ARG FZF_VERSION=0.67.0

# We use the 'releases/download' path which supports both 'stable' and tags like 'v0.10.0'
RUN curl -LO https://github.com/junegunn/fzf/releases/download/v${FZF_VERSION}/fzf-${FZF_VERSION}-linux_amd64.tar.gz \
    && rm -rf /opt/bin && mkdir -p /opt/bin \
    && tar -C /opt/bin -xzf fzf-${FZF_VERSION}-linux_amd64.tar.gz \
    && rm fzf-${FZF_VERSION}-linux_amd64.tar.gz

# Add to PATH
ENV PATH="$PATH:/opt/bin"
# ---------------------------------------------------------


ARG USERNAME=dev
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

USER $USERNAME
WORKDIR /home/$USERNAME

RUN mkdir -p /home/$USERNAME/.config/nvim \
    && mkdir -p /home/$USERNAME/.local/share/nvim \
    && mkdir -p /home/$USERNAME/.local/state/nvim

WORKDIR /workspaces/project
CMD ["/bin/bash"]
