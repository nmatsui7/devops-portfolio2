# Ansible Over SSH With Docker Linux Targets

This Volume 2 lab practices Ansible over SSH without needing AWS, EC2, or a
real remote server. Docker runs three small Ubuntu-based Linux containers, and
Ansible connects to them through `localhost:2222`, `localhost:2223`, and
`localhost:2224`. After nginx is configured, Docker exposes the web pages on
`localhost:8081`, `localhost:8082`, and `localhost:8083`.

In real operations work, you often manage several similar servers. You do not
want to SSH into each one manually and repeat the same commands. Ansible lets
you describe the desired configuration once, then apply it to every host in an
inventory group.

The ping command is only a pre-flight check. It proves Ansible can connect to
every target over SSH and run Python. The playbook is the real exercise: it
turns three plain Linux containers into three small web servers. Each server
receives the same base configuration, but the generated page includes
host-specific facts so you can see that Ansible configured each target
separately.

## Files

```text
ssh-lab/
  Dockerfile
  docker-compose.yml
  inventory.ini
  docker-ssh-playbook.yml
  templates/
    index.html.j2
```

The playbook describes the actions Ansible should perform. The template
describes what the generated file should look like. Ansible fills in the Jinja2
variables separately for each worker, so the same template produces a slightly
different page on `worker1`, `worker2`, and `worker3`.

## Safety

- This lab is local-only.
- Do not expose these SSH containers to the internet.
- Do not reuse the password `ansible123`.
- This is for learning Ansible SSH mechanics only.
- AWS and EC2 remote hosts are optional later, not required for this lab.

## Run the Lab

```bash
docker compose up -d --build
ANSIBLE_HOST_KEY_CHECKING=False ansible -i inventory.ini workers -m ping
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.ini docker-ssh-playbook.yml
docker compose ps
for port in 8081 8082 8083; do
  echo "Checking http://localhost:$port"
  curl -s http://localhost:$port | grep "managed by Ansible"
done
docker compose down
```

You should see successful results for `worker1`, `worker2`, and `worker3`.
First, `docker compose ps` confirms that the three worker containers are
running. Then the loop checks each nginx server through its mapped localhost
port.

Expected verification output:

```text
NAME              STATUS
ansible-worker1   Up
ansible-worker2   Up
ansible-worker3   Up

Checking http://localhost:8081
            <h1>worker1 is managed by Ansible</h1>
Checking http://localhost:8082
            <h1>worker2 is managed by Ansible</h1>
Checking http://localhost:8083
            <h1>worker3 is managed by Ansible</h1>
```

## What This Teaches

- How Ansible uses an inventory to find multiple remote hosts.
- How Ansible logs in over SSH to each target.
- Why a remote user matters.
- Why normal Ansible modules need Python on the target machine.
- How one playbook can configure many Linux targets as web servers.
- How templates and facts make each generated page host-specific.
- Why `ansible.builtin.template` is more realistic than inline `copy` for
  generated nginx config, app config, environment files, systemd unit files, and
  status pages.

## Troubleshooting: `/usr/bin/python3: not found`

Ansible uses Python on the target machine for most modules. If you see an error
like `/usr/bin/python3: not found`, the target container or server does not have
Python installed at that path.

This lab's Docker image installs Python during the Docker build:

```Dockerfile
RUN apt-get update && \
    apt-get install -y --no-install-recommends openssh-server sudo python3 curl nginx
```

For a different Linux target, install Python on that target or update
`ansible_python_interpreter` in `inventory.ini` to the correct Python path.
