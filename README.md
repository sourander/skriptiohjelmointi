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

## Pre-commit

Projektissa on käytössä pre-commit, joka varmistaa, että olet muistanut lisätä kaikki Tehtävät sivuston Tehtäväkooste-osioon. Pre-commit ajetaan automaattisesti ennen commitointia. Ajettava skripti luo uuden version `docs/exercises.md`-tiedostosta ja lisää sen commitiin.

Tehtävälista järjestetään prioriteetin mukaan, jonka voi asettaa `docs/exercises.md`-tiedostossa olevan `priority`-avaimen arvolla. Default on 999. Prioriteetti määritellään Markdown-tiedoston metadata-osiossa, jonka tulee olla heti tiedoston alussa. Se näyttää tältä:

```plaintext
---
priority: 100
---
```

Jos haluat aja hookin käsin, kirjoita:

```bash
uv run pre-commit run --all-files
```
