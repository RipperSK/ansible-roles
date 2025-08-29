Role Name
=========

Role to install postgres server to /storage/pgdata data directory.

Requirements
------------

Working internet connection to official postgresql REPO

Role Variables
--------------

pg_vers variable:
  defines posgres version.
  accepted values:
    * '9.6'
    * '10'
    * '11'
    * '12'
    * '13'

Example Playbook
----------------

---
- hosts: all
  become: true
  vars:
    - pg_vers: '11'
  roles:
    - postgres


License
-------

MIT

Author Information
------------------

Roman Spiak - roman.spiak@zsdis.sk
1st version on 2021-01-11
