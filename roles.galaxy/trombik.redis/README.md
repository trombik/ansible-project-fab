# `trombik.redis`

Install and configures redis and sentinel.

## Notes for uses considering using sentinel for clustering

In the role, sentinel support is supposed to work, but not all platforms have
been tested. Expect bugs.

# Requirements

At least one "save $N" as a key must be defined in `redis_sentinel_config`. See
Example Playbook.

# Role Variables

## Variables for `redis`

| Variable | Description | Default |
|----------|-------------|---------|
| `redis_user` | redis user | `{{ __redis_user }}` |
| `redis_group` | redis group | `{{ __redis_group }}` |
| `redis_package` | redis server package | `{{ __redis_package }}` |
| `redis_service` | redis service name | `{{ __redis_service }}` |
| `redis_conf_dir` | dirname of `redis.conf` | `{{ __redis_conf_dir }}` |
| `redis_conf_file` | path to `redis.conf` | `{{ redis_conf_dir }}/redis.conf` |
| `redis_conf_file_ansible` | static config file for redis | `{{ redis_conf_file }}.ansible` |
| `redis_enable` | enable redis. if true, `tasks/redis.yml` is invoked | `true` |
| `redis_config` | content of `redis.conf` | `""` |

## Variables for `sentinel`

| Variable | Description | Default |
|----------|-------------|---------|
| `redis_sentinel_group` | list of sentinel nodes. The first one is the master | `[]` |
| `redis_sentinel_service` | service name of sentinel | `{{ __redis_sentinel_service }}` |
| `redis_sentinel_conf_file` | path to `sentinel.conf` | `{{ __redis_sentinel_conf_file }}` |
| `redis_sentinel_conf_file_ansible` | path to static config file for redis | `{{ redis_sentinel_conf_file }}.ansible` |
| `redis_sentinel_enable` | enable sentinel. `tasks/sentinel.yml` is invoked | `false` |
| `redis_sentinel_password` | password for `sentinel auth-pass` | `""` |
| `redis_sentinel_master_name` | `master-name`, which is used for several sentinel commands | `""` |
| `redis_sentinel_master_port` | port to monitor redis | `6379` |
| `redis_sentinel_quorum` | number of quorum | `2` |
| `redis_sentinel_parallel_syncs` | `sentinel parallel-syncs` | `1` |
| `redis_sentinel_down_after_milliseconds` | `sentinel down-after-milliseconds` | `5000` |
| `redis_sentinel_failover_timeout` | `sentinel failover-timeout` | `180000` |
| `redis_sentinel_logdir` | path to log directory for `sentinel.log` | `{{ __redis_sentinel_logdir }}` |
| `redis_sentinel_logfile` | path to`sentinel.log` | `{{ redis_sentinel_logdir }}/sentinel.log` |
| `redis_sentinel_port` | the port sentinel binds to | `26379` |
| `redis_sentinel_config` | content of `sentinel.conf` | `""` |

## Debian

| Variable | Default |
|----------|---------|
| `__redis_user` | `redis` |
| `__redis_group` | `redis` |
| `__redis_package` | `redis-server` |
| `__redis_service` | `redis-server` |
| `__redis_conf_dir` | `/etc/redis` |
| `__redis_sentinel_logdir` | `/var/log/redis` |

## FreeBSD

| Variable | Default |
|----------|---------|
| `__redis_user` | `redis` |
| `__redis_group` | `redis` |
| `__redis_package` | `redis` |
| `__redis_service` | `redis` |
| `__redis_conf_dir` | `/usr/local/etc/redis` |
| `__redis_sentinel_logdir` | `/var/log/redis` |


## OpenBSD

| Variable | Default |
|----------|---------|
| `__redis_user` | `_redis` |
| `__redis_group` | `_redis` |
| `__redis_package` | `redis` |
| `__redis_service` | `redis` |
| `__redis_conf_dir` | `/etc/redis` |
| `__redis_sentinel_logdir` | `/var/log/redis` |

## RedHat

| Variable | Default |
|----------|---------|
| `__redis_user` | `redis` |
| `__redis_group` | `redis` |
| `__redis_package` | `redis` |
| `__redis_service` | `redis` |
| `__redis_conf_dir` | `/etc` |
| `__redis_sentinel_logdir` | `/var/log/redis` |

# Dependencies

None

# Example Playbook

```yaml
---
- hosts: localhost
  pre_tasks:
  roles:
    - ansible-role-redis
  vars:
    redis_password: password
    redis_config: |
      databases 17
      save 900 1
      requirepass "{{ redis_password }}"
      bind 127.0.0.1
      protected-mode yes
      port {{ redis_port }}
      timeout 0
      tcp-keepalive 300
      daemonize yes
      pidfile /var/run/redis/{{ redis_service }}.pid
      loglevel notice
      logfile {{ redis_log_file }}
      always-show-logo no
      dbfilename dump.rdb
      dir {{ redis_db_dir }}/
```

# License

```
Copyright (c) 2016 Tomoyuki Sakurai <y@trombik.org>

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
