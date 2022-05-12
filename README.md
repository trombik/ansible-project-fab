# `ansible-project-fab`

A project to maintain `fab.mkrsgh.org`.

The project deploys [fab-manager](https://github.com/sleede/fab-manager) on
AWS EC2.

`terraform` is used to manage AWS resources.

`ansible` is used to manage the `fab-manager` instance.

Tests are provided to ensure the system is working.

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

```console
export PROJECT_ENVIRONMENT=virtualbox
```

Set `PROJECT_ENVIRONMENT` (optional, defaults to `virtualbox`).

## `PROJECT_ENVIRONMENT`

See available `PROJECT_ENVIRONMENT` in [inventories](inventories).

### `virtualbox`

The default environment when `PROJECT_ENVIRONMENT` is not defined.

This environment creates VMs in `virtualbox`. See [Vagrantfile](Vagrantfile)
for details.

### `staging`

A non-production environment on AWS EC2. See
[terraform/plans/staging](terraform/plans/staging) for details.

Make sure your `~/.ssh/config` has necessary configuration options for EC2
instances.

```ssh-config
Host *.amazonaws.com
    User ec2-user
    IdentityFile ~/.ssh/mykey-ed.pem
    ControlMaster auto
    ControlPersist 30m
    ControlPath ~/.ssh/control-%C
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

### Destroying VMs

```console
bundle exec rake destroy
```

## The application

In `virtualbox` environment, the URL is
[http://192.168.56.100/](http://192.168.56.100/).

For the admin account, see
[virtualbox_credentials.yml](playbooks/group_vars/virtualbox_credentials.yml).
