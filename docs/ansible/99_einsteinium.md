---
priority: 499
---

# 👨‍🔬 Einsteinium

## Tärpit

Ei tärppejä. Tehtävänannossa on vihjeitä.

## Tehtävät

!!! question "Tehtävä: Hostaa Linux Perusteet ja Skriptiohjelmointi"

    Luo Playbook, joka ajaa [gh:sourander/linux-perusteet](https://github.com/sourander/linux-perusteet) sekä [gh:sourander/skriptiohjelmointi](https://github.com/sourander/skriptiohjelmointi) -repositorioissa esitellyt Material for MkDocs sivustot Multipassin luomissa koneissa. Muista, että Inventory-tiedostossa nämä ovat lisättyinä **kummatkin** ryhmään `multipass`, ja **erikseen** ryhmiin `first` ja `second`.

    Työvaiheet voi tehdä esimerkiksi seuraavan rungon mukaisesti:

    ```yaml title="study_materials.yml"
    ---
    ######################
    # Play: Dependencies #
    ######################
    - name: Install dependencies
      hosts: multipass
      become: yes

      tasks: []  # Asenna ainakin acl ja python3-virtualenv

    ###############################
    # Play: Set global variables  #
    ###############################
    - name: Set Playbook level variables
      hosts: multipass
      tasks:
        - name: Set global variables
          ansible.builtin.set_fact:
            mkdocs_user: mkdocs
            www_group: www-data
            sites_directory: /var/www/html

    #####################
    # Play: MkDocs user #
    #####################
    - name: Create MkDocs user
      hosts: multipass
      become: yes

      tasks: []  # Muista lisätä www-data ryhmään

    ##############################
    # Play: Set up /var/www/html #
    ##############################

    - name: Set up www directory permissions
      hosts: first,second
      become: yes

      tasks: []

    ###############
    # Play: Clone #
    ###############

    - name: Cloning the repository to mkdocs user home
      hosts: first,second
      become: yes
      become_user: "{{ mkdocs_user }}"

      tasks: []

    ###################
    # Play: MkDocs    #
    ###################

    - name: Install and run Mkdocs Build
      hosts: first,second
      become: yes
      become_user: "{{ mkdocs_user }}"

      tasks: []

      vars:
        venv_dir: "/home/{{ mkdocs_user }}/.venv"
        venv_python: "{{ venv_dir }}/bin/python"

    ################
    # Play: Nginx  #
    ################

    - name: Install and start Nginx with default settings
      hosts: first,second
      become: yes

      tasks:
        - name: Install
          # implementoi
        - name: Ensure Nginx is started and enabled
          # implementoi
        - name: Print what is running and where
          ansible.builtin.debug:
            msg: "{{ repo_name }} is running at http://{{ inventory_hostname }}/"
    ...
    ```

    Alla skriptin ajamisesta seulotut tärkeät osat:

    ```
    PLAY [Install dependencies]
    TASK [Gathering Facts]
    TASK [Install ACL package (for become_user)]
    TASK [Python virtualenv]

    PLAY [Set Playbook level variables]
    TASK [Set global variables]

    PLAY [Create MkDocs user]
    TASK [Create mkdocs user]
    TASK [Create Ansible temporary directory for mkdocs user]

    PLAY [Set up www directory permissions]
    TASK [Ensure www directory exists with proper permissions]

    PLAY [Cloning the repository to mkdocs user home]
    TASK [Clone the repository]

    PLAY [Install and run Mkdocs Build]
    TASK [Install pip dependencies]
    TASK [Build the site to the destination]

    PLAY [Install and start Nginx with default settings]
    TASK [Install]
    TASK [Ensure Nginx is started and enabled]
    TASK [Print what is running and where]
        "linux-perusteet is running at http://192.168.64.71/"
        "skriptiohjelmointi is running at http://192.168.64.70/"

    PLAY RECAP ***********************************
    192.168.64.70              : ok=13   changed=9 
    192.168.64.71              : ok=13   changed=9
    ```

    !!! tip "Vinkki: Group Vars"

        Muuttujat `repo_name` ja `repo_url` on näppärää sijoittaa erilliseen tiedostoon, josta Ansible osaa ne automaattisesti noutaa, kunhan hosts on määritelty muotoon `hosts: first,second`. Tarvitset YAML-tiedostoja kaksi: `first.yml` ja `second.yml`, ja niiden tulee olla hakemistossa `group_vars/`. Huomaa, että tuo polku on relatiivinen playbookin sijaintiin, ei hakemistoon, jossa ajat Ansiblea. Alla ensimmäisen näistä sisältö:

        ```yaml title="group_vars/first.yml"
        repo_name: linux-perusteet
        repo_url: https://github.com/sourander/linux-perusteet.git
        ```

    !!! tip "Vinkki: Ajettava komento"

        Komento, joka varsinaisesti rakentaa sivuston, on `mkdocs build`. Kokonaisuutena komento on:

        ```console
        # Jinja:
        # {{ venv_python }} -m mkdocs build -d {{ sites_directory }}

        # Eli:
        $ /home/mkdocs/.venv/bin/python -m mkdocs build -d /var/www/html
        ```

        Huomaa, että komento tulee ajaa oikeassa hakemistossa, eli `~/linux-perusteet` tai `~/skriptiohjelmointi`.

    !!! tip "Vinkki: Tarvittavat pip-paketit"

        Tarvitset paketit `mkdocs-material` ja `mkdocs-awesome-nav`. Nämä voisi nuuhkia `pyprojects.toml`-tiedostosta, mutta helpoimmalla pääset kun rautakoodaat ne.