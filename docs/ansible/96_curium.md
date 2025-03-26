---
priority: 496
---

# 👩‍🔬 Curium

## Galaxy

Jos teet jotakin, mitä tavallisesti tehdään usein, sille löytyy todennäköisesti moduuli. Hyvä esimerkki tästä on SSH-avaimen lisääminen `authorized_keys`-tiedostoon. Tämä on niin yleinen toimenpide, että Ansiblella on sille oma moduuli, jota olisimme voineet käyttää aiemmin. Moduuli on FQDN:tään [ansible.posix.authorized_key](https://docs.ansible.com/ansible/latest/collections/ansible/posix/authorized_key_module.html). Se asennettaisiin seuraavasti:

```console
$ uv run ansible-galaxy collection install ansible.posix
Starting galaxy collection install process
Process install dependency map
Starting collection install process
Downloading https://galaxy.ansible.com/api/v3/.../artifacts/ansible-posix-2.0.0.tar.gz to /home/me/.ansible/tmp/.../tmp_vdehsjm/ansible-posix-2.0.0-43kkw7ue
Installing 'ansible.posix:2.0.0' to '/home/me/.ansible/collections/ansible_collections/ansible/posix'
ansible.posix:2.0.0 was installed successfully
```

Jos tämän kurssin tehtävät ohjaavat sinua käyttämään moduulia jostakin muusta `namespace.collection`-osoitteesta kuin `ansible.builtin`, voit asentaa sen samalla tavalla.

```console
$ uv run ansible-galaxy collection install <namespace>.<collection>
```
