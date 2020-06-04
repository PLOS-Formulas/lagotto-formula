{% set distro = salt.grains.get('oscodename') %}
sidekiq:
  service.running:
    - watch:
      {% if distro == 'trusty' %}
      - file: /etc/init/sidekiq.conf
      {% else %}
      - file: /etc/systemd/system/sidekiq.service
      {% endif %}

{% if distro == 'trusty' %}
/etc/init/sidekiq.conf:
  file.managed:
    - template: jinja
    - source: salt://lagotto/etc/init/sidekiq.conf
    - user: root
    - group: root
    - mode: 644
{% else %}
/etc/systemd/system/sidekiq.service:
  file.managed:
    - template: jinja
    - source: salt://lagotto/etc/systemd/system/sidekiq.service
{% endif %}
