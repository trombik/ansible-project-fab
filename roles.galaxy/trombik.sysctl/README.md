# ansible-role-sysctl

Set sysctl.

# Requirements

None

# Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `sysctl_conf` | path to `sysctl.conf(5)` | `{{ __sysctl_conf }}` |
| `sysctl_bin` | path to `sysctl(8)` | `{{ __sysctl_bin }}` |
| `sysctl` | dict contains sysctl key as key, sysctl value as value | `{}` |

## Debian

| Variable | Default |
|----------|---------|
| `__sysctl_conf` | `/etc/sysctl.conf` |
| `__sysctl_bin` | `/sbin/sysctl` |

## FreeBSD

| Variable | Default |
|----------|---------|
| `__sysctl_conf` | `/etc/sysctl.conf` |
| `__sysctl_bin` | `/sbin/sysctl` |

## OpenBSD

| Variable | Default |
|----------|---------|
| `__sysctl_conf` | `/etc/sysctl.conf` |
| `__sysctl_bin` | `/sbin/sysctl` |

## RedHat

| Variable | Default |
|----------|---------|
| `__sysctl_conf` | `/etc/sysctl.d/99-sysctl.conf` |
| `__sysctl_bin` | `/sbin/sysctl` |

# Dependencies

None

# Example Playbook

```yaml
- hosts: localhost
  roles:
    - ansible-role-sysctl
  vars:
    sysctl:
      net.inet.ip.forwarding: 1
      kern.maxfiles: 20000
```

# License

```
Copyright (c) 2016 Tomoyuki Sakurai <tomoyukis@reallyenglish.com>

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

Tomoyuki Sakurai <tomoyukis@reallyenglish.com>

This README was created by [ansible-role-init](https://gist.github.com/trombik/d01e280f02c78618429e334d8e4995c0)
