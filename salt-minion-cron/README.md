# cronjob for salt-minion restart

An Ansible role that creates a cron job to restart the `salt-minion` service daily at 4:00 AM via `systemctl`.

## Requirements

- The target host must have `cron` (or `crond`) installed.
- `systemctl` must be available (systemd-based systems).

## Example Playbook

```yaml
- hosts: all
  become: true
  roles:
    - salt-minion-cron
```

## What it does

Creates the following cron entry:

```
0 4 * * * /bin/systemctl restart salt-minion >> /var/log/salt-minion-restart.log 2>&1
```

Restart output (stdout and stderr) is logged to `/var/log/salt-minion-restart.log`.
