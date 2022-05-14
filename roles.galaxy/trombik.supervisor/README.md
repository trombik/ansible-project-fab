# `trombik.supervisor`

[![kitchen](https://github.com/trombik/ansible-role-supervisor/actions/workflows/kitchen.yml/badge.svg)](https://github.com/trombik/ansible-role-supervisor/actions/workflows/kitchen.yml)

`ansible` role to manage `supervisord`.

# Requirements

See [requirements.yml](requirements.yml).

# Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `supervisor_user` | User of `supervisord` | `root` |
| `supervisor_group` | Group of `supervisord` | `{{ __supervisor_group }}` |
| `supervisor_package` | Package of `supervisor` | `{{ __supervisor_package }}` |
| `supervisor_log_dir` | Path to log directory | `{{ __supervisor_log_dir }}` |
| `supervisor_log_file` | Path to log file | `{{ supervisor_log_dir }}/supervisord.log` |
| `supervisor_service` | Service name of `supervisord` | `{{ __supervisor_service }}` |
| `supervisor_conf_dir` | Path to configuration directory | `{{ __supervisor_conf_dir }}` |
| `supervisor_conf_file` | Path to `supervisord.conf` | `{{ supervisor_conf_dir }}/supervisord.conf` |
| `supervisor_conf_d_dir_name` | `basename` of `conf.d` directory | `{{ __supervisor_conf_d_dir_name }}` |
| `supervisor_conf_d_dir` | Path to `conf.d` directory | `{{ supervisor_conf_dir }}/{{ supervisor_conf_d_dir_name }}` |
| `supervisor_config` | Content of `supervisord.conf` | `""` |
| `supervisor_config_owner` | File owner of `supervisor_config` | `{{ supervisor_user }}` |
| `supervisor_config_group` | File group of `supervisor_config` | `{{ __supervisor_config_group }}` |
| `supervisor_config_mode` | File mode of `supervisor_config` | `"0600"` |
| `supervisor_unix_socket_dir` | Path to Unix socket directory | `{{ __supervisor_unix_socket_dir }}` |
| `supervisor_unix_socket_file` | Path to Unix socket file | `{{ supervisor_unix_socket_dir }}/supervisor.sock` |
| `supervisor_pid_dir` | Path to PID file directory | `{{ __supervisor_pid_dir }}` |
| `supervisor_pid_file` | Path to PID file | `{{ supervisor_pid_dir }}/supervisord.pid` |
| `supervisor_flags` | Flags to pass `supervisord` | `""` |
| `supervisor_restart_handler_sleep` | sleep between `stop` and `start` in restart handler | `5` |

## Debian

```yaml
---
__supervisor_group: root
__supervisor_package: supervisor
__supervisor_service: supervisor
__supervisor_conf_dir: "/etc/supervisor"
__supervisor_conf_d_dir_name: conf.d
__supervisor_unix_socket_dir: "/var/run"
__supervisor_pid_dir: "/var/run"
__supervisor_log_dir: "/var/log/supervisor"
__supervisor_config_group: root
```

## FreeBSD

```yaml
---
__supervisor_group: wheel
__supervisor_package: sysutils/py-supervisor
__supervisor_service: supervisord
__supervisor_conf_dir: "/usr/local/etc/supervisor"
__supervisor_conf_d_dir_name: conf.d
__supervisor_unix_socket_dir: "/var/run/supervisor"
__supervisor_pid_dir: "/var/run/supervisor"
__supervisor_log_dir: "/var/log/supervisor"
__supervisor_config_group: wheel
```

## OpenBSD

```yaml
---
__supervisor_group: wheel
__supervisor_package: supervisor
__supervisor_service: supervisord
__supervisor_conf_dir: "/etc/supervisor"
__supervisor_conf_d_dir_name: conf.d
__supervisor_unix_socket_dir: "/var/run/supervisor"
__supervisor_pid_dir: "/var/run/supervisor"
__supervisor_log_dir: "/var/log/supervisor"
__supervisor_config_group: wheel
```

## RedHat

```yaml
---
__supervisor_group: root
__supervisor_package: supervisor
__supervisor_service: supervisord
__supervisor_conf_dir: "/etc"
__supervisor_conf_d_dir_name: supervisord.d
__supervisor_unix_socket_dir: "/run/supervisor"
__supervisor_pid_dir: "/run"
__supervisor_log_dir: "/var/log/supervisor"
__supervisor_config_group: root
```

# Dependencies

None

# Example Playbook

```yaml
---

- hosts: localhost
  roles:
    - ansible-role-supervisor
  vars:
    os_supervisor_flags:
      OpenBSD: "-c {{ supervisor_conf_file }}"
      FreeBSD: |
        supervisord_config="{{ supervisor_conf_file }}"
        supervisord_user="{{ supervisor_user }}"
    # "
    supervisor_flags: "{{ os_supervisor_flags[ansible_os_family] | default('') }}"
    supervisor_config: |
      [unix_http_server]
      file={{ supervisor_unix_socket_file }}

      [supervisord]
      logfile={{ supervisor_log_file }}
      logfile_maxbytes=50MB
      logfile_backups=10
      loglevel=info
      pidfile={{ supervisor_pid_file }}
      nodaemon=false
      minfds=1024
      minprocs=200

      [rpcinterface:supervisor]
      supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface

      [supervisorctl]
      serverurl=unix://{{ supervisor_unix_socket_file }}

      [include]
      files = {{ supervisor_conf_d_dir }}/*.conf
```

# License

```
Copyright (c) 2022 Tomoyuki Sakurai <y@trombik.org>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
```

# Author Information

Tomoyuki Sakurai <y@trombik.org>

This README was created by [qansible](https://github.com/trombik/qansible)
