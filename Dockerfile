FROM ubuntu:16.04

# Install base packages
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
        apt-transport-https \
        curl \
        build-essential \
        libpcsclite1 \
        openssh-server \
        sudo \
        less \
        git \
        libgtk2.0-0 \
        libxss1 \
        libasound2 \
        locales \
        nano \
        bash-completion

# Fix locales
RUN locale-gen en_US.UTF-8

# Folder for sshd
RUN mkdir -p /var/run/sshd

# Setup local accounts
RUN useradd --create-home --shell /bin/bash user \
    && usermod -a -G ssh user \
    && usermod -a -G sudo user \
    && echo 'root:StrongPass' | chpasswd \
    && echo 'user:StrongPass' | chpasswd

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# Install VS Code
RUN curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.gpg \
    && echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list \
    && apt-get update \
    && apt-get install -y code

# Cleanup 
RUN apt-get -y autoremove \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
