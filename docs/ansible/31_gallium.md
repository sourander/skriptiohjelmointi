---
priority: 431
---

# 💡 Gallium

Ansible-osuus eroaa Bash, PowerShell ja Python osuuksista siten, että valmista koodia tarjoillaan merkittävästi aiempaa vähemmän. Tämä osio on kurssin loppusilaus, jossa yhdistellään Bash ja Python -osuuksissa opittua Ansibleen. PowerShell hylätään toistaiseksi, koska Ansible Control Noden tulee olla Unix-pohjainen, ja Bash on valmiina saatavilla.

Gallium-osiossa tehdään minimum viable product. Tämä tehdään muutamassa vaiheessa.

| #   | Vaihe                | Työkalu         | Tavoite                                                 |
| --- | -------------------- | --------------- | ------------------------------------------------------- |
| 1   | venv                 | uv + Python     | Eristetään projektin riippuvuudet OS-tason Pythonista   |
| 2   | Ansible              | uv              | Asennetaan Ansible Core                                 |
| 3   | Virtual Machines     | Bash, Multipass | Luodaan kaksi managed nodea                             |
| 4   | Inventory Generation | Python script   | Luodaan Multipass-komennon outputista Ansible Inventory |
| 5   | Playbook             | VS Code         | Luodaan Hello World -tason Playbook                     |
| 6   | Test Run             | Ansible         | Ajetaan Playbook                                        |

Kuhunkin osioon on oma tärppinsä alla. Lopulta sivun pohjalla on tehtäviä, jotka sisältävät nämä vaiheet.

## Tärpit

### 1️⃣ Venv

Käytämme Pythonin paketin- ja projektinhallintaan työkalua nimeltään [uv](https://docs.astral.sh/uv/).Onko se asennettuna jo Python-osion tiimoilta? Jos ei, asenna se. Se asentuu yhdellä komennolla, joka löytyy [uv](https://docs.astral.sh/uv/) sivulta.

Voit luoda uuden *Application* tyypin projektin alla näkyvillä käskyillä. Huomaa, että projekti luodaan siihen hakemistoon, missä olet nyt. Varmista, että olet oikeassa hakemistossa, kuten `$PROJECT_ROOT/ansible/`. Huomaa, että teemme applikaation nimeltään `ansible-managed-node`. Tämä siksi, että haluamme vältellä päällekäisyyttä pelkän `ansible`-nimisen projektin kanssa. Muutoin `import` voi mennä pieleen tietyissä tilanteissa.

```bash
# Install a new uv-managed Python
uv python install 3.12

# Pin this directory to use the installed Python (.python-version)
uv python pin 3.12

# Create a new uv-managed Python project
uv init --name "ansible-managed-node" --bare --app .
```

Voit kokeilla REPL:iä näin:

```console
$ uv run python
Creating virtual environment at: .venv
Python 3.12 (...) [...]
Type "help" for more information.
>>>
```

!!! warning "Law of UV"

    Huomaa, että `uv` hallinnoi Pythonia.
    
    1. Älä pidä muita Pythoneita.
    2. Jos ajat Pythonia, käsky alkaa `uv run <komento>`.
    3. Jos asennat paketteja, käytä `uv add <paketti>`.

    Unohda system-level Python eli `/bin/python3`. Siihen ei ole asennettu eikä siihen aiota asentaa ansiblea tai muita riippuvuuksia, joita *tämä applikaatio* sattuu tarvitsemaan.


### 2️⃣ Ansible

Nyt voimme asentaa Ansible Coren ==tähän meidän luomaamme applikaatioon==. Ei siis system-wide Pythoniin. Älä sovella omia käskyjä tekoälyn hallusinaatioiden perusteella. Lue mieluummin alla oleva tärppi.

```bash
uv add ansible-core
```

### 3️⃣ Virtual Machines

Voit luoda virtuaalikoneita Multipass-työkalulla. Nimeä ne järkevästi, kuten `ansible-1` ja `ansible-2`. Voit käyttää alla olevia komentoja.

```bash
# Create 1 and 2
multipass launch --name ansible-1
multipass launch --name ansible-2
```

Kun myöhemmin haluat tuhota koneet, aja komennot:

```bash
multipass delete ansible-1
multipass delete ansible-2
multipass purge
```

Olisikohan tässä kenties järkevää käyttää skriptejä `create-vms.sh` ja `destroy-vms.sh`? No olisi! Tee tämä skriptinä.

### 4️⃣ Inventory Generation

Ansiblea varten tarvitsemme joko koneiden hostnamet tai IP-osoitteen Inventory-työkaluun. Pöllerön ratkaisu olisi aina käydä käsin korvaamassa IP-osoitteet kun koneet luodaan uusiksi. Tämä ei ole kovin skaalautuva ratkaisu. Sen sijaan voimme luoda skriptin, joka luo meille Inventoryn automaattisesti. Jotta tämä on mahdollista, tarvitset koneiden tiedot koneluettavassa muodossa, ja tämä onnistuu Multipassin avulla.

```bash
multipass list --format json
```

Mikä parempaa, voimme lopulta luoda Python-skriptin, joka lukee tämän outputin ja kirjoittaa sen tiedostoon `config/inventory/hosts.ini`. Lisätään kumpikin kone groupiin `multipass`, ja luodaan kummallekin oma ryhmänsä: `first` ja `second`. Tämä siksi, että voimme jatkossa kohdentaa käskyjä vain yhteen virtuaalikoneeseen helposti. Meillä ei ole DNS-osoitteita hallittuina, emmekä halua joutua kirjoittamaan IP-osoitteita, koska ne vaihtuvat joka kerta kun koneet tuhotaan ja luodaan uusiksi. Skriptiä voisi käyttää käsin näin:

```console
$ multipass list --format json | uv run scripts/multipass-to-inv.py
[INFO] Adding 192.168.64.41 to inventory
[INFO] Adding 192.168.64.42 to inventory
[INFO] Inventory written to config/inventory/hosts.ini

$ cat config/inventory/hosts.ini 
[multipass]
192.168.64.41
192.168.64.42

[first]
192.168.64.41

[second]
192.168.64.42
```

Yllä oleva komento olisi hyvä lisätä aiemmin luomaasi `create-vms`-skriptiin, eikö vain? Näin inventorio ei voi vahingossa unohtua tilaan, jossa se ei ole ajan tasalla.

??? tip "Opettajan skripti"

    Voit käyttää tämän kaltaista skriptiä. Tunnista puuttuvat riippuvuudet ja lisää ne `uv add`-komennolla.

    ```python
    import sys

    from pydantic import BaseModel
    from ipaddress import IPv4Address
    from pathlib import Path

    TARGET_FILE = Path("config/inventory/hosts.ini")

    class VMInfo(BaseModel):
        ipv4: list[IPv4Address]
        name: str
        release: str
        state: str

    class VMList(BaseModel):
        list: list[VMInfo]

    def read_raw_json_from_stdin() -> str:
        if sys.stdin.isatty():
            print("No input string given", file=sys.stderr)
            sys.exit(1)
        
        return "".join([line.strip() for line in sys.stdin])

    def vmlist_to_ini(vm_list: VMList, ini_file) -> str:
        ini_file.parent.mkdir(parents=True, exist_ok=True)

        with ini_file.open("w") as f:
            f.write("[multipass]\n")
            for vm in vm_list.list:
                ip = vm.ipv4[0].exploded
                print(f"[INFO] Adding {ip} to inventory")
                f.write(f"{ip}\n")

            f.write("\n[first]\n")
            f.write(vm_list.list[0].ipv4[0].exploded)
            f.write("\n")

            f.write("\n[second]\n")
            f.write(vm_list.list[1].ipv4[0].exploded)

    if __name__ == "__main__":
        raw_json = read_raw_json_from_stdin()
        vm_list = VMList.model_validate_json(raw_json)
        vmlist_to_ini(vm_list, TARGET_FILE)
        print(f"[INFO] Inventory written to {TARGET_FILE}")
    ```

### 5️⃣ Playbook

Luo yksinkertainen Playbook, joka vain tulostaa `Hello, World!`. Tämä on hyvä tapa varmistaa, että Ansible toimii ja että koneet ovat saavutettavissa. Voit käyttää pohjana [Ansible Community Docs: Creating a playbook](https://docs.ansible.com/ansible/latest/getting_started/get_started_playbook.html) ohjeen esimerkkiä.

### 6️⃣ Test Run Erehdys ⛔



!!! bug

    Nyt on tuikata Playbook käyntiin, ottaa etäisyyttä ja ihailla käsien työtä. Kuten aiemmasta Creating a Playbook -ohjeesta tiedät, komento on:

    ```
    $ uv run ansible-playbook -i configs/inventory/hosts.ini configs/playbooks/hello.yml
    uv run ansible-playbook -i config/inventory/hosts.ini config/playbooks/hello-world.yml 

    PLAY [Hello World] 
    fatal: [192.168.64.42]: UNREACHABLE! => 
    {
        "changed": false, 
        "msg": "...myuser@192.168.64.42: Permission denied (publickey).", 
        "unreachable": true
    }
    ```

    Uh oh! ==Eihän homma toimi laisinkaan==, mutta tämä on ihan odotettua. Kuinka me voisimme saada SSH-yhteyden hostiin, johon emme ole lisänneet meidän julkista avainta? Lisäksi, yritimme yhdistää käyttäjällä `myuser`, joka on *host-koneen* käyttäjänimi. 
    
    Korjataan tämä tilanne tasan kerran käsin oppimisen vuoksi. Ensi luvussa automatisoimme tämän.

### 6️⃣ Test Run Korjaus ✅

Saat lisättyä avaimen näin:

```bash
# Copy our public key to the remote hosts
multipass transfer ~/.ssh/id_ed25519.pub ansible-1:/tmp/id_ed25519.pub
multipass transfer ~/.ssh/id_ed25519.pub ansible-2:/tmp/id_ed25519.pub

# Append the public key to authorized_keys in /home/ubuntu/.ssh
multipass exec ansible-1 -- bash -c "cat /tmp/id_ed25519.pub >> ~/.ssh/authorized_keys"
multipass exec ansible-2 -- bash -c "cat /tmp/id_ed25519.pub >> ~/.ssh/authorized_keys"

# Disable SSH host key checking. This means the 
# "Are you sure you want to continue connecting (yes/no/[fingerprint])?" prompt is not shown.
# and the host is blindly trusted.
export ANSIBLE_HOST_KEY_CHECKING=False

# Run the playbook using the ubuntu user
uv run ansible-playbook -i config/inventory/hosts.ini config/playbooks/hello-world.yml -u ubuntu
```

Tulosteen pitäisi olla jotakuinkin:

```
PLAY [Hello World] *********************

TASK [Gathering Facts] *********************
ok: [192.168.64.45]
ok: [192.168.64.44]

TASK [Print Hello World] *********************
ok: [192.168.64.45] => {
    "msg": "Hello, World!"
}
ok: [192.168.64.44] => {
    "msg": "Hello, World!"
}

PLAY RECAP *********************
192.168.64.44              : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
192.168.64.45              : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

## Tehtävät

??? question "Tehtävä: Ansible Devausympäristö"

    Luo yllä olevien tärppien avulla devausympäristö hakemistoon `ansible/`. Projektisi juuren tulisi näyttää siis lopulta tältä:

    ```
    johnanderton
    ├── README.md
    ├── ansible/
    ├── bash/
    ├── pwsh/
    └── python/
    ```

    Jos tarkastelemme vain `ansible/`-hakemistoa, sen tulisi näyttää tältä:

    ```
    ansible
    ├── .python-version
    ├── .venv
    │   ├── .gitignore
    │   └── many.files.here
    ├── config
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

    Huomaa, että osa tiedostoista luodaan komentojen avulla, osa käsin. Älä luo esimerkiksi `pyproject.toml` tai `uv.lock` tiedostoja käsin. Käytä `uv`-työkalua, kuten tärpeissä on neuvottu.

    !!! note

        Tuotannossa hakemistorakenne olisi todennäköisesti monimutkaisempi. [Ansible Docs: Sample Ansible setup](https://docs.ansible.com/ansible/latest/tips_tricks/sample_setup.html) antaa esimerkkejä siitä, kuinka hakemistot voivat olla järjestetty.

??? question "Tehtävä: Ansible Hello World"

    Toisinna yllä näkyvät vaiheet siten, että saat Ansiblen tulostamaan `Hello, World!` molemmille virtuaalikoneille. Käytä apunasi yllä olevia tärppejä.

    !!! tip "Vihje: Playbook"

        Playbook näyttää lopulta jotakuinkin tältä:

        ```yaml
        ---
        - name: Hello World
        hosts: multipass
        tasks:
            - name: Print Hello World
            ansible.builtin.debug:
                msg: "Hello, World!"
        ...
        ```
