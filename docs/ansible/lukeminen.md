---
priority: 410
---

# Lukeminen

## Esimerkkejä

### ScyllaDB

Tutustu ScyllaDB:n [Set Up a Spark Cluster with Ansible](https://migrator.docs.scylladb.com/stable/getting-started/ansible.html) ohjeeseen. Ohje sisältää opastuksen vaiheista ja komennoista, joilla käyttäjä saisi Spark-klusterin pystyyn Ansiblen avulla. Klusteriin kuuluu yksi `spark_master` ja kaksi workeria: `spark_worker1` ja `spark_worker2`.

Itse koodi löytyy: [gh:scylladb/scylladb/scylla-migrator repositoriosta](https://github.com/scylladb/scylla-migrator/tree/master/ansible)

### Etsi ohje

Voit etsiä myös muita ohjeita, jotka käyttävät Ansiblea. Pääasia, että ohjeesta löytyy Playbook ja Inventory -tiedostot, jotta voit tutustua Ansiblen syntaksiin. Yksi tapa on etsiä esimerkiksi `medium.com`, `dev.to` tai `substack.com` sivustojen artikkeleita. Voit etsiä tiettyä vuotta tuoreempia artikkeleita tietyltä sivustolta näin:

```
deploy ansible site:medium.com after:2023
```

### Open Forms

Tutustu Open Forms -projektin [Install using Ansible](https://open-forms.readthedocs.io/en/stable/installation/ansible.html) -ohjeeseen. Ohje sisältää opastuksen vaiheista ja komennoista, joilla käyttäjä saisi Open Forms -sovelluksen pystyyn Ansiblen avulla.

Itse koodi löytyy [gh:open-formulieren/open-forms repositoriosta](https://github.com/open-formulieren/open-forms/tree/master/deployment).

Huomaa, että koodissa käytetään [rooleja](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html), jotka ovat Ansiblen tapa luoda itsenäinen kokonaisuus toisiinsa liittyvistä taskeista, muuttujista, tiedostoista ja muista asseteista siten, että sitä voi käyttää useissa eri Playbookeissa. Roolit itsessään ladataan tässä tapauksessa toisesta collectionista:

```yaml
  collections:
    - maykinmedia.commonground
```

Nämä roolit löytyvät `gh:maykinmedia/commonground-ansible` repositoriosta, joka on siis Ansible Galaxystä löytyvä [Galaxy: maykinmedia.commonground](https://galaxy.ansible.com/ui/repo/published/maykinmedia/commonground/) Collection. Esimerkiksi roolin `django_app_docker` koodi löytyy repositorion polusta [roles/django_app_docker/tasks/main.yml](https://github.com/maykinmedia/commonground-ansible/blob/main/roles/django_app_docker/tasks/main.yml).

!!! warning

    Tämä on monimutkainen esimerkki! Älä huoli, jos et ymmärrä kaikkea koodia. Pyri silti silmäilemään koodia ja tunnistamaan syntaksista merkityksellisiä palasia.

## Syventävää lukemista

### Ansible Lokaalisti

Ansible on suunniteltu käytettäväksi keskitettynä työkaluja, jolla hallinnoidaan useiden koneiden konfiguraatiota, mutta kukaan ei estä käyttämästä sitä vain ja ainoastaan omien työasemien konfiguroimiseen. Kenties kyllästyt esimerkiksi varmistelemaan, että sinun `.zshrc`-tiedostosta löytyy tietyt rivit. Jos ajat sokkona seuraavan koodiblokin, päädyt lisäämään samat rivit useita kertoja:

```bash
echo 'alias gitweek="'git log --pretty=format:"%x09%ad%x09%s" --date=format:"%V %a"'' >> ~/.zshrc
echo 'eval "$(uv generate-shell-completion zsh)"' >> ~/.zshrc
echo 'eval "$(uvx --generate-shell-completion zsh)"' >> ~/.zshrc
```

Voit korvata tämän joko `ansible.builtin.lineinfile` tai `blockinfile` moduulia hyödyntäen. Esimerkiksi:

```yaml
- name: Add gitweek alias to startup scripts
  ansible.builtin.lineinfile:
    path: ~/.zshrc
    line: 'alias gitweek='git log --pretty=format:"%x09%ad%x09%s" --date=format:"%V %a"''
    regexp: '^alias gitweek='
- name: Add uv autocompletion to startup scripts
  ansible.builtin.blockinfile:
    path: ~/.zshrc
    block: |
      # uv and uvx autocompletion
      eval "$(uv generate-shell-completion zsh)"
      eval "$(uvx --generate-shell-completion zsh)"
```

Luonnollisesti yllä olevan `typora`-aliasis voisi lisätä myös `blockinfile`-moduulin avulla.

### Ansible dotfiles

Yllä mainitun lokaalin työaseman hallinnan voi viedä niin pitkälle kuin haluaa. Ansible ei ole toki ainut työkalu, jolla voit hakea dotfilesisisi GitHubista tai jostakin muusta keskitetystä lähteestä, mistä löytyy niiden tuoreimmat versiot. Tähän löytyy [hirveä määrä kilpailevia ratkaisuja](https://dotfiles.github.io/utilities/). Tässä luvussa käsitellään Ansiblea, joten on luontevaa pohtia, kuinka ongelman voisi ratkaista Ansiblea hyödyntäen. Tähän tarjoaa yhdenlaisen ratkaisun esimerkiksi TechDufus, katso video alta. Videolla saat pikaisen katsauksen myös Ansible Vaultiin, jota ei käsitellä tällä kurssilla. Ansible Vault mahdollistaa arkaluonteisten tietojen salaamisen siten, että ne voi säilyttää versionhallinnassa. Esimerkiksi SSH-avaimet, salasanat ja muut arkaluontoiset tiedot voi salata ja purkaa Ansible Vaultin avulla.

<iframe width="560" height="315" src="https://www.youtube.com/embed/hPPIScBt4Gw?si=ToR2Fy0ZXr-sj1VR" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

**Video 1**: Kehitysympäristön pystytys Ansiblea hyödyntäen. Varsinainen koodi löytyy [gh:techdufus/dotfiles](https://github.com/techdufus/dotfiles) repositoriosta.

Onko tämä tarpeen? Riippuu täysin sinusta. Jos käytät useita eri työasemia, ja sinulla on tarve pitää niiden kehitysympäristöt kaikkine konfiguraatioineen synkronissa, ja tarpeet ovat monimutkaisempia kuin pelkkä yksi tai kaksi aliasia, niin silloin Ansible voi olla hyvä vaihtoehto. Muissa tapauksissa *over-engineering* voi olla vaarana.

## Tehtävät

!!! question "Tehtävä: Parsi Ansible-koodit"

    Tämä tehtävätyyppi on tuttu jo Bash, PowerShell ja Python osioista. Valitse yllä olevista Ansible-esimerkeistä yksi ja tutustu sen koodin sisältöön. Kirjoita ylös löytämäsi syntaksin palaset, jotka ovat uniikkeja. Huomaa, että koodi ei ole pelkästään yhdessä tiedostossa, vaan sinun tulee yleensä tutustua 2-3 tiedostoon:

    * Playbook (`something.yml`)
    * Inventory (`something.ini`)
    * Ansible Configuration (`ansible.cfg`)

    Jälkimmäistä tiedostoa ei välttämättä ole aina olemassa kaikissa esimerkeissä.

    Huomaa, että jos jokin moduuli on todella lyhyttä muotoa kuten `shell`, se viittaa `ansible.builtin.shell`-moduuliin. FQCN (Fully Qualified Collection Name) on aina suositeltavaa käyttää, mutta se ei ole pakollista, jos moduuli on Ansiblen Coresta.