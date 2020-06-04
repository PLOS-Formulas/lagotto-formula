extend:
  nginx:
    service:
      - watch:
        - file: /etc/nginx/sites-available/lagotto.conf

/etc/nginx/sites-available/lagotto.conf:
  file.managed:
    - template: jinja
    - source: salt://lagotto/etc/nginx/lagotto.conf
