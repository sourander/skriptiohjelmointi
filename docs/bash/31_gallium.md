---
priority: 131
---

# 💡 Gallium

Osaat jo ajaa Hello World -skriptin, ja olet lukenut oikeaa tuotantokoodia. Tässä luvussa harjoittelemme yksinkertaisia skriptejä, jotka eivät odota argumentteja tai käyttäjän syötettä. Ne eivät myöskään luo tai tuohoa tiedostoja. Seuraavassa luvussa siirrymme ajamaan skriptejä Docker-kontissa, jolloin voimme käyttää hitusen riskialttiimpia skriptejä.

Olet kasannut itsellesi oppimateriaaleja, joten tämä paketti ei keskity esittelemään teoriaa. Alla on kuitenkin muutama tärppi, joista voi olla hyötyä. Varsinkin debug-taidot kannattaa ottaa haltuun.

## Muuttujanimet

Muuttujien nimet voivat olla mitä tahansa, mutta niiden tulee alkaa kirjaimella tai alaviivalla ja niissä voi olla kirjaimia, numeroita ja alaviivoja. Muuttujanimet ovat case-sensitiivisiä, eli `muuttuja` ja `Muuttuja` ovat kaksi eri muuttujaa.

Bashissa käytetään usein kokonaan pienillä kirjoitettuja muuttujia ja eri sanat irrotetaan toisistaan `snake_case`-tyylillä. Esimerkiksi `max_length` on hyvä muuttujanimi.

Kussakin kielessä on varattuja avainsanoja (engl. reserved keyword). Niitä ei voi käyttää muuttujien niminä. Nämä on listatuna alla.

```
if          then        else        elif        
fi          case        esac        for         
select      while       until       do          
done        in          function    time        
{           }           !           [[          
]]          coproc      
```

??? note "Klikkaa auki skripti, jolla lista muodostettiin"

    ```bash title="reserved.sh"
    #!/bin/bash

    # Get all reserved keywords
    keywords=($(compgen -k))

    # Define the number of columns
    columns=4

    # Loop through and print in formatted columns
    for ((i = 0; i < ${#keywords[@]}; i++)); do
        printf "%-12s" "${keywords[i]}"

        # Print a newline after every nth column
        if (( (i + 1) % columns == 0 )); then
            echo
        fi
    done

    # End the output with a newline
    echo
    ```

!!! warning

    Varattujen avainsanojen lisäksi on lista Bashin sisäänrakennettuja komentoja, jotka *voit* ylikirjoittaa, mutta tämä ei luonnollisesti kannata. Esimerkiksi `cd ..`-komennon pitäisi vaihtaa hakemistopuussa yksi hakemisto ylöspäin. Katso alta skripti, jossa kyseinen komento tulostaa vain `.. by cd()`, koska se on korvattu samannimisellä funktiolla kyseisen skriptin sisällä.

    ```bash title="overwrite_cd.sh"
    #!/bin/bash -e
    cd() {
        local var="$1";
        echo "${var} by cd()";
    }

    cd ..
    ```

    Tämä ei riko skriptin ulkopuolista `cd`-komennon toimintaa, paitsi jos sen tuo kyseiseen namespaceen `source`-komennolla. Tämän jälkeen hakemiston muuttuminen muuttuu merkittävän hankalaksi:

    ```console title="🐳 Bash"
    $ source /app/overwrite_cd.sh 
    .. by cd()
    
    $ cd /etc/
    /etc/ by cd()
    
    $ cd $HOME
    /root by cd()
    ```


## Muuttujan asettaminen

Muuttujan asettaminen tapahtuu seuraavasti:

```bash
# ✅ Oikein
muuttuja="arvo"
muuttuja='arvo'
muuttuja=arvo
muuttuja="moni sanainen arvo"
muuttuja=5       # Merkkijono "5", ei varsinainen numero

# ⛔️ Väärin
muuttuja = "arvo"
muuttuja=moni sanainen arvo
```

Lisäksi on mahdollista käyttää `declare`-komentoa, joka on Bashin sisäänrakennettu komento muuttujien määrittelyyn. `declare`-komento on hyödyllinen, jos haluat määrittää muuttujan tyypin.

```bash
# Kokonaisluku
declare -i muuttuja=5

# Joukko (array)
declare -a my_array=("eka" "toka" "kolmas")

# Joukko (assoasiative array)
declare -A my_dictionary=([key1]="value1" [key2]="value2")
```

Jos haluat tulostaa kaikki käyttämäsi muuttujat, kirjoita `declare -p`.

Saavutettuja hyötyjä `declare -<tyyppi>`-käytöstä ovat mm. virheiden välttäminen ja koodin selkeyttäminen. Vahvasti tyyppimääriteltyä kieltä Bashistä ei näin tule, mutta `declare`-komento auttaa hieman. 

??? tip "Aritmeettiset operaatiot?"

    Voit suorittaa kokonaislukumuuttujien avulla laskuoperaatioita esimerkiksi näin:

    ```bash title="aritmeettinen.sh"
    #!/bin/bash
    declare -i a=5 b=3 x=0
    x=a*b
    echo "Tulo: $x"
    ```

    Vaihtoehtoinen tapa on `let`, joka käsittelee kaikkia `=`-merkin oikealla puolella olevia muuttujia lukuina.

    ```bash title="aritmeettinen_let.sh"
    #!/bin/bash
    a=5
    b=3
    let "x=a*b"
    echo "Tulo: $x"
    ```

    ```bash title="aritmeettinen_compound.sh"
    #!/bin/bash
    a=5
    b=3
    (( x = a * b ))
    echo "Tulo: $x"
    ```

!!! warning

    Huomaa, että luvut ovat **kokonaislukuja**, mikä aiheuttaa sen, että esimerkiksi `5 / 3` palauttaa luvun `1`. Jos jostain syystä haluat käyttää liukulukuja, sinun tulee kutsua jotakin ulkoista ohjelmaa, kuten `bc`-ohjelmaa. Lähtökohtaisesti Bash ei kuitenkaan ole matemaattinen ohjelmointikieli vaan skriptikieli, joten jätämme nämä operaatiot muiden kielien ongelmaksi tällä kurssilla.

## Vianetsintä

Virheiden etsiminen on tärkeä osa ohjelmointia. Bashissa on muutamia tapoja, joilla voit helpottaa vianetsintää.

### Set Builtin

Jos haluat debugata skriptiäsi, voit käyttää `set -x` ja `set -u` -komentoja. Ensimmäinen tulostaa jokaisen komennon ennen sen suorittamista ja jälkimmäinen kaataa skriptin, jos käytät määrittelemätöntä muuttujaa. Jälkimmäinen kaatuu myös silloin, jos yrität esimerkiksi sijoittaa merkkijonon kokonaislukumuuttujaan. Tutustu myös muihin [The Set Builtin](https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html) optioihin. Näistä varsinkin `-e` on hyödyllinen, joka kaataa skriptin, jos jokin komento palauttaa virheen.

```bash title="muuttuja_set_none.sh"
#!/bin/bash

declare -i luku=5

luku="kissa"
echo $luku
```

```bash title="muuttuja_set_u.sh"
#!/bin/bash -u
# ...
```

```bash title="muuttuja_set_ux.sh"
#!/bin/bash -ux
# ... 
```

!!! tip

    Samat optiot voi antaa myös skriptiä ajaessa näin: `bash -u muuttuja_set_u.sh`.

### Echo

Yksi luonnollinen tapa debugata lähes mitä tahansa ohjelmointikieltä on käyttää `echo`-komennon tulostusta. Voit tulostaa muuttujien arvoja ja tarkistaa, että ne ovat oikein.

### Interaktiivinen

Huomaa, että Bashiä voi ajaa skriptin lisäksi myös interaktiivisesti komentoriviltä. Tämä voi kuulostaa itsestäänselvältä, mutta on helppoa unohtaa, että keskellä 200-rivistä skriptiä olevan rivin voi myös ajaa erikseen ihan vain kopioimalla sen ja liittämällä terminaaliin.

### Declare

Ajoittain on tarpeellista katsoa, mitä muuttujia on määritelty ja mitä niiden arvot ovat. Tämä onnistuu `declare -p`-komennolla. Se tulostaa kaikki määritellyt muuttujat ja niiden arvot - myös sellaiset, jotka Bash on määritellyt jossain sinun skriptin ulkopuolella. Sinun määrittelemät muuttuja-arvot ovat onneksi helposti listan lopussa.

```bash title="declare_p.sh"
#!/bin/bash
declare -A my_dictionary=([key1]="value1" [key2]="value2")
my_dictionary[key3]="kissa"

declare -p
```

```bash title="🖥️ Host"
# Komentoa lyhennetty - ks. runbash.sh alemmasta tehtävästä.
docker container run ... declare_p.sh
```

```plaintext title="🐳 stdout"
# ...
declare -x TERM="xterm"
declare -ir UID="0"
declare -- _=""
declare -A my_dictionary=([key2]="value2" [key3]="kissa" [key1]="value1" )
```

!!! tip

    Jos haluat tulostaa *tietyt* muuttujat, sinun tulee antaa ne argumentteina.
     
    ```bash
    declare -p muuttuja1 muuttuja2 ...
    ```


## Tehtävät

??? question "Tehtävä: Devausympäristö ja runbash.sh"

    Ensimmäisenä tehtävänä luot itsellesi devausympäristön. Käytännössä luot:

    * Hakemistorakenteen tehtävien vastauksia varten
    * Skriptin `runbash.sh`, joka joko:
        * Ajaa valitun skriptin kontissa
        * Käynnistää interaktiivisen Bashin kontissa
    * Varmistat, että kaikki on versionhallinnassa

    Opettaja on antanut sinulle tyhjän repositorion tätä kurssia varten, ja se on esimerkiksi osoitteessa `https://repo.kamit.fi/skriptiohjelmointi-2054/johnanderton`. Tyhjä repositorio sisältää ohjeet, kuinka voit luoda lokaalin repositorion ja alustaa sen `main`-haaralla sekä tyhjällä `README.md`-tiedostolla. Noudata GitLabin ohjeita. Kloonaa repositorio lokaatioon:

    *  Ⓜ️ win: `C:\Users\uname\Code\skriptiohjelmointi-2054\johnanderton`
    *  🐧 linux: `/home/uname/Code/skriptiohjelmointi-2054/johnanderton`
    
    Korvaa 2054 kuluvalla vuodella. Korvaa johnanderton omalla nimelläsi, jossa kirjoitusa on sähköpostisi alku: `xxxxxx@kamk.fi`)

    !!! tip "Miksi 2054?"
    
        Minority Report -elokuvan John Anderton seikkailee vuodessa 2054. Käytän fiktionaalista vuotta, jotta tätä materiaalia ei tarvitse päivittää joka toteutuksen yhteydessä.

    Luo repositorion sisällle seuraava rakenne:

    ```plaintext
    johnanderton
    ├── README.md
    ├── bash
    │   ├── README.md
    │   ├── runbash.sh
    │   └── scripts
    │       ├── kaikki.sh
    │       ├── skriptit.sh
    │       └── tanne.sh
    ├── pwsh
    │   └── .gitkeep 
    └── python
        └── .gitkeep
    ```

    Tiedosto `runbash.sh`:n luominen olisi hyvä tehtävä viikon päästä, mutta tarvitset sitä jo nyt, joten tarjoan sen valmiina. Voit ladata sen Githubista osoitteesta [gh:sourander/skriptiohjelmointi/scripts/runbash.sh](https://raw.githubusercontent.com/sourander/skriptiohjelmointi/refs/heads/main/scripts/runbash.sh). Lataa tiedosto ja sijoita se oikeaan hakemistoon.


??? question "Tehtävä: Bash Hello World"

    Luo skripti `hello.sh`, joka tulostaa tekstin "Hello World". 
    
    Huomaa, että sijoita se oikeaan hakemistoon, kuten `~/Code/skriptiohjelmointi-2054/johnanderton/bash/scripts/hello.sh`. Voit ajaa tiedoston äsken lataamallasi apuri-skriptillä.

    ```bash title="🖥️ Host"
    # Vaihda hakemistoon, missä on runbash.sh
    cd ~/Code/skriptiohjelmointi-2054/johnanderton/bash/

    # Aja
    ./runbash.sh scripts/hello.sh
    ```

    ```plaintext title="🐳 stdout"
    Hello World
    ```

??? question "Tehtävä: Turboahdettu Bash Hello World"

    Luo skripti, joka tulostaa absoluuttisen polun työhakemistoon ja siihen hakemistoon, missä skripti sijaitsee. Skriptin runko on alla:

    ```bash title="hello_turbo.sh"
    #!/bin/bash

    source /etc/os-release
    distro_version=${VERSION:-"Unknown distribution"}

    cwd_path=''  # IMPLEMENT
    scr_path=''  # IMPLEMENT

    printf "========= Turbo Hello World! =========\n"
    printf "%-30s %s\n" "Current working directory:" "$cwd_path"
    printf "%-30s %s\n" "Script directory:" "$scr_path"
    printf "%-30s %s\n" "Kernel name:" "$distro_version"
    ```

    Rivit, joiden perässä on kommentti `# IMPLEMENT`, vaativat sinulta toimia. Lisää näihin toiminnallisuus. Testaa yllä olevan tehtävän neuvoilla. Kutsu skriptiä `hello_turbo.sh` ja katso, että se tulostaa oikeat tiedot.

    **HUOM!** Pelkkä `src_path=$0` sattuu toimimaan, koska skripti ajetaan absoluuttisella polulla. Tämän tulet kuitenkin huomaamaan vääräksi vastaukseksi viimeistään seuraavaa tehtävää tehdessä. Selvitä, kuinka saat käännettyä ==relatiivisen polun absoluuttiseksi==.

    ??? tip "Apuja absolutisointiin"
        GNU:n `readlink`-komento auttaa tässä. Ota selvää, minkä flagin ja parametrin avulla saat haluamasi tuloksen. Tarvitset tässä tiedonhakutaitoja:

        ```bash
        # Mitä ? ja ???? tilalle tulee?
        src_path=$(readlink -? ????)
        ```

??? question "Tehtävä: Interaktiivinen Bash"

    Harjoittele tässä tehtävässä interaktiivista Bashin käyttöä. Tämä on tarpeellista, jos haluat luoda kontin sisälle esimerkiksi testitiedostoja, tai haluat tarkkailla, mitä ajettu skripti oikeastaan tekikään. Tarvitset tässä tehtävässä ylempänä mainitun `runbash.sh`-skriptin. Huomaa, että se löytyy `/app/`-hakemistosta kontin sisällä. Tämä johtuu `runbash.sh`-skriptin rivistä: `--mount type=bind,source="$(pwd)/${SCRIPT_DIR}",target=/app,readonly`.

    Jos muokkaat `hello_turbo.sh`-tiedostoa Host-koneella, sinun ei tarvitse poistua kontista ja käynnistää sitä uudelleen, koska polku on bindattu kontin sisään. Tallenna tiedosto ja aja se uudelleen kontissa - tiedosto on päivittynyt! Myös alla komennoissa luotava tiedosto `/root/a/b/c/hello_turbo.sh`-päivittyy samalla kertaa, koska se on symbolinen linkki eli pointteri alkuperäiseen tiedostoon.
    
    Käynnistä istunto alla olevalla komennolla. Pois pääset komennolla `exit` tai pikanäppäimellä ++ctrl+d++.

    ```bash title="🖥️ Host"
    # Ilman parametriä skripti ajaa kontin vakio CMD:n, joka on
    # haluamamme: /bin/bash
    ./runbash.sh
    ```

    **Vaihe 1: Aja missä oletkin**

    ```bash title="🐳 Bash"
    /app/hello_turbo.sh
    ```

    ```plaintext title="🐳 stdout"
    ========= Turbo Hello World! =========
    Current working directory:     /
    Script directory:              /app/hello_turbo.sh
    Kernel name:                   24.04.1 LTS (Noble Numbat)
    ```

    Huomaa, että vakiona työhakemisto on `/` eli juurihakemisto.

    **Vaihe 2: Aja toisaalla ja toisaalta**

    ```bash title="🐳 Bash"
    mkdir -p /root/a/b/c
    ln -s /app/hello_turbo.sh /root/a/b/c/hello_turbo.sh
    cd /root/a
    ./b/c/hello_turbo.sh
    ```

    Huomaa, että `hello_turbo.sh`-skripti tulostaa nyt oikeat tiedot. Symbolinen linkki tosiaan sijaitsee hakemistossa `/root/a/b/c/`, eli `src_path`-muuttuja on määritelty oikein. Samaten `cwd_path`-muuttuja on määritelty oikein, koska kun ajoit skritin, olit hakemistossa `/root/a`.

    ```plaintext title="🐳 stdout"
    ========= Turbo Hello World! =========
    Current working directory:     /root/a
    Script directory:              /root/a/b/c/hello_turbo.sh
    Kernel name:                   24.04.1 LTS (Noble Numbat)
    ```

    !!! tip

        

??? question "Tehtävä: Bash vianetsintä"

    Luo yllä esitellyt kolme skriptiä: `muuttuja_set_{none,u,ux}.sh`.

    1. Tarkastele, kuinka optiot vaikuttavat outputtiin.
    2. Kokeile myös vaihtoehtoista tapaa. Aja `bash -ux muuttuja_set_none.sh`.

    Ajathan nämä kontissa aiempien tehtävien oppien avulla.

