# `ansible-project-fab`

A project to maintain `fab.mkrsgh.org`.

## Requirements

* `ruby` 2.x
* `python` 3.x
* `vagrant`
* `tox`
* `awscli`
* `terraform`

## Setting up

Install python modules, including `ansible`.

```console
tox
```

Activate `tox` environment.

```console
source ./.tox/default/bin/activate
```

Set `PROJECT_ENVIRONMENT` (optional, defaults to `virtualbox`).

```console
export PROJECT_ENVIRONMENT=virtualbox
```

## Usage

[Rakefile](Rakefile) implements wrappers for all the environment. See `bundle
exec rake -T` for all the targets.

### Launching VMs

```console
bundle exec rake up
```

### Provisioning VMs

```console
bundle exec rake provision
```

### Showing `ansible` inventory

```console
bundle exec rake show:inventory
```

### Testing

See [spec/serverspec](spec/serverspec) for tests.

```console
bundle exec rake spec:serverspec
```

## The application

In `virtualbox` environment, the URL is
[http://192.168.56.100/](http://192.168.56.100/).

For the admin account, see
[virtualbox-credentials.yml](playbooks/group_vars/virtualbox-credentials.yml).
