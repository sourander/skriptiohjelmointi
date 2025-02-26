---
priority: 338
---

# 🎆 Strontium

## Tärpit

### Format Operator

TODO (f-string)

## Mukavuus

### Visual Studio Coden käyttö

TODO Python extension jne.

## Tehtävät

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
