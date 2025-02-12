---
priority: 238
---

# 🎆 Strontium

## Tärpit

### TODO

Lorem ipsum

## Mukavuus

### Visual Studio Coden käyttö

!!! warning

    Mukavuus-otsikon alla on oletus, että sinulla on käytössä Visual Studio Code, PowerShell Extension ja lokaalisti asennettu PowerShell.

Bash-kielessä on hyvin pieni määrä sisäänrakennettuja komentoja, joten kyseistä kieltä kirjoittaa melko kevyesti ilman *code autocompletion* ominaisuutta. PowerShellin kanssa tätä kannattaa opetella hyödyntämään.

![](image.png)

**Kuva 1:** Kun kirjoitat `Get-`, aukeaa valikko, josta voit valita haluamasi cmdletin. PowerShell Extensionin käyttö nopeuttaa kirjoittamista ja vähentää virheitä.

Muita hyödyllisiä pikaneuvoja ovat:

- ++f8++ : Aja maalattu osa komentoa VS Code Terminalissa (ei kontissa!)
- ++f1++ : Avaa komentopaneeli.
    - Kirjoita hakukenttään `PowerShell` ja katso mitä kaikkea löydät.
- ++ctrl+comma++ : Avaa asetukset. 
    - Kirjoita hakukenttään `@ext:ms-vscode.powershell` ja saat esille kaikki PowerShell Extensionin asetukset. (🍎 Mac: ++command+comma++:)

PowerShell Extensionin asetuksiin pääset painamalla `Ctrl+,` ja kirjoittamalla hakukenttään `PowerShell`. Täältä löydät kaikki asetukset, joita voit muokata.



### Promptin muokkaus

Jos/kun käytät lokaalia PowerShelliä syntax highlightingin toimivuuden takaamiseksi tai ympäristöä muokkaamattomien srkriptien ajamiseksi, olet varmasti huomannut, että prompt on tyypillisesti melko pitkä. Se on esimerkiksi:

```plaintext
PS /home/john/Code/johnanderton/skriptiohjelmointi-2025/pwsh>
```

Eikö olisi mukavampaa, jos prompt olisi:

```plaintext
PS pwsh>
```

Bashistä sinulle pitäisi olla tuttua Start-up -tiedosto `.bashrc` ja ympäristömuuttuja `PS1`, joka säätää sinun promptiasi. PowerShellissä hitusen vastaava tiedosto on profiilitiedosto, jonka sijainti sinulle selviää komennolla:

```powershell title="🖥️ PowerShell"
# ks. CurrentUserCurrentHost
$profile

# tai ks. kaikki
$profile | Select-Object *

# avaa haluamasi VS Codessa
code $profile.CurrentUserAllHosts

# kun olet muokannut, käynnistä joko shell tai sourcea profiilitiedosto
. $profile.CurrentUserAllHosts
```

Promptin muotoilusta vastaa funktio `prompt`. Voit ylikirjoittaa tämän funktion yhden istunnon ajaksi terminaalissa. Pysyvämpi muutos syntyy muokkaamalla profiilitiedostoa, koska se ladataan joka kerta PowerShellin käynnistyessä. Tutustu tähän liittyviin helppeihin (about_Prompts, about_Profiles).

```powershell title="🖥️ /path/to/your/profile.ps1"
Function Prompt { 
    "PS $( ( Get-Location | Get-Item ).Name )> " 
}
```

Pyörää ei kannata keksiä uusiksi. Yllä oleva prompt on muokattu [superuser: Configure Windows PowerShell to display only the current folder name in the shell prompt](https://superuser.com/questions/446827/configure-windows-powershell-to-display-only-the-current-folder-name-in-the-shel)-keskustelun vastauksista. Vaihtoehtoinen tapa olisi käyttää valmiita teemoja esimerkiksi [oh-my-posh](https://ohmyposh.dev/):n avulla.

!!! warning

    Muista, että sinun on pitänyt ajaa `/app/scripts/localhelp.ps1`, joka lataa koneelle tallennetun helpin, tai komento `Update-Help`, joka lataa helpin netistä, jotta help oikeasti sisältää jotakin. Vaihtoehto on toki lukea esimerkiksi [about_Prompts](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_prompts) verkosta.

## Tehtävät

??? question "Tehtävä: Verb-Noun generaattori"

    Kehitä generaattori, `rnd-verb-noun.ps1`, joka luo uudenlaisia cmdlet-päteviä nimiä, kuten `Get-Pizza` tai `Set-Spam`. Luo itsellesi rautakoodattu lista substanstiiveja, mutta käytä oikeita, PowerShellissä tyypillisiä verbejä. Syntyneet nimet ovat näiden kahden listan jäsenien satunnaisia yhdistelmiä.

    !!! tip "Vinkki"

        Kokeile komentoa `Get-Verb`.

??? question "Tehtävä: Staattinen analyysi (PSScriptAnalyzer)"

    Bashin kanssa käytimme ohjelmaa `shellcheck`, joka analysoi skriptin ja antaa palautetta mahdollisista virheistä. PowerShellille vastaava työkalu on `PSScriptAnalyzer`. Sen pitäisi olla asennettuna ja aktiivsena, mutta voit tarkistaa, löytyykö se Get-Module cmdletillä:

    ```pwsh
    Get-Module
    ```

    Tämän jälkeen tarkista skriptisi:
    
    ```pwsh
    Invoke-ScriptAnalyzer -Path ./scripts/*.ps1
    ```

    Korjaa kaikki virheet ja varoitukset. Jos jokin virhe toistuu useita kertoja, harkitse Find & Replace -toiminnon käyttöä Visual Studio Codessa. Ole kuitenkin varovainen, ettet korvaa jotain, mitä et halua korvata!

    !!! tip

        Huomaat, että analyzer löytää virheitä, joista PowerShell Extensionin tavallinen linter ei varoita.
