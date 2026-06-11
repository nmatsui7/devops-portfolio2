# Ansible Over SSH With a Docker Linux Target

This Volume 2 lab practices Ansible over SSH without needing AWS, EC2, or a
real remote server. Docker runs a small Ubuntu-based Linux container, and
Ansible connects to it through `localhost:2222`.

## Safety

- This lab is local-only.
- Do not expose this SSH container to the internet.
- Do not reuse the password `ansible123`.
- This is for learning Ansible SSH mechanics only.
- AWS and EC2 remote hosts are optional later, not required for this lab.

## Run the Lab

```bash
docker compose up -d --build
ANSIBLE_HOST_KEY_CHECKING=False ansible -i inventory.ini workers -m ping
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.ini docker-ssh-playbook.yml
docker compose down
```

## What This Teaches

- How Ansible uses an inventory to find a remote host.
- How Ansible logs in over SSH.
- Why a remote user matters.
- Why normal Ansible modules need Python on the target machine.
- How a playbook can create files on a remote Linux target.

## Troubleshooting: `/usr/bin/python3: not found`

Ansible uses Python on the target machine for most modules. If you see an error
like `/usr/bin/python3: not found`, the target container or server does not have
Python installed at that path.

This lab's Docker image installs Python during the Docker build:

```Dockerfile
RUN apt-get update && \
    apt-get install -y openssh-server sudo python3
```

For a different Linux target, install Python on that target or update
`ansible_python_interpreter` in `inventory.ini` to the correct Python path.
