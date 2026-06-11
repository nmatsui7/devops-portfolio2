FROM ubuntu:24.04

RUN apt-get update && \
    apt-get install -y openssh-server sudo python3 && \
    useradd -m -s /bin/bash ansible && \
    echo 'ansible:ansible123' | chpasswd && \
    usermod -aG sudo ansible && \
    echo 'ansible ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ansible && \
    mkdir -p /var/run/sshd && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
