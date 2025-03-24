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

## Tehtävät

!!! question "Tehtävä: "Parsi Ansible-koodit"

    Tämä tehtävätyyppi on tuttu jo Bash, PowerShell ja Python osioista. Valitse yllä olevista Ansible-esimerkeistä yksi ja tutustu sen koodin sisältöön. Kirjoita ylös löytämäsi syntaksin palaset, jotka ovat uniikkeja. Huomaa, että koodi ei ole pelkästään yhdessä tiedostossa, vaan sinun tulee yleensä tutustua 2-3 tiedostoon:

    * Playbook (`something.yml`)
    * Inventory (`something.ini`)
    * Ansible Configuration (`ansible.cfg`)

    Jälkimmäistä tiedostoa ei välttämättä ole aina olemassa kaikissa esimerkeissä.

    Huomaa, että jos jokin moduuli on todella lyhyttä muotoa kuten `shell`, se viittaa `ansible.builtin.shell`-moduuliin. FQCN (Fully Qualified Collection Name) on aina suositeltavaa käyttää, mutta se ei ole pakollista, jos moduuli on Ansiblen Coresta.