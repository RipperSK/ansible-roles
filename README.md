# ansible-roles
Collection of ansible roles with minimalistic config or customization.
Many of these were not available on ansible galaxy at the time of writing but I believe are now available 
and (probably) in better quality than these :)

# how to use
To use any of these roles - create a playbook where role is being called like so:
```
---
- hosts: all
  become: true
  roles:
    - mariadb
```

# contrib
I'd recomend to contribute to Ansible Galaxy roles or Collections
But if you cannot help yourself - open a PR :)
