---
priority: 310
---

# Lukeminen

## Mistä on kyse?

Aloitetaan jo olemassa olevien skriptien lukemisesta. Aiemmissa luvuissa tutustuimme Bash ja PowerShell asennusskripteihin. Python ei ole Shell, joten on hieman harvinaisempaa, että asennusskripti on kirjoitettu Pythonilla. Sen sijaan me pengomme `/usr/bin`-hakemistossa sijaitsevia Python-skriptejä.

## Skriptien louhiminen

Alla on skripti, jolla voit kopioida kaikki Python-skriptit virtuaalikoneesta. Skripti noutaa kaikki virtuaalikoneen skriptit ja kopioi ne hakemistoon `$REPO/python/ubuntu_python/`. Tämän sinä toki jo tiedät, koska osaat tulkita aiempien lukujen oppien avulla skriptin sisällön. Tämän luvun ensimmäinen tehtävä on luoda ja ajaa tämä skripti. Tarkempi tehtävänanto on alempana otsikon Tehtävät alla.

```bash title="getscripts.sh"
#!/bin/bash
# Usage: getscripts.sh [language]

language=${1:-python}
dirname="ubuntu_$language" 
vm_name="copycat"

# Create new virtual machine using multipass
multipass launch --name $vm_name lts

# List all scripts in the system
declare -a scripts
IFS=$'\n' read -d '' -r -a scripts < <(
    multipass exec "$vm_name" -- find /usr/bin -type f -exec file {} \+ | awk -F: -v lang="python" 'tolower($2) ~ lang {print $1}'
)

# Copy all files
for script in "${scripts[@]}"; do
  multipass transfer --parents ${vm_name}:$script ./$dirname/
  echo "Copied $script"
done

# Kill the virtual machine
multipass delete $vm_name
multipass purge
```

!!! tip

    Jos haluat hakea Perl-skriptit, aja sama komento argumentilla `perl`. Ne kopioidaan hakemistoon `$REPO/perl/ubuntu_perl/`. Et tarvitse Perl-skriptejä tällä kurssilla, mutta voit tutustua niihin ihan yleisen mielenkiinnon ja sivistyksen vuoksi.

## Tärpit

Tämän luvun toinen tehtävä on tutustua Python-skripteihin, jotka kopioit virtuaalikoneesta host-koneellesi. Osa skripteistä voi olla hieman vaikea lähestyä, jos et ole Pythonin kanssa ennen työskennellyt. Tämän otsikon alaotsikoissa käsitellään muutamat vinkit, joiden avulla voit paremmin ymmärtää skriptien toimintaa.

### Toimimattomat importit

TODO: `/usr/lib/python3/dist-packages/`-hakemistossa oleva setti ja Debianin outoudet.

### Esimerkki: Twisted

TODO:

```console
$ cd
$ mkdir www
$ echo 'Hello, world!' > www/index.html
$ /usr/bin/twistd3 -n web --path=www
```

## Tehtävät

??? question "Tehtävä: Devausympäristö ja runbash.sh"

    Ensimmäisenä tehtävänä luot itsellesi devausympäristön. Käytännössä luot:

    * Hakemistorakenteen tehtävien vastauksia varten
    * Skriptin `getscripts.sh`, joka:
        * Käynnistää multipass-virtuaalikoneen nimeltään `copycat` 🐱
        * Kopioi skriptit sinun lokaalille koneelle `ubuntu_python/`-hakemistoon
        * Tuhoaa virtuaalikoneen
    * Valitset ja säilytät n kappaletta Python-skriptejä, joita tulet lukemaan
    * Saat tuhota loput skriptit
    * Varmistat, että kaikki tarpeellinen on versionhallinnassa

    On oletus, että työskentelet yhä samassa hakemistossa ja repositoriossa, missä Bash ja PowerShell-osiotkin on tehty. Esimerkiksi:

    🐧 linux: `/home/uname/Code/skriptiohjelmointi-2054/johnanderton`
    
    Luo repositorion sisälle uusi `python/`-hakemisto ja sen sisälle sekä yllä mainittu skripti että hakemisto skriptejä varten. Repositoriosi rakenteen tulisi olla seuraavaa myötäilevä:

    ```plaintext
    johnanderton
    ├── README.md
    ├── bash
    │   └── .gitkeep 
    ├── pwsh
    │   └── .gitkeep 
    └── python
        ├── README.md
        ├── runbash.sh
        └── scripts
            ├── kaikki.py
            ├── skriptit.py
            └── tanne.py
    ```

    Tiedosto `getscripts.sh`:n sisältö on esitelty yllä. Luo ja aja se.

??? question "Tehtävä: Parsi Python-skriptit"

    Tee sama kuin teit Bashin ja PowerShellin vastaavassa tehtävässä. Erona on se, että skriptit eivät ole tällä kertaa netistä löytyviä (tai löytyisi ne sieltäkin), vaan skriptit on louhittu virtuaalikoneen sisältä. Vaiheet:

    1. Tee yllä oleva tehtävä, jotta `ubuntu_python/`-hakemistossa on skriptit
    2. Valitse kolme skriptiä. 
        * Älä valitse liian lyhyitä.
        * Voit tuhota loput skriptit.
    3. Aloita tiedoston ylhäältä ja prosessoi se rivi riviltä.

    Tee seuraavat toimenpiteet jokaiselle skriptille:

    * ✅ Jos koodirivi sisältää entuudestaan vierasta syntaksia: dokumentoi se. 📄
    * 🔁 Jos koodirivin syntaksi on jo esiintynyt aiemmin scriptissä: unohda rivi. 🫳
    * (Optional: Tämän jälkeen poista kyseinen koodirivi tiedostosta.)

    Tämän pitäisi olla sinulle jo entuudestaan tuttua.

    !!! tip "Ajansäätöä tekoälyllä! 🤖"

        Tämän pitäisi olla sinulle aiemmista luvuista tuttu ohje! On suorastaan suositeltua käyttää tekoälyä apuna selittämään, mitä kyseiset Powershell-kielen entuudestaan tuntemattomat koodirimpsut tekevät. Älä ulkoista omia aivojasi, vaan käytä tekoälyä apuna!