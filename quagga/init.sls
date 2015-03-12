{% from "quagga/map.jinja" import map with context %}                                                                                                           


{% set bgpd = pillar.get('quagga:bgpd', None) %}
{% set ripd = pillar.get('quagga:ripd', None) %}
{% set zebra = pillar.get('quagga:zebra', None) %}

quagga_packages:                                                                                                                                                
  pkg.installed:                                                                                                                                                   
    - pkgs:                                                                                                                                                        
      {% for pkg in map.pkgs %}                                                                                                                                    
      - {{ pkg }}                                                                                                                                                  
      {% endfor %}                         

quagga_daemons:
  file.managed:
    - name: {{ map.confdir }}/daemons
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - source:   salt://quagga/files/daemons.jinja
    - context:
      bgpd:  {{ bgpd }}
      ripd:  {{ ripd }}

{% if ripd is defined %}
quagga_ripdconf:
  file.managed:
    - name: /etc/quagga/ripd.conf
    - user: quagga
    - group: quaggavty
    - mode: 644
    - template: jinja
    - source:   salt://quagga/files/ripd.conf.jinja
    - context:
      ripd:  {{ ripd }}
      logdir: {{ map.logdir }}
{% endif %}

{% if bgpd is defined %}
quagga_bgpdconf:
  file.managed:
    - name: {{ map.confdir }}/bgpd.conf
    - user: quagga
    - group: quaggavty
    - mode: 644
    - template: jinja
    - source:   salt://quagga/files/bgpd.conf.jinja
    - context:
      bgpd:  {{ bgpd }}
      logdir: {{ map.logdir }}

# this should not be done here.
# maybe introduce a resourceservice pillar that disables
# services that are run als cluster resource...
# quagga_service:
#   service.disabled:
#     - name: quagga

{% endif %}

{% if zebra is defined %}
quagga_zebraconf:
  file.managed:
    - name: {{ map.confdir }}/zebra.conf
    - user: quagga
    - group: quaggavty
    - mode: 644
    - template: jinja
    - source:   salt://quagga/files/zebra.conf.jinja
    - context:
      ripd:  {{ ripd }}
{% endif %}

{% if map.debian  %}
quagga_debianconf:
  file.managed:
    - name: {{map.confdir}}/debian.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - source:   salt://quagga/files/debian.conf.jinja
    - context:
{% endif %}

