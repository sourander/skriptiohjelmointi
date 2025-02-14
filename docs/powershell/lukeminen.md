---
priority: 210
---

# Lukeminen

## Mistä on kyse?

Aloitetaan jo olemassa olevien skriptien lukemisesta. On kovin tyypillistä, että ohjelmiston asennuksen tai käyttöönoton yhteydessä sinua neuvotaan ajamaan online-hostattu skripti. Tyypillisesti vaihe näyttää tältä:

```powershell title="PowerShell"
# Näin
Invoke-RestMethod -Uri https://example.com/install.ps1 | Invoke-Expression

# Tai näin
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://ohmyposh.dev/install.ps1'))
```

Jos olet epävarma, mitä komennot tekevät, aja `Get-Help` kullekin cmdletille.

Koska kehittäjäyhteisöjen kirjoittamaa koodia on Internet pullollaan, niin tutustutaan näihin esimerkkien kautta.

## Esimerkkejä

### Scoop

Komentoriviltä ajettava [Scoop](https://scoop.sh/) on ohjelmisto, joka asentaa ohjelmia Windowsille. Se on eräänlainen vastine Linuxin `apt`- ja `yum`-paketinhallintajärjestelmille. Scoop asentaa hieman Linuxista tuttuun tapaan ohjelmia käyttäjän kotihakemistoon. Vakiona ohjelmat asennetaan vain käyttäjän scopeen. Scoopin asennus hoituu melko pitkän PS1-scriptin avulla.

Itse skripti löytyy: [https://get.scoop.sh](https://get.scoop.sh)

### Chocolatey

Scoopin kilpailija [Chocolatey](https://chocolatey.org/install) on hyvin vastaava ohjelmisto Windowsille. Se on hieman erilainen, sillä se on enemmän pakettienhallintajärjestelmä kuin ohjelmistojen asentaja. Toisin kuin Scoop, Chocolatey asentaa ohjelmia järjestelmänlaajuisesti, perinteiseen Program Files lokaatioon.

Itse skripti löytyy: [https://community.chocolatey.org/install.ps1](https://community.chocolatey.org/install.ps1)

### Oh My Posh

[Oh My Posh](https://ohmyposh.dev/) on cross-platform teema- ja prompt-asetusten hallintatyökalu PowerShellille (ja myös muille shelliympäristöille). Se on eräänlainen vastine Zsh:n `oh-my-zsh`-teemalle. Sen voi asentaa [Microsoftin ohjeiden mukaan](https://learn.microsoft.com/en-us/windows/terminal/tutorials/custom-prompt-setup) wingetillä, mutta myös suoraan skriptillä. Tähän löytyy ohjeet [Oh My Posh: Installation Windows](https://ohmyposh.dev/docs/installation/windows) -sivulta.

Itse skripti löytyy: [https://ohmyposh.dev/install.ps1](https://ohmyposh.dev/install.ps1)

Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://ohmyposh.dev/install.ps1'))

### Docker Build Script

Tällä kurssilla käytetty `mcr.microsoft.com/powershell` Docker-image käännetään PowerShell-skriptillä CI/CD-automatisaation toimesta. Skripti on pitkä, mutta siitä huolimatta uniikit syntaksinpalat ovat helppoja tunnistaa.

Itse skripti löyty: [gh:PowerShell/PowerShell-Docker/build.ps1](https://github.com/PowerShell/PowerShell-Docker/blob/master/build.ps1)

### Kokoelmat

Voit tutustua myös Markus Fleschutzin kokoelmaan PowerShell-skriptejä [gh:fleschutz/PowerShell/](https://github.com/fleschutz/PowerShell/). Repositoriosta löytyvät skriptit ovat tyypillisesti huomattavasti lyhyempiä kuin ylemmät, joten jos parsit näitä, niin parsi ainakin 5 kappaletta läpi.



## Tehtävät

!!! question "Tehtävä: Parsi PowerShell-skripti"

    Tee sama kuin teit Bashin vastaavassa tehtävässä. Valitse yllä olevista skripteistä yksi (tai monta, jos parsit kokoelman). Kirjoita ylös löytämäsi syntaksin palaset, jotka ovat uniikkeja. Voit noudattaa samaa prosessia kuin Bashin vastaavassa tehtävässä:

    1. Lataa tiedosto: `curl -sSLf https://example.com/install.ps1 > to-inspect.ps1`
    2. Avaa Visual Studio Codessa: `code to-inspect.ps1`
    3. Aloita tiedoston ylhäältä ja prosessoi se rivi riviltä.
   
    Tee seuraavat toimenpiteet **jokaiselle koodiriville**:

    * ✅ Jos koodirivi sisältää entuudestaan vierasta syntaksia: dokumentoi se. 📄
    * 🔁 Jos koodirivin syntaksi on jo esiintynyt aiemmin scriptissä: unohda rivi. 🫳
    * Tämän jälkeen poista kyseinen koodirivi tiedostosta.
 
    Tämän pitäisi olla sinulle tuttua Bash-osuudesta.

    !!! tip "Ajansäästöä tekoälyllä! 🤖"

        Tässä tehtävässä on suorastaan suositeltua käyttää tekoälyä apuna selittämään, mitä kyseiset Powershell-kielen entuudestaan tuntemattomat koodirimpsut tekevät. Promptia muotoillessa kannattaa harkita Bash-osaamisesi esittely: kielimalli voi selittää sinulle termejä siten, että se vertaa niitä Bashin vastaaviin.