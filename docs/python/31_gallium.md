---
priority: 331
---

# 💡 Gallium


## Avainsanat

Aivan kuten Bashissä ja PowerShellissä, myös Pythonissa on varattuja sanoja, joita ei voi käyttää muuttujaniminä. Tässä on lista niistä:

```plaintext
False     None      True      and       as
assert    async     await     break     class
continue  def       del       elif      else
except    finally   for       from      global
if        import    in        is        lambda
nonlocal  not       or        pass      raise
return    try       while     with      yield
```

Lisäksi on sisäänrakennettuja funktioita, joita toki *voit* käyttää muuttujaniminä, mutta jyräät sivuoireena Pythonin toiminnallisuuksia. Tämä ei siis ole suositeltavaa. Näitä ovat:

```plaintext
abs           aiter         all           anext         any           ascii
bin           bool          breakpoint    bytearray     bytes         callable
chr           classmethod   compile       complex       copyright     credits
delattr       dict          dir           display       divmod        enumerate
eval          exec          execfile      filter        float         format
frozenset     get_ipython   getattr       globals       hasattr       hash
help          hex           id            input         int           isinstance
issubclass    iter          len           license       list          locals
map           max           memoryview    min           next          object
oct           open          ord           pow           print         property
range         repr          reversed      round         runfile       set
setattr       slice         sorted        staticmethod  str           sum
super         tuple         type          vars          zip
```

??? tip "Kuinka tulostettiin?"

    Yllä olevat listat on tulostettu seuraavalla skriptillä.

    ```python
    import keyword
    import builtins

    def print_as_tabular(words:list[str], columns:int=5, margin:int=2):

        # Calculate variables
        column_width = max([len(x) for x in words]) + margin

        # Loop and print
        for batch in range(0, len(words), columns):
            row_words = words[batch:batch + columns]
            for word in row_words:
                print(f"{word:<{column_width}}", end="")
            print()
        print()


    # Print the reserved keywords
    print_as_tabular(keyword.kwlist)

    # Print the built-ins
    low_case_builtins = [x for x in dir(builtins) if x[0].islower()]
    print_as_tabular(low_case_builtins, columns=6)
    ```

## Tärpit

## Muuttujat

Koko totuus löytyy Pythonin dokumentaatiosta (esim. [Built-In Types](https://docs.python.org/3/library/stdtypes.html)), mutta alla on pikaohje, jolla pääset alkuun.

### Dynaaminen

Aivan kuten PowerShell, myös Python dynaamisesti tyypitetty kieli. Alla oleva esimerkki on sinulle hyvinkin tuttu PowerShellin puolelta:

```python
x = 1                 # Kokonaisluku (class 'int')
x = 3.12              # Liukuluku (class 'float')
x = "abc"             # Merkkijono (class 'str')
x = [1, 2, 3]         # Lista (class 'list')
x = (1,2,3)           # Tuple (class 'tuple')
x = {1,2,3}           # Set (class 'set')
x = {"a": 1, "b": 2}  # Sanakirja (class 'dict')
x = True              # Boolean (class 'bool')
x = None              # NoneType (class 'NoneType')
```

KAMK:n opiskelijana olet käynyt mitä todennäköisimmin Python Perusteet -kurssin, joten näiden pitäisi olla sinulle tuttuja tyyppejä. Jos et ole varma, niin suosittelen kertaamaan materiaalia. Erityisesti listan, tuplen ja setin ero on hyvä tunnistaa, koska ne muistuttavat toisiaan, mutta eroavat käyttötarkoitukseltaan.

### Tyypittäminen

Python ja PowerShell eroavat merkittävästi toisistaan tyypityksen ja tyypin vaihtamisen suhteen. Muistat toivon mukaan PowerShellistä, että muuttujan voi pakottaa tiettyyn tyyppin kirjoittamalla tyypin hakasulkeisiin ennen muuttujaa (esim. `[int]$x = "42"`). Pythonissa on vastaava syntaksi, mutta se on vain *type hint* dokumentaatiota varten, ei pakottava tyypitys. Alla esimerkki:

```python-console title="Python REPL"
>>> x: int = 42
>>> x = "thingy"
>>> type(x)
<class 'str'>
```

!!! tip "🦆 Terminologia"

    Termi, jota käytetään Pythonin äärimmäisen liberaalista tyypityksestä, on *duck typing*. Lause, johon kenties olet jo törmännyt, määrittelee sen näin: *If it looks like a duck, swims like a duck, and quacks like a duck, then it probably is a duck*.

Pythonin tyypitys on siis vapaaehtoista, mutta se ei tarkoita, että sitä ei kannattaisi käyttää. Kevyimmillään kannattaa määrittää *type hinting* tyylillä. Käyttämäsi IDE, kuten Visual Studio Code lisäosineen, osaa hyödyntää tätä tietoa ja tarjota parempaa koodiautomaatiota ja -tarkistusta.

```python title="⛔️ Ei näin"
def add(a, b):
    return a + b

a = 2
b = 3
print(add(a, b))
```

```python title="✅ Näin"
def add(a: int, b: int) -> int:
    return a + b

a: int = 2
b: int = 3
print(add(a, b))
```

### Ulkoista apua

Dynaaminen tyypitys ei ole kaikkien mieleen, ja se altistaa koodin virheille, jotka voitaisiin havaita staattisella tyypityksellä. Tyyppivirheisiin perustuvat bugit ovat usein vaikeita löytää ja korjata. Tämän vuoksi on olemassa työkaluja, jotka tarkistavat koodin tyypityksen ennen sen suorittamista. Visual Studio Codessa on Microsoftin ylläpitämä ja täten hyvinkin virallinen lisäosa [Python](https://marketplace.visualstudio.com/items?itemName=ms-python.python), jonka mukana asentuu vakiona [Pylance](https://marketplace.visualstudio.com/items?itemName=ms-python.vscode-pylance). Jälkimmäisen voi vaihtaa sen tuoreeseen kilpailijaan nimeltään Ruff tai mypy.

Tutustumme Visual Studion Coden asetuksiin tarkemmin live-tunneilla. Tässä materiaalissa neuvotaan työkalujen käyttö Dockerin avulla yhtä skriptiä vasten.

Aloitetaan työkalulla nimeltään **mypy**.

```bash
# Run mypy against a single script
docker run --rm -v $(pwd):/data:ro cytopia/mypy scripts/hello_turbo.py

# Or maybe with a strict mode to be more pedantic
docker run --rm -v $(pwd):/data:ro cytopia/mypy --strict scripts/hello_turbo.py
```

Tuore haastaja Python-ekosysteemissä on Astral, jonka työkalu Ruff toimii sekä linterinä että formatterina. Linter tarkistaa koodin virheistä ja formatter muotoilee koodin yhtenäiseen tyyliin. Sitä voit käyttää Dockerin kautta näin:

```bash
# Tarkista virheet
docker run --rm -v $(pwd):/io ghcr.io/astral-sh/ruff:latest check scripts/hello_turbo.py

# Korjaa automaattisesti virheet (1)
docker run --rm -v $(pwd):/io ghcr.io/astral-sh/ruff:latest check scripts/hello_turbo.py --fix

# Muotoile teksti vakiotyyliin
docker run --rm -v $(pwd):/io ghcr.io/astral-sh/ruff:latest format scripts/hello_turbo.py
```

!!! warning

    Ruff-komennot ajetaan ilman `:ro` eli *read-only* volumea. Ruff tarvitsee kirjoitusoikeudet muokatakseen tiedostoa ja luodakseen väliaikaisia tiedostoja. Nämä tiedostot ilmestyvät `.ruff_cache`-hakemistoon. Kylkiäisenä tulee `.gitignore`-tiedosto, joka estää näiden tiedostojen päätymisen versionhallintaan.

## Vianetsintä

### Print

Bashistä ja PowerShellistä tuttu `echo`-komennon vastine Pythonissa on `print`. Hyvin primitiivinen, mutta silti tehokas tapa debugata koodia on tulostaa muuttujien arvoja konsoliin.

```python
user_input = input("Give me a number: ")
print(f"User input was: {user_input}")
```

### Assert

On tilanteita, joissa haluat skriptin kaatuvan, jos jokin ehto ei täyty. Tämä onnistuu `assert`-lausekkeella. Alla esimerkki:

```python
x = 1
assert x == 2, "x should be 2"
```

### Logging

Toivon mukaan muistat yhä PowerShellin puolelta eri virrat, joihin pystyy kirjoittamaan viestejä. Pythonissa vastaava toiminnallisuus löytyy `logging`-moduulista. Alla esimerkki:

```python title="logger_practice.py"
import logging
import random


def pick_random_level() -> int:
    level = random.choice(
        [
            logging.DEBUG,
            logging.INFO,
            logging.WARNING,
            logging.ERROR,
            logging.CRITICAL,
        ]
    )

    name = logging._levelToName[level]
    print(f"Randomly chosen level: {name} (no. {level})")
    return level


# Set the logging level and format
rnd_level = pick_random_level()
FORMAT: str = "%(asctime)s - %(levelname)s - %(message)s"
logging.basicConfig(level=rnd_level, format=FORMAT, datefmt="%H:%M:%S")

# Call each level once
logging.critical("DON'T PANIC!")
logging.warning("It worked on my machine...")
logging.error("Have you tried turning it off and on again?")
logging.info("Must be a cosmic ray. Try running it again.")
logging.debug("I'm sure it's just a typo.")
```

Skripti arpoo satunnaisen loggaustason ja tulostaa viestin jokaisella tasolla. Vain valitun tason ylittävät viestit tulostuvat konsoliin. Alla esimerkki skriptin ajosta:

```console
$ ./runpy.py scripts/logger_practice.py
Randomly chosen level: INFO (no. 20)
11:24:23 - CRITICAL - DON'T PANIC!
11:24:23 - WARNING - It worked on my machine...
11:24:23 - ERROR - Have you tried turning it off and on again?
11:24:23 - INFO - Must be a cosmic ray. Try running it again.
```

## Tehtävät

??? question "Tehtävä: Devausympäristö ja runpy.py"

    Loit ajo aiemmassa tehtävässä `python/`-hakemiston, jotta sait kopioitua skriptin avulla virtuaalikoneesta kaikki Python-srkriptit sinun host-koneellesi. Jatketaan saman hakemiston käyttöä, mutta Multipass-koneen sijaan käytetään Docker-konttia. Lisäksi Bash-skriptin sijasta käytämme Python-skriptiä. Vaiheet:

    1. Lataa [gh:sourander/skriptiohjelmointi/scripts/runpy.py](https://raw.githubusercontent.com/sourander/skriptiohjelmointi/refs/heads/main/scripts/runpy.py)
    2. Tee tiedostosta ajettava (tai aja jatkossa `python runpy.py`)
    3. Lue tiedoston sisältö läpi ja selvitä, mitä se tekee.

    Referenssiksi hakemistorakenteen kuuluisi olla:


    ```plaintext
    johnanderton
    ├── README.md
    ├── bash
    │   └── .gitkeep 
    ├── pwsh
    │   └── .gitkeep 
    └── python
        ├── README.md
        ├── getscripts.sh
        └── scripts
            └── hello.py  # <= Seuraava tehtävä!
    ```

??? question "Tehtävä: Python Hello World"

    Luo skripti `hello.py`, joka tulostaa konsoliin `Hello, World!`. Aja sitten:

    ```console
    $ ./runpy.py --dryrun scripts/hello.py
    [DRY] Cmd that would run: LUE TÄMÄ OUTPUT!!

    $ ./runpy.py scripts/hello.py
    Hello, World!

    $ ./runpy.py --bash --dryrun
    [DRY] Cmd that would run: LUE TÄMÄ OUTPUT!!

    $ ./runpy.py --bash
    # python3 /app/scripts/hello.py
    Hello, World!
    ```

    Huomaa, että tiedoston ei tarvitse olla executable, koska kontin sisällä ajetaan komento `python <tiedosto>` eikä `./<tiedosto>`.

??? question "Tehtävä: Python Turboahdettu Hello World"

    Luo skripti, joka tulostaa:

    * absoluuttinen polku työhakemistoon
    * absoluuttinen polku skriptin sijaintiin
    * polut, joista Python etsii moduuleja

    Tiedoston tulisi alkaa näin:

    ```python title="hello_turbo.py"
    #!/usr/bin/env python3

    # Implement
    ```

    Alla esimerkkikäyttö Dockerin kanssa:

    ```console
    $ runpy.py scripts/hello_turbo.py

    ========= Turbo Hello World! =========
    Current working dir:          : /app
    Skriptin sijainti:            : /app/scripts/hello_turbo.py
    Python moduulien hakupolut:
        /app/scripts
        /usr/local/lib/python312.zip
        /usr/local/lib/python3.12
        /usr/local/lib/python3.12/lib-dynload
        /usr/local/lib/python3.12/site-packages
    ```

    Ja tässä vielä Multipassin kanssa:

    ```console
    $ multipass launch --name helloturbo 24.04
    $ multipass transfer scripts/hello_turbo.py helloturbo:.
    $ multipass exec helloturbo -- python3 hello_turbo.py
    ========= Turbo Hello World! =========
    Current working dir:          : /home/ubuntu
    Skriptin sijainti:            : /home/ubuntu/hello_turbo.py
    Python moduulien hakupolut:
        /home/ubuntu
        /usr/lib/python312.zip
        /usr/lib/python3.12
        /usr/lib/python3.12/lib-dynload
        /usr/local/lib/python3.12/dist-packages
    ```

    ??? tip "Vinkki: Moduulit"

        Katso, mitä `sys.path` sisältää. Huomaa, että `sys`-moduuli pitää importoida ensin.

??? question "Tehtävä: Interaktiivinen Python"

    Harjoittele tässä tehtävässä interaktiivista Python Shelliä eli REPL:iä kontin sisällä. Saat sen auki ajamalla aiemmin lataamasi `runpy.py`-skriptin ilman argumentteja. Kokeile seuraavia:

    1. Laske 2+2
    2. Luo muuttuja `x` ja anna sille arvoksi 42
    3. Tulosta muuttujan `x` arvo
    4. Luo lista `lista` ja anna sille arvoksi `[1, 2, 3]`
    5. Tulosta listan `lista` arvot

    ```console
    $ runpy.py
    Python 3.1x.x (main, ...) [GCC xx.x.0] on linux
    Type "help", "copyright", "credits" or "license" for more information.
    >>> # Tässä voit kirjoittaa Python-koodia
    ```

    Kun olet valmis, voit poistua painamalla `Ctrl+D` tai kirjoittamalla `exit()`.

    !!! tip "Miksi REPL?"

        Interaktiivinen Python on hyvä tapa kokeilla nopeasti koodinpätkiä ja testata, miten Python toimii. Materiaalin kirjoittanut opettaja käyttää sitä usein myös nopeana laskimena.

??? question "Tehtävä: Interaktiivinen Python Pt. 2"

    Äärimmäisen näppärä komento lyhyitä skriptejä debugatessa on `-i`-flagi, joka jättää Pythonin auki skriptin suorituksen jälkeen interaktiiviseen tilaan. Dokumentaatiossa se on määritelty näin: "When a script is passed as first argument (...) enter interactive mode after executing the script (...)" [^pythoncmdline]. Lokaalisti ajettuna se olisi näinkin helppoa:

    ```console
    $ python -i scripts/hello_turbo.py
    ```

    [^pythoncmdline]: Python Docs. Command line and environment. https://docs.python.org/3/using/cmdline.html#cmdoption-i

    ```
    $ ./runpy.py --dryrun --interactive scripts/hello_turbo.py
    [DRY] Cmd that would run: LUE TÄMÄ OUTPUT!!

    $ ./runpy.py --interactive scripts/hello_turbo.py
    ========= Turbo Hello World! =========
    Current working dir:          : /app
    Skriptin sijainti:            : /app/scripts/hello_turbo.py
    Python moduulien hakupolut:
        /app/scripts
        /usr/local/lib/python312.zip
        /usr/local/lib/python3.12
        /usr/local/lib/python3.12/lib-dynload
        /usr/local/lib/python3.12/site-packages
    >>>
    ```

    Mitä me voitimme? Sinulla on kaikki skriptissä importatut moduulit käytössä, kuten myös muuttujat ja funktiot. Tämä on yksi monista vaihtoehdoista debugata ja/tai kehittää skriptejä. Kukin skriptaaja löytää oman tyylinsä, joka sopii parhaiten omaan tapaansa työskennellä – on kuitenkin hyvä tuntea vaihtoehdot eikä tarttua ensimmäiseen. Omia työskentelytapojaan kannattaa myös jatkuvasti haastaa ja kehittää.

??? question "Tehtävä: Tiedostoon loggaus"

    Ota mallia yllä olevasta `logger_practice.py`-skriptistä ja luo oma skripti, joka loggaa viestit konsolin sijasta tiedostoon (esim. `logger_practice.log`). Pythonin oma [Logging HOWTO](https://docs.python.org/3/howto/logging.html) on hyvä paikka aloittaa.

    !!! tip

        Huomaa, että jos ajat skriptiä kontin sisällä, niin tiedosto tallentuu kontin sisälle. Ethän yritä tallentaa tiedostoa `/app`-hakemistoon, koska se on read-only. Voit tallentaa tiedoston esimerkiksi `/tmp`-hakemistoon.

        Muista myös, että kontti on väliaikainen, joten tiedosto katoaa, kun kontti tuhotaan. On kannattavaa ajaa kontti siten, että CMD on bash, ja käyt suorittamassa skriptin käsin. Eli siis:

        ```console title="🖥️ Bash"
        $ ./runpy.py --bash
        ```

        ...joka avaa bashin kontin sisällä. Tämän jälkeen voit ajaa skriptin käsin ja käydä tarkistamassa, että tiedosto on luotu.

        ```console title="🐳 Bash"
        # python3 /app/scripts/logger_practice.py
        ```


??? question "Tehtävä: Ruff"

    Yllä on esitelty Ruff-työkalun käyttö Docker-kontissa. Käytä sitä ja korjaa kaikkien tiedostojen virheet (sekä check että format), jotka olet tähän asti luonut `scripts/`-hakemistoon.

    Saat käyttää parhaaksi katsomallasi tavalla joko Dockerissa ajettua Ruffia, lokaalisti asettua Ruff:ia (esim. `uv tool install ruff`) tai Visual Studio Coden lisäosaa. Docker on helpoin, koska se on neuvottu yllä. Muita varten sinun tarvitsee ottaa omatoimisesti selvää.

    !!! warning
    
        Muista ottaa tämä tavaksi jatkossa! On oletus, että kurssilla kirjoittamasi skriptit läpäisevät Ruffin tarkistukset. Kenties haluat kirjoittaa skriptin, joka ajaa pitkän Docker-komennon puolestasi? 🤔

## Lähteet