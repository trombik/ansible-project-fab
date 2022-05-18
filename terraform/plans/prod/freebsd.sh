#!/bin/sh
EC2_SUDOERS_FILE=/usr/local/etc/sudoers.d/ec2-user

ASSUME_ALWAYS_YES=yes pkg install pkg python3 curl sudo

touch "${EC2_SUDOERS_FILE}"
chmod 440 "${EC2_SUDOERS_FILE}"

cat <<EOF > "${EC2_SUDOERS_FILE}"
Defaults:ec2-user !requiretty
ec2-user ALL=(ALL) NOPASSWD: ALL
root ALL=(ALL) NOPASSWD: ALL
EOF

cat <<EOF > /etc/boot.conf
set timeout 1
EOF

# XXX add ec2-user to ansible, which is intended to be used as
# `common_remote_group` for `defaults` option in ansible.cfg.
# all unix users who runs ansible, and `become_user`,  need to be in this
# group to make `become` possible without POSIX ACLs support in file system.
#
# see:
# https://docs.ansible.com/ansible/latest/user_guide/become.html
pw useradd ec2-user -m -G wheel
pw groupadd -n ansible -M ec2-user
