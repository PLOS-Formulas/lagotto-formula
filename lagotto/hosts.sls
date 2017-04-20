{% if salt['grains.get']('location') == 'soma' -%}
include:
  - common.hosts

extend:
  global-etc-hosts:
    file.managed:
      - context:
          hosts_present:
            # this is a workaround until ops sets up DNS in Soma to 
            # resolve ".plos.org"
            {% if salt['grains.get']('environment') == 'stage' %}
            - ip_address: 10.5.3.178
              hostnames: ['nedcas-stage.plos.org']
            {% endif %}

{% endif -%}
