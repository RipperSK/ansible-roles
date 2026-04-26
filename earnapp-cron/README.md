# cronjob for salt-minion restart

An Ansible role that creates a cron job to restart the `earnapp` service daily at 4:00 AM via `systemctl`.

## Requirements

- The target host must have `cron` (or `crond`) installed.
- `systemctl` must be available (systemd-based systems).

## Example Playbook

```yaml
- hosts: all
  become: true
  roles:
    - earnapp-cron
```

## What it does

Creates the following cron entry:

```
0 4 * * * /bin/systemctl restart earnapp > /dev/null 2>&1
```
