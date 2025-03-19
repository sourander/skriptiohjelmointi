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

Nyt voit ajaa `build-skroh-python.py`-skriptin, joka luo uuden Docker-imagen. Skripti on Python-skripti, joten sen pitäisi toimia eri käyttöjärjestelmissä. Seuraa alla olevia komentoja ajatuksella. Komentojen tulostetta on lyhennetty luettavuuden parantamiseksi.

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

    Luo skripti, joka tulostaa n kappaletta suurimpia binääritiedostoja /usr/bin-hakemistossa. Vakio n = 5, mutta käyttäjä voi syöttää sen. Voit lähestyä ongelmaa kahdella tavalla:

    * `subprocess.run(["du", "-a", "/usr/bin"])`
    * `Path("/usr/bin/some_executable").stat()`

    Jälkimmäinen tapa säästää sinut `du`-komennon tuloksen parsimiselta ja on muutenkin *more pythonic*. Se palauttaa itemin, joka sisältää muun muassa seuraavat tiedot:

    ```python
    os.stat_result(
        st_mode=33261,    # oct(33261) == 0o100755 eli 755 eli rwxr-xr-x
        st_uid=0,         # user id
        st_gid=0,         # group id
        st_size=1346480,  # size in bytes
        ...
    )
    ```

    Huomaa, että arvot `st_uid` ja `st_gid` tulee muuttaa käyttäjänimeksi ja ryhmänimeksi. Tämä onnistuu helposti [pwd](https://docs.python.org/3/library/pwd.html) ja [grp](https://docs.python.org/3/library/grp.html)-moduuleilla. Entä kuinka muuttaisit `st_size`-arvon ihmisluettavaan muotoon? Kenties StackOverFlow-palvelussa tätä on pohtinut joku muukin?

    !!! note "Lisähaaste"

        Voit lisätä tehtävän haastavuutta seuraamalla symbolisia linkkejä. Jos teet tämän, tulet saamaan kohtalaisen määrän duplikaatteja. Keksi tapa poistaa duplikaatit listasta.

    !!! note "Lisähaaste 2"
        Lisähaaste on hyödyntää st_modea. Voit parsia siitä muun muassa moden numeroina (esim. `755`), kääntää sen merkkijonoksi (esim. `rwxrxrx`)

    Esimerkki käytöstä alla (lisähaasteet mukana):

    ```console title="🖥️ Bash"
    $ ./runpy.py scripts/largest_binaries.py -n 8 
    /usr/bin/x86_64-linux-gnu-lto-dump-12      30.5 MiB    root:root rwxr-xr-x
    /usr/bin/sq                                 9.6 MiB    root:root rwxr-xr-x
    /usr/bin/python3.11                         6.5 MiB    root:root rwxr-xr-x
    /usr/bin/perl5.36.0                         3.6 MiB    root:root rwxr-xr-x
    /usr/bin/git                                3.5 MiB    root:root rwxr-xr-x
    /usr/bin/x86_64-linux-gnu-ld.gold           3.0 MiB    root:root rwxr-xr-x
    /usr/bin/scalar                             2.1 MiB    root:root rwxr-xr-x
    /usr/bin/git-shell                          2.0 MiB    root:root rwxr-xr-x
    ```

    Tämä harjoitus ei juuri saavuta mitään, mitä `ls`-komento ei tee, mutta se on hyvä harjoitus tiedostojen käsittelyyn ja tiedostojen metatietojen lukemiseen. Voisit käyttää näitä taitoja esimerkiksi tiedostojen analysointiin, järjestämiseen, tai vaikkapa tiedostojen poistamiseen – kenties sisällyttäen merkittävästi enemmän logiikkaa.

??? question "Tehtävä: Duplikaattitiedostojen luominen"

    Tämä tehtävä toimii esiasteena seuraavalle tehtävälle. Luo skripti, joka kirjoittaa tiedostoihin sisältöä siten, että osa tiedostoista on tarkoituksella toistensa kopioita. Osa tiedostoista tulee sen sijaan olla uniikkeja. Voit käyttää apuna seuraavanlaista jakoa:

    ```python title="add_duplicates.py"
    duplicate_files = [
        tmpdir / "foo.txt",
        tmpdir / "foo_copy.txt",
        tmpdir / "nested" / "foo_copy_nested.txt",
    ]

    unique_files = [
        tmpdir / "unicorn_a.txt",
        tmpdir / "nested" / "unicorn_b.txt",
    ]
    ```

    Lopulta ohjelmaa tulisi voida käyttää seuraavanlaisesti:

    ```console title="🐳 Bash"
    $ python scripts/add_duplicates.py
    Temporary directory created at: /tmp/tmpinhu9_m1
    Created file: /tmp/tmpinhu9_m1/foo.txt
    Created file: /tmp/tmpinhu9_m1/foo_copy.txt
    Created file: /tmp/tmpinhu9_m1/nested/foo_copy_nested.txt
    Created file: /tmp/tmpinhu9_m1/unicorn_a.txt
    Created file: /tmp/tmpinhu9_m1/nested/unicorn_b.txt
    Navigate to /tmp/tmpinhu9_m1 to see the files! 👀
    ```

    !!! tip
    
        Rautakoodauksen sijasta voit käyttää `tempfile.gettempdir()`, jotta sama skripti toimisi eri alustoilla.

??? question "Tehtävä: Duplikaattien tunnistaminen"

    Luo skripti, joka tunnistaa duplikaatit annetussa hakemistossa. Mikäli `-recurse` flag on annettu, sen tulisi käydä myös alihakemistot läpi. Duplikaatit tulisi tunnistaa tiedoston MD5-hashin perusteella. Voit käyttää samoja vaiheita kuin aiemmin PowerShellin kanssa, mutta puuttuvat cmdletit saattavat aiheuttaa päänvaivaa.

    **Päänvaiva 1:** Tulet mahdollisesti huomaamaan, että Group-Object ja Where-Object Count -komentojen puute tekee tehtävästä hieman vaikeamman Pythonissa kuin PowerShellissä, jossa olet toteuttanut vastaavan operaation aiemmin. Datan käsittelyyn tarkoitetut kirjastot, kuten Pandas, tarjoavat näitä ominaisuuksia, mutta se lisäisi meidän skriptille ylimääräisiä riippuvuuksia. Ratkaise tämä ongelma Pythonin sisäänrakennetuilla kirjastoilla. Kenties `collections.defaultdict` tai `collections.Counter` voisi olla hyödyllinen?

    **Päänvaiva 2:** Sinun saattaa tulla ikävä myös Get-FileHash -cmdletia, joka laskee tiedoston hashin. Pythonissa voit käyttää `hashlib`-moduulia. Voit chunkata tiedoston ja laskea hashin osissa, kuten StackOverFlow:n postauksissa neuvotaan, jotta suurten tiedostojen käsittely onnistuu. Vaihtoehtona on käyttää ==valmisratkaisua==: `hashlib.file_digest(f, algorithm)`. Kyseinen funktio on Python 3.11:ssä lisätty.

    Alla näkyy esimerkkitoteutuksen käyttö:

    ```console title="🐳 Bash"
    $ python scripts/find_duplicates.py /tmp/tmpinhu9_m1/
    🚨 WARNING: Duplicate files found:

    Full path                      MD5 checksum
    ---------------------------------------------------------------
    /tmp/tmpinhu9_m1/foo.txt       746308829575e17c3331bbcb00c0898b
    /tmp/tmpinhu9_m1/foo_copy.txt  746308829575e17c3331bbcb00c0898b
    
    $ python scripts/find_duplicates.py /tmp/tmpinhu9_m1/ --recurse
    🚨 WARNING: Duplicate files found:

    Full path                                    MD5 checksum
    -----------------------------------------------------------------------------
    /tmp/tmpinhu9_m1/foo.txt                     746308829575e17c3331bbcb00c0898b
    /tmp/tmpinhu9_m1/foo_copy.txt                746308829575e17c3331bbcb00c0898b
    /tmp/tmpinhu9_m1/nested/foo_copy_nested.txt  746308829575e17c3331bbcb00c0898b
    ```


??? question "Tehtävä: Tulosta PATH-muuttujan hakemistot"

    Skriptiohjelmoinnin tärkeä osa on ympäristömuuttujien käsittely. Yksi tärkeimmistä ympäristömuuttujista on `PATH`, joka sisältää hakemistot, joista käyttöjärjestelmä etsii suoritettavia tiedostoja. Toteuta skripti, joka tulostaa `PATH`-muuttujan hakemistot riveittäin. Voit käyttää `os.environ["PATH"]`-muuttujaa, joka palauttaa `PATH`-muuttujan arvon.

    Tämä on Curium-osion helppo loppukevennys! Tulosteen tulisi näyttää jotakuinkin tältä:

    ```console title="🐳 Bash"
    python scripts/print_env.py 
    /usr/local/bin
    /usr/local/sbin
    /usr/local/bin
    /usr/sbin
    /usr/bin
    /sbin
    /bin
    ```