include:
  - common.packages
  - common.repos

lagotto:
    group:
      - present
      - gid: {{ salt.pillar.get('uids:lagotto:gid') }}
    user:
      - present
      - uid: {{ salt.pillar.get('uids:lagotto:uid') }}
      - gid: {{ salt.pillar.get('uids:lagotto:gid') }}
      - gid_from_name: true
      - createhome: true
      - shell: /bin/bash
      - require:
        - group: lagotto
