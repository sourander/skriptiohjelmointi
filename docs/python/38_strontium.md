---
priority: 338
---

# 🎆 Strontium

## Tärpit

### Format Operator

Pythonin f-string on tehokas tapa formatoida merkkijonoja. Se on ollut käytössä Python 3.6:sta lähtien. F-stringin avulla voit lisätä muuttujia suoraan merkkijonoon. F-stringin tunnistaa siitä, että merkkijonon alkuun tulee `f`-kirjain. Esimerkiksi:

```python
name = "John"
age = 42

print(f"My name is {name} and I am {age} years old.")
```

Huomaa, että yksinkertaisen muuttujan ujuttamisen lisäksi f-string sallii uskomattoman määrän muotoilua, ja tyypillisen Python-lausekkeen käytön. Esimerkiksi:

```python
print(f"2 + 2 = {2 + 2}")
print(f"216 can be written as hex {216:X} and as binary {216:b}")
```

Voit tutustua tähän muotoiluun [Python f-string cheat sheets](https://fstring.help/cheat/) -sivuston avulla tai suoraan [Python Docs: String > Format String Syntax](https://docs.python.org/3/library/string.html#format-string-syntax).

## Mukavuus

### Visual Studio Coden käyttö

Mukavuus-otsikon alla on oletus, että sinulla on käytössä Visual Studio Code, Python Extension ja lokaalisti asennettu Python 3.1x. Python voi olla Ubuntun mukana tullut, Python.org-sivustolta ladattu, [uv](https://docs.astral.sh/uv/)-työkalulla asennettu tai jokin muu. Tärkeintä on, että Python on lisätty käyttöjärjestelmäsi PATH:iin ja on täten ajettavissa terminaalista komennolla `python` tai `python3`.

#### Venv

!!! warning

    Pythonin virtuaaliympäristöt eivät ole maailman helpoin aihe. Tulethan läsnätunneille paikalle, jotta saat tähän tukea ja neuvoja!

Kun luot uudet Python-projektin Visual Studio Codessa, sinulla voi olla tarve asentaa joitakin moduuleita. Olet jo aiemmin oppinut, että Debian-pohjaisessa ympäristössä on `dist-packages`-hakemisto, jossa on esimerkiksi `requests`-moduuli asennettuna. Jos olet jossakin toisesssa käyttöjärjestelmässä tai jakelussa, se voi hyvin puuttua sinulta. Tässä tapauksessa tarvitset virtuaaliympäristön.

Virtuaaliympäristö kuulostanee monimutkaiselta, mutta käytännön tasolla se on **kopio Python-asennuksesta**. 

Voit luoda sen seuraavalla tavalla:

=== "uv"

    Jos sinulla on [uv](https://docs.astral.sh/uv/), käytä ihmeessä sitä! Uv toimii Windowsissa, Linuxissa ja macOS:ssä samoin tavoin.

    ```bash title="🖥️ Bash"
    # Varmista, että olet projektisi hakemistossa
    $ cd mene/sinun/projektisi/hakemistoon
    
    # Asenna haluamasi Python
    $ uv install 3.12
    $ uv venv --python 3.12

    # Asenna virtuaaliympäristöön requests
    $ uv pip install requests

    # Aja uv:n hallinnoima Python
    $ uv python scripts/hello.py
    ```

=== "Ubuntu"

    Jos sinulla on käytössäsi Ubuntu, sen mukana tulee Python 3.xx. Uv on mukava työkalu, mutta vaihtoehtoisesti voit luoda virtuaaliympäristön seuraavasti.

    ```bash title="🖥️ Bash"
    # Varmista, että olet projektisi hakemistossa
    $ cd mene/sinun/projektisi/hakemistoon

    # Luo virtuaaliympäristö
    $ python3 -m venv .venv

    # Aktivoi virtuaaliympäristö 
    $ source .venv/bin/activate

    # Asenna haluamasi moduulit
    (.venv) $ pip install requests

    # Aja Python
    (.venv) $ python scripts/hello.py

    # Deaktivoi virtuaaliympäristö
    (.venv) $ deactivate
    ```

=== "Windows"

    Jos sinulla on Windowsiin asennettuna Python 3.xx, etkä halua jostain syystä asentaa uv:ta, aja seuraavat komennot.

    ```pwsh-session title="🖥️ PowerShell"
    # Varmista, että olet projektisi hakemistossa
    PS> cd mene/sinun/projektisi/hakemistoon

    # Suositeltu: kiellä pip:n käyttö virtuaaliympäristön ulkopuolella
    PS> pip3 config set global.require-virtualenv true

    # Luo virtuaaliympäristö
    PS> python3 -m venv .venv

    # Aktivoi virtuaaliympäristö
    PS> .venv\Scripts\Activate.ps1

    # Asenna haluamasi moduulit
    (.venv) PS> pip install requests

    # Aja Python
    (.venv) PS> python scripts/hello.py

    # Deaktivoi virtuaaliympäristö
    (.venv) PS> deactivate
    ```



!!! warning "Muista Git Ignore!"

    Ethän unohda lisätä kyseistä hakemistoa `.gitignore`-tiedostoon, jotta se ei päädy versionhallintaan! Se on kopio Pythonista, joten se sisältää satoja binääritiedostoja, jotka eivät todellakaan kuulu versionhallintaan. Kukin käyttäjä luo oman virtuaaliympäristönsä itse.

    Lisää siis seuraava rivi `.gitignore`-tiedostoon:

    ```plaintext
    .venv/
    ```

    Tarkista, että tiedostoja ei näy versionhallinnassa komennolla `git status -u`.

Huomaa, että on kaksi eri asiaa: käyttää virtuaaliympäristöä shell-istunnossa ja Visual Studio Coden GUI:ssa. Visual Studio Code yleensä havaitsee, jos luot virtuaaliympäristön, mutta ei aina. Visual Studio Code saattaa myös jatkossa aktivoida sen automaattisesti shell-istuntoon, mutta tämä riippuu asetuksesta:

```json title="$HOME/.config/Code/User/settings.json"
{
    // ...
    "python.terminal.activateEnvironment": false,
    // ...
}
```

Sen sijaan VS Coden GUI-editorin, eli ei siis integroidun terminaalin, käyttämä Python on valittavissa painamalla `F1` ja kirjoittamalla `Python: Select Interpreter`. Yleensä VS Code avaa alla näkyvän (ks. Kuva 1) pop-up -ikkunan ruudun oikeaan alalaitaan kun olet luonut virtuaaliympäristön. ==Jos tämä popup menee sinulta ohi== syystä tai toisesta, voit valita Workspace-kohtaisen virtuaaliympäristön painamalla `F1` ja kirjoittamalla `Python: Select Interpreter`. Kenttään voi kirjoittaa relatiivisen polun projektin uudesta esimerkiksi näin: `${workspaceFolder}/python/.venv/`. Tämä polun käsin kirjoittaminen on tarpeen vain, jos executable on jossakin muualle kuin avoinna olevan kansion juuressa (kuten `python/.venv` eikä `.venv/`).

![](../images/py-vscode-venv-created-popup.png)

**Kuva 1:** *Visual Studio Code ilmoittaa, että se on havainnut uuden virtuaaliympäristön, ja tarjoaa sinun valita sen kyseistä worskpacea varten. Klikkaa **Yes**.*

#### Intellisense

Aivan kuten PowerShell, myös Python on hyvin vahvasti *object-oriented* -kieli. Tämä tarkoittaa, että Pythonissa kaikki on objekteja, ja objekteilla on metodeja ja ominaisuuksia. Olet jo kokeillut samaa ominaisuutta PowerShellin kanssa, mutta kokeile uusiksi Pythonin kanssa. Luo esimerkiksi seuraava skripti:

```python title="testing_context_menu.py"
name = "John Anderton"
name
```

Kun lisäät sanan `name` perään vielä pisteen, aukeaa lista objektin metodeista ja ominaisuuksista. Kokeile esimerkiksi `name.upper()`. Jos lista ei aukea, paina ++ctrl+space++. Huomaa, että IntelliSense käyttää sitä Python-versiota, joka on valittu Visual Studio Codessa. Tämä neuvotaan yllä.

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

??? question "Tehtävä: breakpoint()"

    Koska käytämme Visual Studio Codea, voimme käyttää sen interaktiivista debuggeria CLI-pohjaisen Pdb:n (Python Debugger) sijasta. Tämän käyttö esitellään läsnätunneilla. On kuitenkin suositeltavaa kokeilla Pdb:tä lyhyesti ihan sivistyksen tähden. Vastaavia työkaluja löytyy myös muista kielistä, kuten Pdb:n esikuva GDB, joka voi käyttää useissa kielissä: C, C++, Rust ja moni muu.
    
    Yksi tapa aktivoida Pdb on sijoittaa skriptiin alla olevassa code snippetissä oleva rivi. Rivin voi tarpeen mukaan ujuttaa useisiin paikkoihin, jolloin debuggeri pysähtyy jokaisen rivin kohdalla.

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

!!! question "Tehtävä: IP Address"

    TODO. (Parsitaan IP-osoitteita built-in ipaddress-moduulilla)