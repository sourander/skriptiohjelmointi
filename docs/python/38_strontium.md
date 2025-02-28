---
priority: 338
---

# 🎆 Strontium

## Tärpit

### Format Operator

TODO (f-string)

## Mukavuus

### Visual Studio Coden käyttö

!!! warning

    Mukavuus-otsikon alla on oletus, että sinulla on käytössä Visual Studio Code, Python Extension ja lokaalisti asennettu Python 3.1x.

#### Venv

Kun luot uudet Python-projektin Visual Studio Codessa, sinulla voi olla tarve asentaa joitakin moduuleita. Olet jo aiemmin oppinut, että Debian-pohjaisessa ympäristössä on `dist-packages`-hakemisto, jossa on esimerkiksi `requests`-moduuli asennettuna. Jos olet jossakin toisesssa käyttöjärjestelmässä tai jakelussa, se voi hyvin puuttua sinulta. Tässä tapauksessa tarvitset virtuaaliympäristön.

Virtuaaliympäristö kuulostanee monimutkaiselta, mutta käytännön tasolla se on **kopio Python-asennuksesta**. 

Voit luoda sen seuraavalla tavalla Terminaalissa:

```bash title="🖥️ Bash"
# Jos käytät OS:n omaa Pythonia
$ python3 -m venv .venv

# Jos sinulla on uv asennettuna
$ uv venv
```

??? warning "Muista Git Ignore!"

    Ethän unohda lisätä kyseistä hakemistoa `.gitignore`-tiedostoon, jotta se ei päädy versionhallintaan! Se on kopio Pythonista, joten se sisältää satoja binääritiedostoja, jotka eivät todellakaan kuulu versionhallintaan. Kukin käyttäjä luo oman virtuaaliympäristönsä itse.

    Lisää siis seuraava rivi `.gitignore`-tiedostoon:

    ```plaintext
    .venv/
    ```

    Tarkista, että tiedostoja ei näy versionhallinnassa komennolla `git status -u`.

![](../images/py-vscode-venv-created-popup.png)

**Kuva 1:** *Visual Studio Code ilmoittaa, että se on havainnut uuden virtuaaliympäristön, ja tarjoaa sinun valita sen kyseistä worskpacea varten. Klikkaa **Yes**. Jos tämä popup menee sivulta ohi syystä tai toisesta, voit valita Workspace-kohtaisen virtuaaliympäristön painamalla `F1` ja kirjoittamalla `Python: Select Interpreter`. Kenttään voi kirjoittaa relatiivisen polun projektin uudesta esimerkiksi näin: `${workspaceFolder}/python/.venv/`.*

#### Intellisense

Aivan kuten PowerShell, myös Python on hyvin vahvasti *object-oriented* -kieli. Tämä tarkoittaa, että Pythonissa kaikki on objekteja, ja objekteilla on metodeja ja ominaisuuksia. Olet jo kokeillut samaa ominaisuutta PowerShellin kanssa, mutta kokeile uusiksi Pythonin kanssa. Luo esimerkiksi seuraava skripti:

```python title="testing_context_menu.py"
name = "John Anderton"
name
```

Kun lisäät sanan `name` perään vielä pisteen, aukeaa lista objektin metodeista ja ominaisuuksista. Kokeile esimerkiksi `name.upper()`. Jos lista ei aukea, paina ++ctrl+space++.

!!! tip "🍎 macOS"

    Sama pikanäppäin on ++fn+ctrl+space++

#### Run Selection

Joskus voi olla tarpeen ajaa valittu koodinpätkä lokaalin koneen terminaalissa. Kenties haluat nopeasti kokeilla, kuinka keskellä pitkää skriptiä määritelty funktio toimii ajamatta muuta koodia? Tämä onnistuu Visual Studio Codessa valitsemalla koodinpätkä ja painamalla ++shift+enter++. Vaiheoehtoinen tapa on context menu. Klikkaa hiiren oikealla korvalla valittuja koodirivejä, valitse **Run Python >** ja **Run Selection/Line in Python Terminal**.

![](../images/py-vscode-run-in-terminal.png)

**Kuva 2:** *Skripistä on valittuna vain yksi funktio, `function_i_wanna_test`, ja se ajetaan terminaalissa.*

Kun ajat koodin näin, huomaat, että alle Terminal-kohtaan ilmestyy uusi **Python**-niminen terminaali, jossa koodi suoritetaan REPL-tilassa. Tämä on vastaava tapa kuin ajaa aiemmin näkemäsi `python -i scripts/some.py`, mutta voit valita juuri ne rivit, jotka haluat suoritettavaksi. Kuten alla olevasta snippetistä näet, funktio on jatkossa kutsuttavissa kyseisessä terminaalissa.

```python-console title="🖥️ Python REPL (VS Code Terminal)"
>>> function_i_wanna_test([1,2,3,4,5,6], 3)
([1, 2], [3, 4, 5, 6])
```

## Tehtävät

??? question "Tehtävä: Arvaa numero"

    Luo ohjelma, joka generoi luvun väliltä 1-1000 ja pyytää käyttäjää arvaamaan sen. Ohjelma antaa vihjeen, onko arvattu luku suurempi vai pienempi kuin generoitu luku. Ohjelma lopettaa, kun käyttäjä arvaa oikein. Olet tehnyt ohjelman jo aiemmin (Bash ja PowerShell), joten voit lainata sieltä logiikan.

    ```console
    $ ./runpy.py scripts/arvaaluku.py
    Arvaa luku väliltä 1-1000.
    Muu syöte kuin positiviinen kokoluku poistuu ohjelmasta.

    Syötä arvaus:
    9
    📉 Luku on pienempi kuin 9.

    Syötä arvaus:
    7
    📈 Luku on suurempi kuin 7.

    Syötä arvaus:
    8
    🎉 Oikein! Arvasit luvun 8. (Peliaika: 0h 4m 18s)
    ```

    Varmista, että pelaaja voi halutessaan lopettaa pelin. Minun toteutuksessa mikä tahansa muu syöte kuin kokonaisluvuksi parsittava syöte lopettaa pelin (esim. exit tai tyhjä merkkijono).

    !!! note "⚠️ TÄRKEÄÄ"

        Kirjoita ohjelman `input()` ilman promptia. Anna prompti erillisellä print-komennolla. Tämä helpottaa kurssin myöhempää tehtävää, jossa rakennamme skriptin, joka pelaa peliä meidän puolestamme. Eli siis:

        ```python
        # ⛔️ Ei näin
        guess = input("Guess a number: ")

        # ✅ Vaan näin
        print("Guess a number: ")
        guess = input()
        ``` 

!!! question "Tehtävä: Reminder"

    TODO.

??? question "Lisätehtävä: breakpoint()"

    Koska käytämme Visual Studio Codea, voimme käyttää sen interaktiivista debuggeria CLI-pohjaisen Pdb:n (Python Debugger) sijasta. Tämän käyttö esitellään läsnätunneilla.

    On kuitenkin suositeltavaa kokeilla Pdb:tä lyhyesti ihan sivistyksen tähden. Yksi tapa aktivoida se on sijoittaa skriptiisi seuraava rivi:

    ```python
    breakpoint()
    ```

    Koodi pysäyttää suorituksen kyseiseen kohtaan ja avaa Pdb:n. Tässä tilassa ei ole tarkoitus kirjoittaa interaktiivisesti Pythonia vaan tarkkailla muuttujien arvoja esimerkiksi looppia ajettaesa.

    ```python title="breakpoint_practice.py"
    #!/usr/bin/env python3

    n = 5
    counter = 0

    for i in range(n):
        breakpoint()
        counter += 1
    ```

    ```console
    $ ./runpy.py scripts/breakpoint_practice.py
    (Pdb) p counter
    0
    (Pdb) continue
    > /app/scripts/breakpoint_practice.py(8)<module>()
    -> counter += 1
    (Pdb) p counter
    1
    ```
    
    Debuggerissa toimivat muiden muassa seuraavat komennot [^pdb]:

    [^pdb] Python Docs. The Python Debugger. https://docs.python.org/3/library/pdb.html

    **Peruskomennot**

    | Komento      | Kuvaus                                          |
    | ------------ | ----------------------------------------------- |
    | `h(elp)      | Näytä ohjeet (eli kaikki nämä komennot)         |
    | `q(uit)      | Poistu debuggerista                             |
    | `c(ontinue)` | Jatka suoritusta seuraavaan breakpointtiin asti |
    | `n(ext)`     | Suorita seuraava rivi (astu funktiokutsun yli)  |
    | `s(tep)`     | Astu funktiokutsuun                             |
    | `r(eturn)`   | Suorita loppuun nykyinen funktio                |
    

    **Tarkastelu**

    | Komento   | Kuvaus                                       |
    | --------- | -------------------------------------------- |
    | `l(ist)`  | Näytä koodi breakpointin läheisillä riveillä |
    | `p expr`  | Tulosta lausekkeen arvo                      |
    | `pp expr` | Tulosta lausekkeen arvo (prettify)           |
    | `whatis`  | Näytä lausekkeen tyyppi                      |

    Lauseke (engl. expression) on usein muuttuja, mutta voi olla myös esimerkiksi funktio tai moduuli.
