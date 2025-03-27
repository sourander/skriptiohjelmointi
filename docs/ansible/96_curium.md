---
priority: 496
---

# 👩‍🔬 Curium

## Tärpit

### Faktat

Ansible suorittaa Play-vaiheita edeltävän Fact Gathering prosessin, jossa se noutaa muuttujiin arvoja koneelta. Voit tarkastella JSON-muotoista *raakamuotoa* näin:

```console
$ uv run ansible 192.168.64.62 -m ansible.builtin.setup
```

Playbookeissa näitä arvoja voi käyttää simppelisti jommalla kummalla alla näkyvistä tavoista. Huomaa, että `ansible_facts` dictionaryn arvot ovat saatavilla myös globaaleiksi muuttujiksi injektoituina. Niiden etuliitteenä on `ansible_`. Lisäksi löytyy nippu `magic`-muuttujia, kuten `inventory_hostname` tai `group_names`. Nämä ovat varattuja sanoja (engl. reserved), jotka eivät ole `ansible_facts` -dictionaryssä. Et voi ylikirjoittaa niiden sisältöä.

```yaml title="playbook_facts.yml"
---
- name: Gather facts
  hosts: localhost
  tasks:
    - name: Print processor architecture (injected)
      ansible.builtin.debug:
        msg: "Processor architecture is {{ ansible_processor }}"

    - name: Print processor architecture (from dictionary)
      ansible.builtin.debug:
        msg: "Processor architecture is {{ ansible_facts['processor'] }}"
...
```

### Muuttujat

Yllä mainitut faktat ovat jo itsesään muuttujia, mutta voit määritellä niitä itse lisää. Muuttujat voivat olla tyyppiä string, boolean, list tai dictionary. Playbookin sisällä tämän joko Play- tai Task-tasolla, mutta yhteensä eri tapoja määritellä muuttujia on kymmeniä, mukaan lukien erilliset `vars_files`:t, `--extra-vars` CLI optionit ja **Ansible Vault**-säilön. Jos pysytään kuitenkin Play- ja Task-tasolla, niin alla näkyvät kummatkin:

```yaml title="playbook_variables.yml"
---
- name: This is my play
  hosts: localhost
  vars:
    play_level1: "aaa"
    play_level2: 123
    play_level3:
        - "Hello"
        - "World!"
  tasks: 
    - name: This is my task
      vars:
        task_level1: "ccc"
        task_level2: 456
        task_level3:
            goodbye: "Goodbye"
            world: "World!"
      debug:
        msg: |
            From task: {{ task_level1 }} and {{ task_level2 }} and {{ task_level3 }}
            From play: {{ play_level1 }} and {{ play_level2 }} and {{ play_level3 }}
...
```

Huomaat, että Playbookin ajaminen tuottaa seuraavan tulosteen:

```
TASK [This is my task] **********************
ok: [localhost] => {
    "msg": "From task: ccc and 456 and {'goodbye': 'Goodbye', 'world': 'World!'}\nFrom play: aaa and 123 and ['Hello', 'World!']\n"
}
```

### Galaxy

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

## Tehtävät

??? question "Tehtävä: Nginx"

    Luo playbook, `configs/playbooks/nginx.yml`, joka asentaa Nginxin ja käynnistää sen. Käytä vain ja ainoastaan `ansible.builtin` collectionista löytyviä moduuleita. Kenties `ansible.builtin.package` ja/tai `ansible.builtin.apt` ratkaisee ongelman? Jos kumpikin toimii, missä tilanteessa suosisit toista? Mitä mahtaa apt:n parametri `update_cache` tehdä, ja löytyykö sille vastaine `package`-moduulista?
    
    Tarvitset kaksi play:tä, jotka voivat olla nimeltään esimerkiksi:

    * `- name: Install nginx`
    * `- name: Ensure Nginx is running and enabled`

    Tarkista, että saat **Welcome to nginx!** -sivun auki selaimessa kummastakin IP-osoitteesta.

??? question "Tehtävä: Nginx idempotenssi"

    Aja yllä oleva skripti uusiksi ja tarkkaile, kuinka se käyttäytyy. Pohdi erityisesti, mikä numerot n ja m ovat seuraavassa, ja miten ne eroavat ensimmäisestä ajokerrasta:

    ```
    PLAY RECAP ******************************************************* ...
    192.168.xx.xx              : ok=n    changed=m    unreachable=0    ...
    192.168.xx.xx              : ok=n    changed=m    unreachable=0    ...
    ```

    Varmista, että osaat jatkossa selittää, mitä *idempotentti* tarkoittaa Ansiblessa - tai ylipäätänsä tietojenkäsittelyn kontekstissa. Apua saat vaikkapa [Wikipediasta](https://fi.wikipedia.org/wiki/Idempotenssi).

??? question "Tehtävä: Nginx poisto"

    Luo **Playbook**, `configs/playbooks/nginx-remove.yml`, joka poistaa edellisen **Playbookin** asentaman **nginx**:n. Jos **nginx**:ää ei ole asennettuna, skripti ei saa antaa virheilmoitusta! Kyllä, sen pitää olla *idempotentti*.

    Sinun tulisi tarvita vain yksi Play, esimerkiksi:

    * `- name: Remove Nginx package and its configuration`

    !!! tip
    
        Käytä `purge`-parametria, jotta kaikki asetustiedostot poistetaan.

    !!! tip

        Muista, että voit koska tahansa ottaa `multipass shell` -komennolla yhteyden koneeseen, jos haluat tutkia sen tilaa manuaalisesti.


??? question "Tehtävä: Nginx with Hello World"

    Tee Playbook, `configs/playbooks/nginx-hello.yml`, joka asentaa Nginxin ja luo sille yksinkertaisen *Hello World* -sivun. Jos tutkit aiemman tehvätän tilassa olevaa palvelinta, huomaat, että `/etc/nginx/sites-available/default` tiedostossa määritellään default endpoint `/var/www/html`. Tämä on siis se hakemisto, johon sivut tulisi asentaa.

    ```nginx title="/etc/nginx/sites-available/default"
    server {
        listen 80 default_server;
        listen [::]:80 default_server;
        root /var/www/html;
        index index.html index.htm index.nginx-debian.html;
        # ...
    }
    ```

    Tämä tarkoittaa, että voimme vaihtaa etusivua siten, että kirjoitamme `index.htm[l]` -tiedoston `/var/www/html` -hakemistoon. Päätetään samalla, että hakemiston ei tulisi olla `root:root` omistuksessa, vaan `www-data:www-data`. Syy on se, että jatkossa voimme pyörittää esimerkiksi staattista sivugeneraattoria käyttäjällä www-data, jolloin se voi kirjoittaa hakemistoon ja sen tiedostoihin. Hakemiston omistajuuden tulisi olla `755` (`drwxr-xr-x`) ja tiedoston `644` (`-rw-r--r--`).
    
    Playbookin pitäisi siis tehdä seuraavat askeleet, joista kaksi ensimmäistä olet jo kerran tehnyt:

    * ✅ Asenna Nginx (tuttu)
    * ✅ Käynnistä Nginx (tuttu)
    * 📂 Luo `/var/www/html` -hakemisto
        * Omistajaksi: www-data
        * Oikeudet: 755
    * 🌐 Luo `/var/www/html/index.html` -tiedosto
        * Sama omistaja kuin hakemistolla
        * Oikeudet: 644

    Saat päättää HTML-tiedoston sisällön itse, kuten myös tavan, kuinka sen kirjoitat. Kenties haluat käyttää `ansible.builtin.copy` -moduulia ja määrittää sisällön YAML:n sisällä content-kentässä? Tai ehkä haluat käyttää `template` -moduulia ja noutaa tiedoston sisällön erillisestä tiedostosta? Valinta on sinun. Tiedoston sisällöksi riittää mikä tahansa simppeli HTML-dokumentti. Jos et osaa HTML-kieltä, käytä pohjana vaikkapa [W3Schoolsin esimerkkiä](https://www.w3schools.com/html/html_basic.asp).

    ??? tip "Template?"

        Jos haluat käyttää templatea, tässä on vihje:

        ```
          - name: Create Index from Template
            ansible.builtin.template:
                src: ../templates/index.html.j2
                dest: TODO
                owner: TODO
                group: TODO
                mode: TODO
            vars:
                site_title: "Hello from Template!"
                computer_name: "{{ ansible_hostname }}"
        ```

        Yllä esitelty `ansible_hostname` on Ansiblen [Special Variable](https://docs.ansible.com/ansible/latest/reference_appendices/special_variables.html), joka pengotaan koneesta Fact Gathering -vaiheessa. Näin ensimmäisen koneen ip vastaisi:

        ```
        Hello World!
        I am ansible-1`
        ```

        Ja toisen:

        ```
        Hello World!
        I am ansible-2`
        ```

??? question "Tehtävä: Ufw from Galaxy"

    Luo yksinkertainen Playbook, jossa:

    * Varmistat, että `ufw` on asennettu
    * Lisää seuraavat säännöt:
        * Default policy, joka kieltää kaiken liikenteen
        * Salli SSH
        * Salli HTTP
    * Varmista, että `ufw` on enabled

    Käytä tehtävässä `community.general.ufw` moduulia. Selvitä, kuinka asennat sen, ja mistä sen ohjeet löytyvät.

    Voit tarkistaa, että säännöt ovat voimassa komennolla:

    ```console
    # Ansible
    $ uv run ansible all -a "ufw status" --become
    
    # Multipass (jos suljet SSH-portin vahingossa)
    $ multipass exec ansible-1 -- sudo ufw status
    $ multipass exec ansible-2 -- sudo ufw status
    ```

