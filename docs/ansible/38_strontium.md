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

Ansible-käyttäjän luominen koneen luomisen yhteydessä on näppärä tapa automatisoida inhat vaiheet.

🚧 🚧 🚧 TODO 🚧 🚧 🚧

## Konfiguraatiotiedosto

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
```

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

🚧 🚧 🚧 TODO 🚧 🚧 🚧
