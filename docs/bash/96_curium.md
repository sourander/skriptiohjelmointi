---
priority: 196
---

# 👩‍🔬 Curium


## Listat

Ennen kuin siirrymme viimeiseen Einsteinium-osuuteen, harjoitellaan vielä hieman listoja. Listat ovat tärkeitä, koska niitä käytetään usein silmukoiden yhteydessä. Listoja käsitellään usein myös argumentteina skripteille. On kovin tyypillistä, että sinun pitää tavalla tai toisella parsia kaikkia argumentteja, eli: `$@`, jonka osatekijöitä ovat `$1`, `$2`, `$3`, jne. Alla olevissa tehtävissä tähän tutustutaan parin rautakoodatun, helpomman esimerkin kautta.

## Funktiot

Listojen lisäksi on syytä opetella funktioiden käyttöä. Funktiot auttavat pitämään koodisi modulaarisena ja helposti luettavana. Funktiot ovat myös hyvä tapa välttää toistoa koodissasi. 

Funktiot ovat myös hyvä tapa testata koodiasi, koska voit testata yksittäisiä funktioita erikseen. Tämä on erityisen hyödyllistä, jos koodisi on monimutkaista ja sisältää paljon reunaehtoja.

## Tehtävät

??? question "Tehtävä: Pilkulla erottelu"

    Luo skripti, joka tulostaa luvut 1-10 pilkulla eroteltuna. Skriptin pitää alkaa näin:
    
    ```bash title="pilkkuerotellut.sh"
    #!/bin/bash
    numbers=({1..10})
    ```
    
    Lopputuloksena tulisi tulostaa:

    ```plaintext title="🐳 stdout"
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10
    ```


    ??? vihje "Vihje 1"

        Sijoita väliaikaiseen muuttujaan jotain, mitä seuraava tulostaa:

        ```bash
        printf ", %s" "${numbers[@]}"
        ```

    ??? vihje "Vihje 2"

        Huomasit kaiketi, että yllä neuvottu komento jättää komennon alkuun pilkun ja välilyönnin. Voit jättää nämä kaksi ensimmäistä merkkiä, eli `, ` tulostamatta käyttämällä `${parameter:offset}` parameter expansion syntaksi: 
        
        ```bash
        echo ${muuttuja:2}
        ```

??? question "Tehtävä: Pizzatäytteet"

    Luo skripti, jonka alussa määritellään rautakoodatut muuttujat alla olevan `pizza.sh`-esimerkin mukaisesti. Huomaa, että nimeä, ikää ja suosikkitäytteitä pitää voida muuttaa. Täytteitä on aina vähintään kaksi.

    ```bash title="pizza.sh"
    #!/bin/bash
    name='Black Knight'
    age=42
    fav_toppings=("egg" "sausage" "spam")
    ```

    Tavoite on tulostaa seuraava lause:
    
    ```plaintext title="🐳 stdout"
    Black Knight is 42 years old and likes pizza with egg, sausage, and spam.
    ```

    Huomaa, että täytteiden tulee olla pilkkueroteltuja kahden viimeisen välissä kuuluu olla sana "and". Toiseksi viimeisen täytteen perässä saa joko olla pilkku tai ei - päätä itse (eli ns. Oxford comma 🧐).
    ??? tip "Vihje"

        Kenties helpoin ratkaisu ymmärtää on *string concatenation*-tyyli, jossa ainekset ynnätään merkkijonoon. Käytä `for`-silmukkaa, jossa rakennat pilkkuerotellun täytelistan yksi täyte kerrallaan. Huomaa, että tehtävän voi ratkaista myös aivan toisin.

        ```bash
        for ingredient in "${fav_toppings[@]}"; do
            # IMPLEMENT if-else string concatenation here.

            n_toppings=$((n_toppings-1))
        done

        echo "${name} is ${age} years old and likes pizza with ${comma_topping}."
        ```

??? question "Tehtävä: Päivämäärän analysointi"

    Luo skripti, joka analysoi skriptin ajopäivästä seuraavat asiat:

    * Pariton vai parillinen päivämäärä
    * Onko vuosi karkausvuosi
    * Kuinka monta päivää on jouluaattoon?

    Käytä apuna funktioita, jotta koodi pysyy modulaarisena ja helposti luettavana. Vältä pitkää "wall of text" -tyylistä koodia. Koodin runko voi myötäillä esimerkiksi alla olevaa rakennetta:

    ```bash title="dateinfo.sh"
    #!/bin/bash
    
    # Define functions here
    is_odd() {
        local today
        local number

        today=$1
        number= # IMPLEMENT

        # IMPLEMENT
        echo Something
    }

    # ... more functions here ...

    # Wrapper function
    main() {
        # Declare
        local default_date
        local today

        # Assign
        default_date=$(date +%Y-%m-%d)
        today=${1:-$default_date}

        # Call
        is_odd "$today"
        # is_leap_year "$today"
        # n_days_till_xmas "$today"
    }

    main "$@"
    ```

    Skriptiä voi jatkossa kutsua argumentilla tai ilman. Alla kaksi esimerkkiä, joista alempi on ajettu 7. helmikuuta 2025.

    ```bash title="🖥️ Bash"
    ./runbash.sh sripts/dateinfo.sh 1600-02-29
    ```

    ```plaintext title="🐳 stdout"
    [INFO] Tänään on 1600-02-29
    [INFO] Päivämäärä on pariton. 🦄
    [INFO] Karkausvuosi! 366 päivää! 🎉
    [INFO] Päiviä jouluaattoon: 299 🎅
    ```

    ```bash title="🖥️ Bash"
    ./runbash.sh sripts/dateinfo.sh
    ```

    ```plaintext title="🐳 stdout"
    [INFO] Tänään on 2000-02-29
    [INFO] Päivämäärä on pariton. 🦄
    [INFO] Karkausvuosi! 366 päivää! 🎉
    [INFO] Päiviä jouluaattoon: 299 🎅
    ```

    ??? note "Lisähaastetta?"

        Validoi päivämäärä, jonka käyttäjä antaa argumenttina. Voit esimerkiksi tarkistaa, että se noudattaa muotoa `yyyy-mm-dd`, ja että `date`-binääri saa sen parsittua (eli ei palauta error return codea).

    ??? note "Vielä lisää lisähaastetta?"
    
        Voit halutessasi toteuttaa itsellesi lisähaasteena testejä. Tämä vaatisi, että esimerkiksi virheherkkä karkausvuoden logiikka on testattuna kohtalaisen systemaattisesti. Tämä vaatii, että funktio `is_leap_year` palauttaa exit coden: `1` jos vuosi on karkausvuosi ja `0` jos ei. Tämä exit code voidaan sitten tarkistaa testissä.

        ```bash
        test_leap_year() {
            is_leap_year "$1" 0
            local result=$?
            local expected=$2
            if (( result != expected )); then echo "Failed $1 (${result})"; exit 1; fi
        }
        ```

        Tämän jälkeen voit ajaa testejä esimerkiksi ennen main-funktion kutsua:

        ```bash
        test_leap_year 1600-01-01 1
        test_leap_year 1700-01-01 0
        test_leap_year 2023-01-01 0
        test_leap_year 2024-01-01 1
        test_leap_year 2025-12-31 0
        test_leap_year 2026-01-01 0
        test_leap_year 2027-01-01 0
        test_leap_year 2028-01-01 1
        main "$@"
        ```

        Tämä on kuitenkin lisähaaste. Jos tämä tuntuu mahdottomalta, keskity muuhun.

??? question "Tehtävä: Swap"

    Luoda ohjelma, joka auttaa sinua tilanteessa, jossa olet vahingossa kirjoittanut kahden eri tiedoston sisällöt ristiin. Toisin sanoen haluat vaihtaa tiedostot päikseen. Miten tämä onnistuu?

    Käyttö (kontin sisällä):

    ```bash title="🐳 Bash"
    echo "I think I'm A" > b.txt   # note wrong content
    echo "I think I'm B" > a.txt
    /app/scripts/swap.sh tiedosto1.txt tiedosto2.txt
    cat a.txt
    ```

    ```plaintext title="🐳 stdout"
    I think I'm A
    ```

    ??? tip "Vihje"

        Käytä komentoa `mktemp` avuksesi. Tutustu sen ohjeisiin: [Ubuntu Manuals: mktemp](https://manpages.ubuntu.com/manpages/noble/en/man1/mktemp.1.html).