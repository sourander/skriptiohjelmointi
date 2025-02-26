---
priority: 138
---

# 🎆 Strontium

## Tärpit

### Tarpeelliset komennot

Tämän osion tehtävissä avuksi ovat ainakin seuraavat kohdat GNU-manuaalista:

* [read](https://www.gnu.org/software/bash/manual/bash.html#index-read)
* [while](https://www.gnu.org/software/bash/manual/bash.html#index-while)
* [if](https://www.gnu.org/software/bash/manual/bash.html#index-if)
* [RANDOM](https://www.gnu.org/software/bash/manual/bash.html#index-RANDOM)

### Hakasulkeiden määrä

Huomaa, että yksittäiset hakasulkeet, eli `[ jotain ]`, ovat sama asia kuin komento `test`. Kyseinen komento on POSIX-yhteensopiva ja sitä käytetään usein ehtolauseissa, jos haluat koodin toimivan kaikilla Unix-johdannaisilla käyttöjärjestelmillä. Jos tiedät, että koodia ajetaan nimenomaan Bash-shellillä, niin voit käyttää kaksoishakasulkeita, eli `[[ jotain ]]`. Kaksoishakasulkeet ovat extensio Bashille ja niissä on muutamia etuja, kuten parempi merkkijonon käsittely ja parempi looginen operaattorien tuki.

```bash title="compare_brackets.sh"
#!/bin/bash

if [ 2 -gt 1 -a 1 -lt 2 -a 3 -eq 3 ]; then
    echo "[POSIX] 2>1 ja 1<2 ja 3 on yhtä suuri kuin 3"
fi

# Tämä on Bash-spesifi
if [[ 2 -gt 1 && 1 -lt 2 && 3 -eq 3 ]]; then
    echo "[[BASH]] 2>1 ja 1<2 ja 3 on yhtä suuri kuin 3"
fi

# Arithmetic Bash
if (( 2 > 1 && 1 < 2 && 3 == 3 )); then
    echo "((BASH)) 2>1 ja 1<2 ja 3 on yhtä suuri kuin 3"
fi
```

!!! warning

    Huomaa, että välilyönnit ovat tärkeitä Bash-skripteissä - myös (haka)sulkeiden kanssa. Katso alta esimerkki toimivasta ja ei-toimivasta koodista.

    ```bash title="bracket_space_problem.sh"
    #!/bin/bash -e

    answer="no"

    # ⛔️ Huonoa koodia; puuttuva välilyönti tekee ehdosta 
    # epäpätevän, ja one-linerin logiikka hajoaa vaarallisesti!
    if [ "$answer" != "yes"]; then exit 1; fi
    echo "Case 1: should not print"

    # ✅ Hyvää koodia; koodista otetaan exit ellei vastaus ole 'yes'
    if [ "$answer" != "yes" ]; then exit 1; fi
    echo "Case 2: should not print"
    ```

    Tulostuu:
    
    ```plaintext title="🐳 stdout"
    ./thingy.sh: line 6: [: missing `]'
    Case 1: should not print
    ```

## Staattinen analyysi

Viime luvussa opimme debuggausta bash:n optioneilla. Nyt käytämme lintteriä. Voit kokeilla sen online-versiota osoitteessa [shellcheck.net](https://www.shellcheck.net/). Tehtävä-osiossa sinä otat sen käyttöön skriptauksen ja Dockerin avulla.


## Tehtävät

??? question "Tehtävä: Arvaa numero"

    Luo ohjelma, joka generoi luvun väliltä 1-1000 ja pyytää käyttäjää arvaamaan sen. Ohjelma antaa vihjeen, onko arvattu luku suurempi vai pienempi kuin generoitu luku. Ohjelma lopettaa, kun käyttäjä arvaa oikein.

    ```bash title="arvaaluku.sh"
    #!/bin/bash

    max_number=1000

    declare -i correct=500 # IMPLEMENT! Generoi satunnainen
    declare -i guess=0

    echo "Arvaa luku väliltä 1-${max_number}."
    echo "Negatiivinen luku poistuu ohjelmasta."

    # IMPLEMENT! Logiikka käyttäen while-silmukkaa.
    ```

    Kannattaa tutkia, minkä arvon kokonaisluku `guess`saa, jos syöte on jotain muuta kuin validi numero.

??? question "Tehtävä: Reminder"

    Tämän tehtävän idean pohjana toimii Dave Taylorin ja Brandon Perryn [Wicked Cool Shell Scripts, 2nd Edition](https://nostarch.com/wcss2). Luo kaksi ohjelmaa, jotka toimivat yhdessä. Toinen luo, toinen näyttää muistiinpanoja.

    Jotta tehtävä ei olisi pelkkä copy-paste [kirjan repositoriosta löytyvistä tiedostoista](https://github.com/brandonprry/wicked_cool_shell_scripts_2e/tree/master/3), niin luodaan ohjelma, joka on merkittävästi yksinkertaisempi. Voit poistaa koodista monimutkaisimmat osiot (`cat` ja `grep`). Typistä koodin toiminnallisuus siten, että vain välttämätön on jäljellä. Jos haluat lisähaastetta, älä katso kirjan esimerkkikoodia laisinkaan.

    * `install_remind.sh`
        * Lisää `remember` ja `remind`-komennot `/usr/local/bin`-hakemistoon symbolisina linkkeinä, jotta niitä voi kutsua ilman tiedostopolkua nimillä `remember` ja `remind`.
    * `remember`
        * Kysyy `read`-komennon avulla käyttäjältä muistutuksia, jotka tallennetaan `$HOME/.reminder`-tiedostoon. Tyhjä syöte lopettaa muistutusten kirjoittamisen.
        * Formaatti: `[timestamp] Muistutus`
    * `reminder`
        * Tulostaa koko muistutustiedoston sisällön.

    ??? tip "Vihje PATH:iin"
    
        `ln -s /app/jotain.sh /usr/local/bin/jotain`

    Alla esimerkki asennuksen ja kummankin sovelluksen toiminnasta. Komentojen väliin on lisätty tyhjä rivi lukemisen helpottamiseksi:

    ```plaintext title="🐳 Bash"
    root$ /app/remind_install.sh
    [INFO] Added remember and remind commands to /usr/local/bin
    
    root$ remember
    Enter note (quit with empty note)
    >>> Buy egg
    >>> Buy ham
    >>> Buy sausage
    >>> ???
    >>> Profit
    >>>
    
    root$ remind
    Your reminders are as follows:
    [1738583804]	Buy egg
    [1738583806]	Buy ham
    [1738583809]	Buy sausage
    [1738583814]	???
    [1738583815]	Profit
    ```
    
    Komennoissa on UNIX-timetamp eli sekunteja 1970-luvun alusta, joten olisi täysin mahdollista toteuttaa ohjelma, joka poistaa yli n viikkoa vanhat muistutukset. Vaihtoehtoisesti olisi tehtävissä menu, joka kysyy, mitkä muistutukset halutaan poistaa. Emme kuitenkaan toteuta näitä tässä tehtävässä.

??? question "Tehtävä: Staattinen analyysi (Shellcheck)"

    Latasit aiemmassa luvussa `readbash.sh`-skriptin. Ota siitä ja [ShellCheck GitHub repositoriosta](https://github.com/koalaman/shellcheck) mallia. Luo skripti, jolla voit ajaa ShellCheckin valitsemillesi skripteille. 
    
    Ehdot:
    
    * Hyödyntää `shellcheck:stable`-imagea Docker Hubista.
    * On ajettavissa alla näkyvän docsin examplejen mukaisesti

    Nice-to-have:

    * Värit tulostuvat oikein, jotta output on helpompi lukea.

    ```bash title="static.sh"
    #!/bin/bash
    #: Title        : static.sh
    #: Date         : 202x-xx-xx
    #: Author       : xxx xxxxx
    #: Version      : 1.0
    #: Description  : Static code analysis for bash scripts.
    #
    #: Options      : [script_name(s)]
    #
    #: === Examples ====
    #:   static.sh scripts/*.sh
    #:   static.sh scripts/foo.sh
    #:   static.sh scripts/foo.sh scripts/bar.sh
    #:   static.sh scripts/{foo,bar}.sh

    # ... IMPLEMENT !
    ```

??? question "Tehtävä: Korjaa skriptit"

    Aja yllä luomasi skripti kaikkia `scripts/`-hakemiston skriptejä vasten – eli testaa kaikki kurssin skriptit. Korjaa virheet, joita ShellCheck löytää. Löydät virheistä lisätietoa [ShellCheck Wikistä](https://www.shellcheck.net/wiki/SC2162). Korvaa urlissa viimeinen `SCxxxx`-osa oikealla virhekoodilla.

    Ota samalla tavoitteeksi ajaa jatkossa kaikki skriptisi ShellCheckin läpi ennen kuin päästät niitä käsistäsi. Huomaa, että ShellCheck ei palauta mitään, jos skripti on virheetön.
