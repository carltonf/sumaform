include:
  - default.locale
  - default.update
  - default.minimal
  - default.pkgs
  - default.sshd
  {% if grains.get('reset_ids') | default(false, true) %}
  - default.ids
  {% endif %}
  {% if not grains.get('transactional', False) %}
  # Dependencies already satisfied by the images
  # https://build.opensuse.org/project/show/systemsmanagement:sumaform:images:microos
  - default.testsuite
  {% endif %}


{% if grains.get('swap_file_size', "0")|int() > 0 %}
file_swap:
  cmd.run:
    - name: |
        mkdir -p /var/swap
        truncate -s 0 /var/swap/swapfile
        chattr +C /var/swap/swapfile 2>/dev/null || true
        dd if=/dev/zero of=/var/swap/swapfile bs=1M count={{ grains["swap_file_size"] }}
        chmod 0600 /var/swap/swapfile
        mkswap /var/swap/swapfile
        chmod 0600 /var/swap/swapfile
        mkswap /var/swap/swapfile
    - creates: /var/swap/swapfile
  mount.swap:
    - name: /var/swap/swapfile
    - persist: true
    - require:
      - cmd: file_swap
{% endif %}

{% if grains['authorized_keys'] %}
authorized_keys:
  file.append:
    - name: /root/.ssh/authorized_keys
    - text:
{% for key in grains['authorized_keys'] %}
      - {{ key }}
{% endfor %}
    - makedirs: True
{% endif %}
