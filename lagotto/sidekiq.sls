sidekiq:
  service.running:
    - watch:
      - file: /etc/init/sidekiq.conf

/etc/init/sidekiq.conf:
  file.managed:
    - template: jinja
    - source: salt://lagotto/etc/init/sidekiq.conf
    - user: root
    - group: root
    - mode: 644
