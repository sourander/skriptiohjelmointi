---
priority: 438
---

# 🎆 Strontium

Edellisessä luvussa varmasti huomasit, että Ansible-komennoista kasvoi melko pitkiä. Lisäksi viimeisiin komentoihin jäi jonkin verran käsin tehtävää, kuten IP-osoitteiden täydennys. Strontium-luvussa keskitymme tekemään Ansiblesta siinä mielessä käytettävän, että komennot ovat jatkossa lyhyitä.

## Ansible-käyttäjä

Kuvitellaan, että meillä on ohjattavana myös muita distribuutioita kuin kaksi Multipassilla ajettavaa Ubuntua. Olisi huomattavan näppärää, jos **kaikissa** koneissa olisi **aina** käyttäjä `ansible`, jonka avulla voimme tehdä muutoksia. Tämä onnistuu, kun käytämme Ansiblen `authorized_key`-moduulia.


### Ansible-käyttäjä käsin

Käyttäjän voi luoda kohtalaisen käsin käyttäen Multipassia ja Ansiblea. Alla esimerkki, jota sinun ei siis todellakaan tarvitse kirjoittaa, koska seuraavaksi automatisoimme tämän.

```bash
# Copy our public key to the remote hosts
multipass transfer ~/.ssh/id_ed25519.pub ansible-1:/tmp/id_ed25519.pub
multipass transfer ~/.ssh/id_ed25519.pub ansible-2:/tmp/id_ed25519.pub

# Append the public key to authorized_keys in /home/ubuntu/.ssh
multipass exec ansible-1 -- bash -c "cat /tmp/id_ed25519.pub >> ~/.ssh/authorized_keys"
multipass exec ansible-2 -- bash -c "cat /tmp/id_ed25519.pub >> ~/.ssh/authorized_keys"

# Disable SSH host key checking.
export ANSIBLE_HOST_KEY_CHECKING=False

# Create ansible user
uv run ansible \
--inventory config/inventory/hosts.ini multipass \
--module-name ansible.builtin.user \
--args "name=ansible create_home=yes groups=sudo append=yes" \
--user ubuntu --become

# Create the .ssh directory
uv run ansible \
-i config/inventory/hosts.ini multipass \
-m ansible.builtin.file \
-a "path=/home/ansible/.ssh state=directory owner=ansible group=ansible mode=0700" \
-u ubuntu -b

# Copy the public key to the authorized_keys file
uv run ansible -i config/inventory/hosts.ini multipass \
-m ansible.builtin.copy \
-a "src=~/.ssh/id_ed25519.pub dest=/home/ansible/.ssh/authorized_keys owner=ansible group=ansible mode=0600" \
-u ubuntu -b

# NOW you could run commands as the ansible user! 🎉
uv run ansible -i config/inventory/hosts.ini multipass \
-m debug \
-a "msg='Hello world!'" \
-u ansible
```

Yksittäinen komento yltä selitettynä auki. Tätä ymmärtääksesi sinun tulisi lukea [Ansible Community Docs: ansible](https://docs.ansible.com/ansible/latest/cli/ansible.html)-binäärin optioneiden kuvaukset. Selitys parametreille järjestyksessä vasemmalta oikealle:

| Parametri                           | Selitys                                                      |
| ----------------------------------- | ------------------------------------------------------------ |
| `uv run ansible`                    | Ansible Core                                                 |
| `-i <path>`, `--inventory <path>`   | Inventory-tiedoston polku                                    |
| `multipass`                         | Group `multipass`, jonka hosteihin tehdään muutoksia         |
| `-m <FQDN>`, `--module-name <FQDN>` | Moduuli. Esimerkiksi `user` collectionista `ansible.builtin` |
| `-a "..."`                          | Argumentit moduulille                                        |
| `-u ubuntu`, `--user <username>`    | Käyttäjä, jolla ajetaan                                      |
| `-b`, `--become`                    | Käytä sudoa                                                  |

Seuraavia kahta parametriä emme tarvitse tämän virtuaalikoneen kanssa, koska käyttäjällä `ubuntu` ei ole salasanaa, mutta ne on hyvä tuntea, koska niitä tarvitaan usein. Näin voi olla, jos esimerkiksi teet VMwareen virtuaalikoneen ja haluat konfiguroida sen Ansiblella.

| Parametri                 | Selitys                                                               |
| ------------------------- | --------------------------------------------------------------------- |
| `-k`, `--ask-pass`        | Kysy käyttäjän (ubuntu) salasanaa SSH-avaintunnistuksen sijasta.      |
| `-K`, `--ask-become-pass` | Kysy sudo-salasanaa interaktiivisesti kun jokin sudo-komento ajetaan. |

### Ansible-käyttäjä Cloud-initilla

Ansible-käyttäjän luominen koneen luomisen yhteydessä on näppärä tapa automatisoida inhat vaiheet. Tämä onnistuu Cloud-Initillä, joka on pilvipalveluissa yleisesti käytetty tapa konfiguroida virtuaalikoneita luomisen tai käynnistymisen yhteydessä.

Jos kurkkaat [multipass launch](https://canonical.com/multipass/docs/launch-command)-komennon dokumentaatiota, huomaat, että sille voi antaa `--cloud-init <file> | <url>` optionin. Tämä tarkoittaa, että voimme luoda Cloud-Init -tiedoston, joka sisältää Ansiblen käyttäjän luomisen.

```yaml
#cloud-config
ssh_pwauth: false
users:
- name: ansible
  gecos: Ansible User
  groups: users,admin,wheel
  sudo: ALL=(ALL) NOPASSWD:ALL
  shell: /bin/bash
  lock_passwd: true
  create_home: true
  ssh_authorized_keys:
    - "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGK9z+oj4VYSpW7K/k0MJKFYuZFw68sDTrw8NGToyM41"
```

Tämän jälkeen sinun tulee lisätä kyseinen tiedosto `multipass launch`-komennon `--cloud-init`-parametrin perään. Muokkaa sinun `create-vms.sh`-tiedostoa.

!!! warning

    HUOM! Ensimmäisen rivin `#cloud-config` on oltava ensimmäinen rivi tiedostossa. Muutoin Cloud-Init ei tunnista tiedostoa omakseen.

## Komennon lyhentäminen

### Konfiguraatiotiedosto

Ansiblen `ansible.cfg`-tiedostoon voi kirjoittaa asetuksia, jotka ovat voimassa kaikille Ansible-komennoille. Tämän avulla voimme ratkaista monta aiemmin vastaan tullutta ongelmaa, kuten sen, että `--inventory`-parametri on aina kirjoitettava.

Ansible etsii tiedostoa seuraavassa järjestyksessä, kuten [Ansible Community Docs: Ansible Configuration Settings](https://docs.ansible.com/ansible/latest/reference_appendices/config.html) kertoo:

1. `ANSIBLE_CONFIG` (ympäristömuuttuja)
2. `ansible.cfg` (cwd)
3. `~/.ansible.cfg` (kotikansion juuressa)
4. `/etc/ansible/ansible.cfg` (globaali)

Voit luoda kommentoidun esimerkkitiedoston seuraavalla komennolla:

```bash
uv run ansible-config init --disabled > ansible.cfg
```

Tiedosto on todella *verbose*, joten luomme sen sijaan käsin omamme:

```ini
[defaults]
inventory = config/inventory/hosts.ini
remote_user = ansible
host_key_checking = False
```

### Kokeile vaikka

Olettaen että sinun `ansible.cfg`-tiedosto on kunnossa ja Cloud-init on ajettu onnistuneesti, voit ajaa ==ad-hoc komentoja== Ansiblen avulla hyvinkin helposti. Tämä on näppärää ja poistaa tarpeen ottaa käsin SSH-yhteyksiä (tai ParalellelSSH:n tai `multipass exec` kautta). Jos termi *ad-hoc* on vieras, sillä tarkoitetaan IT-maailmassa tilapäistä tai kertaluonteista käskyä tai ratkaisua.

!!! quote

    **ad hoc** tapauskohtainen t. tapauskohtaisesti, yhteen tarkoitukseen soveltuva(sti) ¶ Periaatteessa sitaattilaina latinasta, merkitykseltään 'tätä varten', mutta käytetään tavallisemmin määritteenä, esim. "ad hoc -ratkaisu". Usein sävyltään lievästi paheksuva; taustalla voi olla ajatus, että olisi pitänyt löytää tai kehittää yleinen ratkaisu mutta tehtiinkin jokin "viritelmä" joka sopii vain yhteen tilanteeseen eikä siihenkään ehkä luotettavasti.

    Lähde: [Jukka Korpelan pienehköstä sanakirja](https://jkorpela.fi/siv/sanata.html)

Mikäli `ansible.cfg`-tiedosto on kunnossa ja vakiokäyttäjä ansible on olemassa avaimineen, niin voit ajaa seuraavanlaisia komentoja:

```bash
# Syntaksi
# uv run ansible <group> -m <module> -a "<args>"

# Yksi tietty moduuli
$ uv run ansible all -m ping

# Yksi tietty moduuli attribuutteineen
$ uv run ansible all -m file -a "path=/home/ansible/kissa.txt state=touch"
$ uv run ansible all -m find -a "paths=/home/ansible patterns=*.txt"

# Vakiomoduuli on command
$ uv run ansible all -a "df -h"

# Jos haluat ajaa komennon sudo-oikeuksilla
$ uv run ansible all -a "cat /etc/shadow" --become

# Tarvitsemme Shell-moduulin, jos haluamme käyttää putkia
$ uv run ansible all -m shell -a "cat /etc/shadow | grep -i ansible" --become
```

Kuten jo yllä esitellystä määritelmästä voi arvata, tämä ratkaisu on väliaikainen. Pysyvämpiä ratkaisuja varten kannattaa käyttää Playbookeja, joihin palaamme kurssin seuraavassa luvussa.


### Requirements

Riippuvuuksia varten voi luoda oman `requirements.yml`-tiedoston, joka sisältää kaikki tarvittavat moduulit. Tämä on hyödyllistä, jos haluat jakaa projektisi muiden kanssa. Tiedosto on käyttötarkoitukseltaan vastaava kuin `pyproject.toml`-tiedoston `dependencies`-lista.

```yaml
---
collections:
  - ansible.posix
```

Kaikki kyseisessä tiedostossa olevat riippuvuudet voi asentaa, kuten [Ansible Community Docs: Install multiple collections with a requirements file](https://docs.ansible.com/ansible/latest/collections_guide/collections_installing.html#install-multiple-collections-with-a-requirements-file) ohje neuvoo, komennolla:

```console
$ uv run ansible-galaxy collection install -r requirements.yml
```

## Tehtävät

!!! question "Tehtävä: Lisää Cloud-Init"

    Tämä vaihe on simppeli ja siihen löytyy ohjeet yltä. Vaiheet:

    1. Luo Cloud-Init -tiedosto, joka luo `ansible`-käyttäjän virtuaalikoneisiin.
    2. Lisää tiedosto `create-vms.sh`-skriptiin.

    Hakemistorakenteesi tulisi näyttää jotakuinkin tältä:

    ```plaintext
    ansible
    ├── ansible.cfg
    ├── config
    │   ├── cloud-init
    │   │   └── ansible.yml
    │   ├── inventory
    │   │   └── hosts.ini
    │   └── playbooks
    │       └── hello-world.yml
    ├── pyproject.toml
    ├── scripts
    │   ├── create-vms.sh
    │   ├── destroy-vms.sh
    │   └── multipass-to-inv.py
    └── uv.lock
    ```

!!! question "Tehtävä: Luo Ansible config"

    Luo yllä neuvottu `ansible.cfg`-tiedosto ja tarkista, että kokonaisuus toimii. Sinun tulisi voida ajaa seuraavanlaiset komennot `ansible/`-hakemistossa:

    ```console
    $ ./scripts/create-vms.sh
    Launched: ansible-1
    Launched: ansible-2
    [INFO] Adding 192.168.64.49 to inventory
    [INFO] Adding 192.168.64.48 to inventory
    [INFO] Inventory written to config/inventory/hosts.ini

    $ uv run ansible all -m ping
    192.168.64.53 | SUCCESS => {
        ...
    }
    192.168.64.52 | SUCCESS => {
        ...
    }

    $ uv run ansible multipass -a "df -h"
    192.168.64.53 | CHANGED | rc=0 >>
    Filesystem      Size  Used Avail Use% Mounted on
    tmpfs            96M  1.2M   95M   2% /run
    /dev/sda1       3.9G  1.9G  2.0G  50% /
    ...
    
    192.168.64.52 | CHANGED | rc=0 >>
    Filesystem      Size  Used Avail Use% Mounted on
    tmpfs            96M  1.2M   95M   2% /run
    /dev/sda1       3.9G  1.9G  2.0G  50% /
    ...
    ```