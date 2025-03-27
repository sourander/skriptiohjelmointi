---
priority: 400
---

# Ansible 101

## Perusteet

### Missä ajetaan?

#### Lokaalisti

Emme käytä Docker-konttia Ansiblen ajamiseen, jotta säästymme mahdollisilta huolilta liittyen verkotukseen. Ansible **control node** ajetaan tällä kurssilla omalta **Linux-työasemalta**. 

Ansiblea voi ajaa keskitetystä CI/CD-palvelusta (GitLab CI/CD, GitHub Actions, Jenkins, ...) tai keskitetyn hallintapalvelimen kautta (Ansible Tower, AWX), mutta perusteita opetellessa on helpointa ajaa Ansiblea lokaalisti. Käytettiin sitä mistä tahansa, sen tiedostot säilötään tyypillisesti Git-repositorioon. 

!!! note

    Git ja *"`$ANYTHING` as a Code"* ovat DevOpsin perusta.

    Muuttuja `$ANYTHING` voi olla esimerkiksi:
    
    * Platform as Code
    * Infrastructure as Code
    * Configuration as Code
    * Pipeline as Code
    * Policy as Code
    * ...

#### Multipass

Ansible **managed node** on tällä kurssilla Multipass-virtuaalikone. Huomaa, että tämä ei tarkoita, että me ajaisimme Ansiblea Multipass-virtuaalikoneessa. Ansible ajetaan **control nodella**, ja se yhdistää SSH:lla managed nodeen. Termi tälle on **agentless**.

### Mikä Ansible on?

Ansible on DevOps- tai Configuration Management -työkalu, joka toteuttaa ==Configuration as Code==-periaatetta. Sen omistaa Red Hat Inc., ja se on kirjoitettu Pythonilla, mutta tavallisessa käytössä Python-taitoja ei tarvita: riittää, että osaa kirjoittaa YAML-tiedostoja. Ansiblella ei siis tyypillisesti hallita intrastruktuuria vaan sen konfiguraatiota. Toisilla kursseilla sinulle on esitelty Terraform, joka on infrastruktuurin hallintatyökalu: Ansible jatkaa siitä, mihin Terraform loppuu.

Ansiblella voi siis esimerkiksi asentaa ohjelmia, konfiguroida palomuureja, luoda käyttäjiä, ajaa skriptejä, ja niin edelleen. Kaiken, minkä voit tehdä komentorivillä, voit tehdä Ansiblella.

Ansiblen kilpailijoita ovat esimerkiksi Puppet, Chef, VMware SaltStack. Toisin kuin useimmat kilpailijat, Ansible ei vaadi agenttien asentamista managed nodeihin, vaan se käyttää SSH:ta (tai Windows-nodejen kanssa WinRM:ää) managed nodeihin yhteyden ottamiseen. Tämä tekee Ansiblesta helpon ottaa käyttöön, koska managed nodeihin ei tarvitse asentaa mitään (paitsi SSH).

Alla on taulukko tyypillisistä entiteeteistä tai konsepteista, jotka ovat osa Ansiblea:

| Entiteetti   | Kuvaus                                                    |
| ------------ | --------------------------------------------------------- |
| Control node | Ansiblen ajamiseen käytettävä kone                        |
| Managed node | Ansiblen hallinnoitava kone                               |
| Inventory    | Managed nodejen lista                                     |
| Playbook     | Ansiblen suoritettava tiedosto                            |
| Task         | Yksittäinen komento Playbookissa                          |
| Collection   | Kokoelma moduuleja (`<namespace>.<collection>`)           |
| Module       | Yksittäinen komento (`<namespace>.<collection>.<module>`) |

==Moduuli== on käytännössä yksittäinen ==Python-skripti==, joka suoritetaan managed nodella. Kuinka tämä ajetaan? **Control Node** avaa SSH-yhteyden **Managed Nodeen**, etsii Python-binäärin, siirtää (`scp`:llä) skriptin väliaikaishakemistoon, ja ajaa skriptin: `/usr/bin/python3 /tmp/ansible_script_xyz.py`. Huomaa, että Ansiblen ei tarvitse olla asennettuna Managed Nodeen: riittää, että Python, SSH Daemon ja automaatioon sopiva käyttäjä (default: `ubuntu`) ovat läsnä.

!!! tip

    Voit käydä kurkkimassa Python-skriptien sisältöä. Esimerkiksi `ansible.builtin.command`-moduuli löytyy virtuaaliympäristön luomisen jälkeen `.venv/lib/python3.12/site-packages/ansible/modules/command.py`-tiedostosta. Jos haluat nähdä tiedoston ilman asennusta, se löytyy luonnollisesti GitHubista: [gh:ansible/ansible/lib/ansible/modules/command.py/](https://github.com/ansible/ansible/blob/devel/lib/ansible/modules/command.py).

### Ero skripteihin

Ansible on deklaratiivinen työkalu, toisin kuin imperatiiviset skriptit, kuten Bash-skriptit. Deklaratiivinen tarkoittaa, että kerrot Ansiblelle, mitä haluat, ja Ansible huolehtii siitä, että se tapahtuu. Imperatiivinen tarkoittaa, että kerrot tarkalleen, miten haluat, että asiat tapahtuvat.

Lisäksi Ansible on idempotentti, eli voit ajaa saman Playbookin monta kertaa, ja lopputulos on aina sama. Jos *desired state* on jo saavutettu, Ansible ei tee mitään.

## Komponentit

### Core ja Community

Red Hat pyrkii tekemään Ansiblella rahaa, joten kaikki siihen liittyvät työkalut eivät ole ilmaisia. Alla on taulukko Ansiblen eri palikoista ja tieto siitä, onko se ilmainen vai kuuluuko se maksulliseen tuotteeseen.

| Työkalu           | Free | $$$ | Maksullinen lisätuote         |
| ----------------- | ---- | --- | ----------------------------- |
| Ansible Core      | x    |     |                               |
| Ansible Community | x    |     |                               |
| Ansible Galaxy    | x    |     | Automation Hub                |
| AWX               | x    |     | Ansible Controller (ex Tower) |

Yllä listatuista on hyvä tietää, että:

* **Ansible Core** on varsinainen ansible-komentorivityökalu.
* **Ansible Galaxy** on pakettivarasto, josta voit ladata Collectioneita *(vrt. PowerShell Gallery, PyPi)*.
* **Ansible Community** sisältää Ansible Coren, johon on valmiiksi asennettu kuratoitu kattaus Collectioneita.

Lopulta on siis sama, asennatko [ansible-coren](https://pypi.org/project/ansible-core/) vai [ansiblen](https://pypi.org/project/ansible-core/). Jos asennat ensimmäiseen kaikki jälkimmäiseen sisältyät Collectionit, sinulla on käytännössä sama paketti. Kuinka monta Collectiona ja mitä ne ovat?

* Core
    * 1 Collection.
    * Tämä: [Core docs: ansible.builtin](https://docs.ansible.com/ansible-core/devel/collections/ansible/builtin/index.html)
* Community
    * Yli 100 Collectionia.
    * Lista: [Community docs: Collection Index](https://docs.ansible.com/ansible/latest/collections/)

!!! tip "Rautalangasta"

    Kuvittele, että Windowsista olisi olemassa **Windows Core** ja **Windows Community Gamer Edition (WCGE)**.

    **WCGE** sisältäisi: Windows Coren, eli tavallisen Windowsin, johon on valmiiksi asennettu: Steam, Discord, Chrome, ja Visual Studio Code.

    Lopulta on aivan sama, asennatko Windows Coren ja lataat sen jälkeen Steam, Discord, Chrome ja Visual Studio Code erikseen, vai asennatko Windows Community Collectionin.

### Versionumerot

Jotta homma ei olisi liian simppeliä, Community ja Coren versionumerot poikkeavat toisistaan, ja lisäksi standardi on ==vaihtunut 2021 Ansible 3:n myötä==. Alla on taulukko, joka kertoo, mikä Coren versio vastaa mitäkin Communityn versiota:

| Ansible       | Ansible Core |
| ------------- | ------------ |
| Ansible 11    | 2.18         |
| Ansible 10    | 2.17         |
| Ansible 9     | 2.16         |
| ...           | ...          |
| ==Ansible 3== | 2.11         |
| Ansible 2.10  | 2.10         |
| Ansible 2.9   | 2.9          |

Nykyään riittää tietää, että Python Package Indexissä on [ansible-core](https://pypi.org/project/ansible-core/)-paketti, joka on Ansible Coren uusin versio, ja [ansible](https://pypi.org/project/ansible/)-paketti, joka on Ansible (Community) uusin versio. Kirjoitushetkellä versiot mätsäävät yllä näkyvään taulukkoon, eli versiot 11 ja 2.18 ovat tuoreimmat:

* Ansible (Community) 11.3.0
* Ansible Core 2.18.3

### Playbook

### Sisältö

Hello World -viritelmään tarvitsemme vähintään kaksi tiedostoa: **Inventory** ja **Playbook**.

Playbook on Ansiblen suoritettava tiedosto, joka koostuu yhdestä tai useammasta **play**sta. Play on yksi tai useampi **task**, joka suoritetaan managed nodeilla. Task on yksittäinen komento, joka suoritetaan managed nodella. Alla on yksinkertainen Playbook, joka on lainattu [Ansible Community: Getting started with Ansible](https://docs.ansible.com/ansible/latest/getting_started/get_started_playbook.html)-dokumentaatiosta.

```yaml title="my-first-playbook.yml"
- name: My first play
  hosts: myhosts
  tasks:
   - name: Ping my hosts
     ansible.builtin.ping:

   - name: Print message
     ansible.builtin.debug:
       msg: Hello world
```

Kyseinen Playbook sisältää yhden playn, *My first play*, joka sisältää kaksi taskia. Ensimmäinen task käyttää `ansible.builting` Collectionista moduulia nimeltään `ping`, ja toinen käyttää saman Collectionin `debug`-moduulia.

!!! note "Kolme väliviivaa"

    Tulet törmäämään esimerkkeihin, joissa Playbook alkaa kolmella väliviivalla. Tämä kuuluu [YAML-tiedoston spesifikaatioon](https://yaml.org/spec/1.2.2/), ja merkkaa dokumentin alkua: *"YAML uses three dashes (“---”) to separate directives from document content. This also serves to signal the start of a document if no directives are present."*

    Meidän harjoituksissa yhdessä YAML-tiedostossa ei tule koskaan olemaan enempää kuin yksi dokumentti, joten ne voi nähdä valinnaisina. Ota tai jätä.

!!! note "Kolme pistettä"

    Sama tarina kuin yllä, mutta `...`-merkkaa dokumentin loppua. Valinnainen, mutta spesifikaation mukainen.

Toinen tiedosto on Inventory, joka sisältää listan IP-osoitteista tai hostnameista, joihin Ansible yhdistää. Inventory voi olla yksinkertainen tiedosto, joka sisältää hyödyntää ryhmiä ja muuttujia. Tiedosto voi olla `.ini` tai `.yaml`-muotoinen. Alla on esimerkki `.ini`-muotoisesta Inventory-tiedostosta, joka on lainattu samasta lähteestä kuin Playbook:

```ini title="inventory.ini"
[myhosts]
192.0.2.50
192.0.2.51
```

### Ajaminen

Olettaen, että sinulla on `ansible-core` asennettuna, voit ajaa Playbookin seuraavasti:

```bash
ansible-playbook -i inventory.ini my-first-playbook.yml
```

Tämä komento ajaa Playbookin `my-first-playbook.yml` ja käyttää Inventory-tiedostoa `inventory.ini`. Ansible yhdistää IP-osoitteisiin ja suorittaa määritellyt taskit järjestyksessä ylhäältä alas.

## Tehtävät

!!! question "Tehtävä: Ansiblen informaatiohaku"

    Muodosta itsellesi katalogi tarpeellisista lähteistä. Suosi tuoreita ja virallisia lähteitä. Alla pari suositusta, mistä aloittaa etsintä:

    1. [Ansible Community Documentation](https://docs.ansible.com/ansible/latest/index.html). Vaikka me käytämme `ansible-core`-pakettia, tämä dokumentaatio on silti hyödyllinen. Ainut, mitä sinun pitää huomioida, että `ansible.builtin`-moduuli on Ansible Coren oma, muut moduulit ovat Collectioneista. Jos tarvitset jotakin muuta pluginia (moduulia tai roolia), asenna se `ansible-galaxy`-komennolla.
    2. [Ansible for DevOps](https://github.com/geerlingguy/ansible-for-devops-manuscript). Tämä avoimen lähdekoodin kirja on ostettavissa, jos haluaa tukea kirjoittajaa. Kirja on saatavilla ilmaiseksi: etsi GitHubista lausetta *"You can also grab a free copy of the published work on LeanPub using this coupon link"*.
    3. [Ansible for DevOps Examples](https://github.com/geerlingguy/ansible-for-devops). Latasit yllä olevan kirjan tai et, tämä repositorio on hyödyllinen, koska se sisältää paljon esimerkkejä. Eikä ihan mitä tahansa esimerkkejä. Jos [etsit ladatuimmat Rolet Ansible Galaxystä](https://galaxy.ansible.com/ui/standalone/roles/?page=1&page_size=10&sort=-download_count), huomaat, että top 10 on täynnä tämän kirjoittajan rooleja. Kirjoitushetkellä ladatuin on `geerlingguy.docker` noin 22 miljoonalla latauksella.
    4. [Practical Ansible Automation Handbook](https://kamk.finna.fi/Record/kamk.99641009106247) on vaihtoehtoinen kirja ja se löytyy KAMK Finna -kirjastosta. Kirja on vuodelta 2023 ja Luca Bertonin kirjoittama.
    
    Myös maksullisia kirjoja löytyy, joista maininnan arvoinen on **Ansible: Up and Running 3rd e.d. (2022)**, joka O'Reillyn julkaisema ja . Data Center -opiskelijoita voi kiinnostaa myös **Ansible for VMware by Examples: A Step-by-Step Guide to Automating Your VMware Infrastructure (2022)**, joka on Apressin julkaisema ja Luca Bertonin kirjoittama.

    Ansible on aihe, josta löytyy merkittävästi myös YouTube-sisältöä.

