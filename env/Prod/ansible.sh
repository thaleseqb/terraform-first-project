#!/bin/bash
cd /home/ubuntu
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
sudo python3 get-pip.py
sudo python3 -m pip install ansible
tee -a playbook.yml > /dev/null  << EOT
- hosts: localhost
  tasks:
    - name: Instalando o python3, virtualenv
      apt:
        pkg:
        - python3
        - virtualenv
        update_cache: yes
      become: yes
    - name: Git Clone
      ansible.builtin.git:
        repo: https://github.com/guilhermeonrails/clientes-leo-api.git
        dest: /home/ubuntu/tcc
        version: master
        force: yes
    - name: pip dependencies installation
      pip:
        virtualenv: /home/ubuntu/tcc/venv
        requirements: /home/ubuntu/tcc/requirements.txt
    - name: change the setting hosts
      lineinfile:
        path: /home/ubuntu/tcc/setup/settings.py
        regexp: 'ALLOWED_HOSTS'
        line: 'ALLOWED_HOSTS = ["*"]'
        backrefs: yes
    - name: updating pip, setuptools and wheel
      pip:
        virtualenv: /home/ubuntu/tcc/venv
        name:
          - pip
          - setuptools
          - wheel
        state: latest
    - name: database configuration
      shell: '. /home/ubuntu/tcc/venv/bin/activate; python /home/ubuntu/tcc/manage.py migrate'
    - name: gathering data
      shell: '. /home/ubuntu/tcc/venv/bin/activate; python /home/ubuntu/tcc/manage.py loaddata clientes.json'
    - name: server initialization
      shell: '. /home/ubuntu/tcc/venv/bin/activate; nohup python /home/ubuntu/tcc/manage.py runserver 0.0.0.0:8000 &'
EOT
ansible-playbook playbook.yml