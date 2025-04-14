---
priority: 199
---

# 👨‍🔬 Einsteinium

## Docker vs. Multipass

Docker sopii moneen, mutta jos tarve on hallita esim. systemd-palveluita, luoda käyttäjiä, tai sitoa eri prosesseja yhteen tavalla tai toisella, niin virtuaalikone on parempi ratkaisu. Kehitysympäristömme on Ubuntu, joten Canonicalin oma Multipass on oiva valinta. Qemu mahdollistaa rautatason virtualisoinnin (KVM), joten suorituskyky on parempi kuin tyypin 2 hypervisoreilla (VirtualBox, VMware).

!!! tip "Muut OS:t?"

    Multipass toimii myös macOS ja Windows -käyttöjärjestelmissä, mutta näiden käyttöä ei erikseen neuvoja tällä kurssilla. Windowsissa default `local.driver` on hyperv, joten jos käytät Windowsia, niin Windows Pro on suositeltu. Muutoin joudut tyytymään VirtualBoxiin driverinä.

## Tehtävät

??? question "Tehtävä: Argumenttien parsiminen"

    Luo skripti `arguments.sh`, joka vastaa seuraavaan käyttökuvaukseen: `Usage: arguments.sh [-n instance_name] [-c cloud-init-file] [FILE]..`
    
    Skriptin tulee tulostaa argumentit. Alla muutama esimerkki skriptin ajamisesta:

    ```plaintext title="🖥️ Bash"
    ./runbash.sh scripts/arguments.sh -n 'Name Here' -c config/notexists.yaml abc def efg
    ```

    ```plaintext title="🐳 stdout"
    Image name: Name Here
    Cloud Init file: config/notexists.yaml
    Positional arguments one by one: 
      abc
      def
      efg
    ```

    ```plaintext title="🖥️ Bash"
    ./runbash.sh scripts/arguments.sh
    ```

    ```plaintext title="🐳 stdout"
    Image name:
    Cloud Init file:
    Positional arguments one by one: 
    ```

    ```plaintext title="🖥️ Bash"
    ./runbash.sh scripts/arguments.sh arg1 arg2 arg3 arg4
    ```

    ```plaintext title="🐳 stdout"
    Image name:
    Cloud Init file:
    Positional arguments one by one:
      arg1
      arg2
      arg3
      arg4
    ```

    ??? "Vihje"

        Käytä `getopts`-rakennetta. Ohjeet esim. [Greg's Wiki](https://mywiki.wooledge.org/BashFAQ/035#getopts). Mallia voit ottaa myös `runbash.sh`-skriptistä.


??? question "Tehtävä: Multipass-harjoituskenttä"

    Luo skripti, joka alustaa sinulle Multipassin avulla harjoituskentän. Tarvitset tässä ylemmän tehtävän apuja: sinun pitää voida antaa sille argumentteja.

    Aloita tehtävä asentamalla [Canonical Multipass](https://canonical.com/multipass/docs/install-multipass) jos se ei ole jo asennettu. On suositeltavaa tehdä tämä tehtävä, kuten muutkin kurssin tehtävät, Ubuntu Linuxissa. Voit omalla vastuulla kuitenkin asentaa Multipassin myös macOS- ja Windows-käyttöjärjestelmiin. Jälkimmäisessä tapauksessa suosittelen Windows Pro -versiota, jotta saat Hyper-V:n käyttöön.

    !!! warning

        Huomaa, että näitä komentoja ==ei ajeta== kontissa. Nämä ajetaan sinun host-koneella.

    Komennon pitäisi toimia esimerkiksi näin:

    ```bash title="🖥️ Bash"
    ./runmulti.sh -n 'harjoituskentta' scripts/hello.sh
    ```

    Komennossa kestää ympäristöstäsi riippuen noin minuutti: se lataa ~500 megatavun Ubuntu cloud imagen koneellesi ja käynnistää sen pohjalta virtuaalikoneen. Tämän jälkeen voit ottaa yhteyttä koneeseen komennolla `multipass shell harjoituskentta`. Skripti `hello.sh` tulisi löytyä ubuntu-käyttäjän kotihakemistosta. Voit ajaa sen komennolla `bash hello.sh` tai `./hello.sh` - aivan kuten olet aiemmin oppinut. Pääset ulos koneesta komennolla `exit` tai ++ctrl+d++ pikanäppäimellä.

    ??? tip "Vihje"

        Skriptin pitäisi ajaisi seuraavanlaisia komentoja:

        ```bash
        # Komento 1: komentoon tulee ujuttaa muuttuja $INSTANCE_NAME
        multipass launch lts --cpus 1 --disk 5G --memory 1G --name ${INSTANCE_NAME}

        # Komento 2[..]: yksi per [FILE]..
        multipass transfer ${file} ${INSTANCE_NAME}:/home/ubuntu
        ```

    !!! note

        Kun haluat tuhota komeet, aja `multipass delete <koneennimi>` tai `multipass delete --all`. Kone jää vielä kummittelemaan, etkä voi luoda uutta samannimistä ennen kuin ajat `multipass purge`.

??? question "Tehtävä: Einstein-level Oppimispäiväkirja"

    Automatisoi oppimispäiväkirjan alustaminen Cookiecutter-templaatista ja tarvittavien riippuvuuksien asentaminen.  Luo skripti, joka ottaa argumenttinaan konfiguraatiotiedoston, josta se lukee muuttujat itselleen. Nämä muuttuja-arvot määräävät, minkä kurssin oppimispäiväkirjan skripti alustaa, mihin lokaatioon se tulee ja kuka on kirjoittaja. Näiden vaiheiden pitäisi olla sinulle tuttuja muilta minun kursseiltani.

    Konfiguraatiotiedosto on YAML. Sen rakenne neuvotaan [Cookiecutter: User Config](https://cookiecutter.readthedocs.io/en/stable/advanced/user_config.html)-sivulla. Meidän tapauksessa se on esimerkiksi:

    ```yaml title="skriptiohjelmointi-2054.yaml"
    default_context:
        course_name: "Skriptiohjelmointi 2054"
        author: "John Anderton"
        containing_folder: "/home/john/Code/skriptiohjelmointi-2054/johnanderton"
        __week_nro: "42"
    ```

    ??? tip "Mitä YAML:iin?"
    
        Default context -arvot eivät ole sattumanvaraisia muuttujanimiä. Käytetty Cookiecutter-templaatti, tai tarkemmin sen [gh:sourander/kamk-coociecutters/oppimispaivakirja/cookiecutter.json](https://github.com/sourander/kamk-cookiecutters/blob/main/oppimispaivakirja/cookiecutter.json)-tiedosto määrittelee ne. Tutustu tiedostoon ja sen logiikkaan. Huomaa, että tiedosto ei ole raakakoodattu JSON vaan Jinja2-pohjainen templaatti - tavallaan skriptausta sekin!

    Kun olet sitä mieltä, että skripti on kenties valmis ajettavaksi, aja:

    ```bash title="🖥️ Bash"
    # Luo
    ./runmulti.sh -n oppimispaivakirja scripts/luo-paivakirja.sh config/skriptiohjelmointi-2054.yaml

    # Yhdistä ☣️-koneeseen
    multipass shell oppimispaivakirja
    ```

    Tämän jälkeen olet valmis kokeilemaan skriptin ajamista virtuaalikoneen sisällä.

    ```bash title="☣️ Bash"
    # Aja ubuntun kotikansiossa
    ./luo-paivakirja.sh skriptiohjelmointi-2025.yaml
    ```

    Ideaalitilanne on, että skripti ei kysy käyttäjän syötettä. Sen sijaan skripti lukee konfiguraatiotiedoston ja suorittaa tarvittavat toimenpiteet, ja lopuksi tulostaa, missä oppimispäiväkirja sijaitsee. Tarkka tulosteen muotoilu ei ole tärkeä, mutta se voi olla nätti ja hymiöitä hyödyntävä. Esimerkiksi:

    ```plaintext title="☣️ stdout"
    [INFO] Learning diary created! 🥳
    [INFO] You will find it in: /home/john/Code/skriptiohjelmointi-2054/johnanderton/
    ```

    ??? tip "Vihje"

        Tulet ajamaan tämän sortin komentoa jossain vaiheessa:

        ```bash
        uv tool run cookiecutter \
            --lue cookiecutterin \
            --dokumentaatiosta \
            --mita \
            --argumentteja \
            --tarvitset \
            gh:sourander/kamk-cookiecutters
        ```

??? question "Tehtävä: Oppimispäiväkirjan jatkot"

    Tämä tehtävä on edellisen viimeisen viimeistelyä ja varmistelua. Kun olet saanut yllä olevan tehtävän suoritettua, niin haluat varmasti myös nähdä oppimispäiväkirjan selaimessa? Tämä onnistuu seuraavilla komennoilla:

    ```bash title="☣️ Bash"
    # Varmista että uv löytyy PATH:sta
    source .bashrc 

    # Mene oikeaan hakemistoon
    cd Code/skriptiohjelmointi-2025/yourname/docs

    # Aja mkdocs lisäosineen uv:lla
    uv tool run \
      --with mkdocs-material \
      --with mkdocs-awesome-nav \
      mkdocs serve --dev-addr 0.0.0.0:8000
    ```

    Tämän jälkeen selvitä virtuaalikoneen IP-osoite ja yhdistä siihen. Virtuaaliosoitteen näet ajamalla komennon `multipass info <koneennimi>`. Tämän jälkeen voit avata selaimen ja kirjoittaa osoiteriville `http://<virtuaalikoneen-ip>:8000`.

    Nyt olet virallisesti varmistanut skripti, joten se olisi valmiina käytetäväksi myös muuallakin kuin virtuaalikoneessa. Success! 🎉