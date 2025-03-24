# Skriptiohjelmointi

Tämä on Skriptiohjelmointi-kurssin oppimateriaali. Projekti löytyy tavallisena HTTP-sivustona verkosta (ks. linkki tämän sivun About-osiosta), mutta sen voi tarpeen mukaan ajaa myös lokaalisti.

Projekti nojaa vahvasti `Material for MkDocs`-nimiseen Python-kirjastoon. Kyseinen kirjasto luo `docs/`-kansion sisällön perusteella verkkosivuston.

Tämä sivusto on luotu [Doc Skeleton](https://github.com/sourander/doc-skeleton)-templaatin avulla.

## Riippuvuudet
* Python >=3.10
* Python uv

## Kuinka ajaa lokaalisti

Tämä projekti käyttää uv-projektinhallintaa.

```bash
# Kloonaa 
git clone 'this-repo-url'

# Aktivoi hookit
uv run pre-commit install

# Aja development serveri
uv run mkdocs serve --open
```
