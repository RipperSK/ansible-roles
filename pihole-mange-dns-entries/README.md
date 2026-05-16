# pihole-manage-dns-entries

Deploys a managed `pihole.toml` to Pi-hole v6 hosts and restarts `pihole-FTL`.
Validates the TOML before deploying using `validtoml`.

## Requirements

- Pi-hole v6 on target hosts
- `validtoml` binary committed to `files/validtoml` (pre-built for the target arch)
- validtoml is taken from https://github.com/martinlindhe/validtoml

## Role Variables

None. The DNS records are managed directly in `files/pihole.toml`.

## Usage

Edit `files/pihole.toml`, then run the playbook. The role will:
1. Install `validtoml` to `/usr/local/bin/`
2. Copy `pihole.toml` to `/tmp/` and validate it
3. Deploy to `/etc/pihole/pihole.toml` (with backup)
4. Restart `pihole-FTL`

```yaml
- hosts: pihole
  roles:
    - pihole-manage-dns-entries
```

## License

MIT-0
