---
priority: 396
---

# 👩‍🔬 Curium

## Tärpit

### Väliaikaiset tiedostot

Skriptejä kirjoittaessa sinulla voi hyvinkin olla tarve esimerkiksi ladata suuri `zip` tai `tar.gz` paketti verkosta ja purkaa se. Näitä ei luonnollisesti kannata säilöä pitkäaikaisesti. Pythonin [tempfile](https://docs.python.org/3/library/tempfile.html)-moduuli tarjoaa väliaikaisten tiedostojen luomisen ja hallinnan. Se soveltuu useisiin käyttötapauksiin, mutta tässä esittelemme kaksi.

Käyttötapaus 1 on, että haluat käyttää internetistä löytyvää tiedostoa, mutta et halua ladata sitä joka kerta uusiksi. Voit käyttää `tempfile.gettempdir()`-funktiota saadaksesi järjestelmän väliaikaisten tiedostojen hakemiston ja luoda tiedoston sinne. Tämä on hyödyllistä esimerkiksi, jos haluat ladata tiedoston vain kerran ja käyttää sitä sen jälkeen paikallisesti. Huomaa, että käyttöjärjestelmä voi poistaa tmp-tiedostoja mielivaltaisesti esimerkiksi käynnistyksen yhteydessä tai levytilan käydessä vähiin. Lue toiminnallisuus koodista:

```python title="cache_internet_file.py"
import tempfile
import requests

from pathlib import Path

URI = "https://www.example.com/index.html"

def cache_internet_file(uri: str) -> Path:
    temp_dir = tempfile.gettempdir() # (1)!
    temp_file_path = Path(temp_dir) / "etusivu.html" # (2)!

    if not temp_file_path.exists():
        print("[INFO] Downloading data from the internet...")
        response = requests.get(URI)
        with open(temp_file_path, 'wb') as temp_file:
            temp_file.write(response.content)

    return temp_file_path

local_file_path = cache_internet_file(URI)
print(f"[INFO] Downloaded data is available at: {local_file_path}")
```

1. `tempfile.gettempdir()` palauttaa järjestelmän väliaikaisten tiedostojen hakemiston. Windowsissa tämä voi olla esimerkiksi `C:\Users\user\AppData\Local\Temp`, Linuxissa `/tmp` ja macOS:ssä `/var/folders/.../T/`.
2. Yksinkertaisuuden vuoksi tiedostonimi on kovakoodattu. Kenties haluaisit poimia tiedostonimen URI:sta urlib.parse.urlparse()-funktiolla? Tai antaa tiedostonimen argumenttina funktiolle? Tai käyttää sanitoitua urlia tiedostonimenä?

Käyttötapaus 2 on hetkellisen hakemiston tai tiedoston luominen, jota tarvitaan vain ja ainoastaan skriptin ajon verran. Tämä on hyödyllistä, jos skriptisi ajon sivutuotteena syntyy tiedosto, jota ei tarvita jatkossa. Löydät lisää esimerkkejä tempfile-moduulin dokumentaatiosta. Alla hyvin yksinkertainen esimerkki.

```python title="use_temporary_file.py"
import tempfile

from pathlib import Path

with tempfile.NamedTemporaryFile(delete_on_close=True) as temp_file: # (1)!
    temp_file.write(b"Hello world!")
    temp_file.flush()
    temp_path = Path(temp_file.name)

if temp_path.exists():
    print(f"⛔️ Oh no! Temporary file is still available at: {temp_path}")
else:
    print(f"✅ Temporary file was deleted! (rip {temp_path})")
```

1. Tässä käytetään *context manageria* eli `with`-lauseketta. Context manager kutsuu luokan `__enter__`- ja `__exit__`-metodeja automaattisesti, joten et tarvitse `temp_file.close()`-kutsua.

### Kirjastot kontissa

Jos ajat yllä olevan `cache_internet_file.py`-esimerkin kontissa, saat alla näkyvän virheen. Tämä johtuu siitä, että `python:3.12`-image sisältää vain ja ainoastaan Pythonin sisäänrakennetut moduulit. Sen sijaan Ubuntussa `requests`-moduuli on asennettu järjestelmätasolla - tähän `dist-packages`-hakemistoon olet tutustunut jo aiemmin.

```console title="🖥️ Bash"
$ python runpy.py scripts/cache_internet_file.py 
Traceback (most recent call last):
  File "/app/scripts/cache_internet_file.py", line 2, in <module>
    import requests
ModuleNotFoundError: No module named 'requests'
```

Voimme toki ajaa `pip install requests`-komennon kontin sisällä, mutta tämä pitäisi ajaa joka kerta uudestaan, sillä kontit ovat *ephemeral* eli niiden tila ei pysy tallennettuna. Jos haluat pysyviä muutoksia, sinun tulee luoda oma Dockerfile ja sen pohjalta oma image. Tehdään siis näin!

Luo tiedostot `build-skroh-python.py` ja `skroh-python.Dockerfile` haluamaasi lokaatioon. Tässä esimerkissä ne on luotu projektikansion `python/`-alihakemistoon.

=== "build-skroh-python.sh"
    ```bash title="build-skroh-python.py"
    #!/usr/bin/env python3
    import subprocess

    def build_docker_image():
        command = [
            "docker", "buildx", "build",
            "-t", "skroh-python:3.12",
            "-f", "skroh-python.Dockerfile",
            "."
        ]
        subprocess.run(command)

    if __name__ == "__main__":
        build_docker_image()
    ```

=== "skroh-python.Dockerfile"
    ```dockerfile title="skroh-python.Dockerfile"
    FROM python:3.12

    RUN pip install requests
    ```

Nyt voit ajaa `build-skroh-python.py`-skriptin, joka luo uuden Docker-imagen. Skripti on Python-skripti, joten sen pitäisi toimia eri käyttöjärjestelmissä Seuraa alla olevia komentoja ajatuksella. Komentojen tulostetta on lyhennetty luettavuuden parantamiseksi.

```console title="🖥️ Bash | CMD | PowerShell"
$ python build-skroh-python.py
=> [internal] load build definition from skroh-python.Dockerfile
=> [1/2] FROM docker.io/library/python:3.12
=> [2/2] RUN pip install requests
=> => naming to docker.io/library/skroh-python:3.12

$ docker image ls
➜  python git:(main) ✗ docker image ls            
REPOSITORY                                TAG                   IMAGE ID       CREATED          SIZE
skroh-python                              3.12                  ad99a641fce3   28 minutes ago   1.03GB
python                                    3.12                  ba0500f08e94   12 days ago      1.02GB

$ python runpy.py --image skroh-python:3.12 scripts/cache_internet_file.py 
[INFO] Downloading data from the internet...
[INFO] Downloaded data is available at: /tmp/etusivu.html
```

Huomaa, että jos ajat alimman komennon uusiksi, tiedosto ladataan uudestaan. Tämä johtuu siitä, että kontti on *ephemeral* ja sen tila ei pysy tallennettuna. Jos haluat hyötyä tämän sortin cachetuksesta, nopein tapa on käyttää Bash-istuntoa kontissa ja ajaa skripti useita kertoja saman istunnon aikana. Muista, että `scripts/`-hakemisto on mountattu kontin sisälle, joten voit muokata tiedostoja suoraan hostilla ja muutokset näkyvät kontissa välittömästi.

```title="🖥️ Bash | CMD | PowerShell"
$ python runpy.py --image skroh-python:3.12 --bash

🐳 # python scripts/cache_internet_file.py 
[INFO] Downloading data from the internet...
[INFO] Downloaded data is available at: /tmp/etusivu.html

🐳 # python scripts/cache_internet_file.py 
[INFO] Downloaded data is available at: /tmp/etusivu.html
```

## Tehtävät

??? question "Tehtävä: Pingviinien laskeminen"

    Tämä on sinulle PowerShell-osiosta tuttua dataa. Lue skripti, joka lukee tiedoston [penguins.csv](https://raw.githubusercontent.com/mwaskom/seaborn-data/refs/heads/master/penguins.csv) ja laskee pingviinit lajeittain. Tulosta lajit ja niiden lukumäärät.

    Huomaa, että meidän käytössä on järjestelmätason Python ja siten vain Pythonin sisäänrakennetut (ja ehkä debianin) kirjastot. Älä asenna datankäsitelykirjastoja. Käytä sisäänrakennettua [csv](https://docs.python.org/3/library/csv.html)-moduulia.

    ```python
    import csv

    # Steps:
    # 1. Read the file if exists
    # 2. Download the file otherwise
    # 3. Count the penguins
    # 4. Print the results
    ```

    Lopulta sen pitäisi käyttäytyä näin:

    ```console title="🖥️ Bash"
    $ python runpy.py --image skroh-python:3.12 scripts/penguins.py
    [INFO] Downloading data from the internet...
    Downloaded data is available at: /tmp/penguins.csv
    Read 344 rows from the CSV file.
    Adelie: 152
    Chinstrap: 68
    Gentoo: 124
    ```

    ??? tip "CSV"

        ```python
        import csv
        
        # ...
        csv_reader = csv.DictReader(csv_file)
        list(csv_reader)
        ```

    ??? tip "Counting"

        Lajien laskemisen voi tehdä usealla eri tavalla. Voit esimerkiksi käyttää `collections.Counter`-luokkaa, saman kirjaston defaultdictiä, sqliteä, tai ihan tavallista dictionaryä. Counterilla se hoituu näin:

        ```python
        from collections import Counter

        # ...
        c = Counter(entry["species"] for entry in penguin_dict)
        dict(c)
        ```

??? question "Tehtävä: Suurimmat ohjelmat"

    TODO

??? question "Tehtävä: Duplikaattitiedostojen luominen"

    TODO

??? question "Tehtävä: Duplikaattien tunnistaminen"

    TODO
