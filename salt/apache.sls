install_apache:
  pkg.installed:
    - name: apache2
make sure apache is running:
  service.running:
    - name: apache2
    - enable: True
