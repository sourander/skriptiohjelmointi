---
priority: 199
---

# 👨‍🔬 Einsteinium

## Tärpit

### Invoke-Expression

`Invoke-Expression`-funktio on hyödyllinen, kun haluat ajaa dynaamisesti generoituja komentoja. Staattinen koodianalyysi tulee varoittamaan tästä, koska se on potentiaalinen tietoturvariski, ja voi altistaa sinut injection-hyökkäyksille. Käytä siis harkiten. Alla esimerkki:

```powershell
# Lista komennon palasista
$dockerCmd = @(
    "docker run",
    "--rm"
)

# Lisää komentoon osia valitsemallasi logiikalla
# Käytä esimerkiksi if-lauseita.
$dockerCmd += "--some-other-part"

# Lopulta yhdistä komennon palaset toisiinsa käyttäen välilyöntiä
# erotinmerkkinä ja aja komento.
Invoke-Expression ($dockerCmd -join ' ')
```

### What If

Jos haluat varmistaa, että komento toimii oikein, mutta et halua sitä vielä ajaa, voit käyttää `-WhatIf`-parametria. Alla on minimaalinen skripti, joka tukee toiminnallisuutta ja käyttää sitä yhdessä funktiossa:

```powershell title="what_if.ps1"
# This activates the script to support WhatIf
[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$Name='Unknown Person'
)

function Write-Name {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string]$Name
    )

    # This is where the WhatIf is checked.
    if ($PSCmdlet.ShouldProcess($Name)) {
        Write-Output "Hello, $Name!"
    }
}

#                       This passes the WhatIf to the function
Write-Name -Name $Name -WhatIf:$WhatIfPreference
```

## Tehtävät

!!! question "Tehtävä: PowerShell Docker Wrapper"

    Olet varmasti kurssin aikana huomannut oudon riippuvuuden Bashiin: sinulla on lokaali PowerShell asennettuna syntax highlightiä varten, mutta kun haluat ajaa PowerShelliä kontin sisällä, päädyt ajamaan `./runpwsh.sh`-skriptin Bash-terminaalissa.
    
    Toteuta `runpwsh.sh`-skriptin vastine PowerShellille. Tämä `runpwsh.ps1`-skripti tulisi olla vastaavalla tavalla käytettävissä kuin edeltäjänsä. Alla karkea esimerkki:

    ```powershell-session
    PS /> ./runpwsh.ps1 scripts/hello.ps1
    Hello, World!

    PS /> ./runpwsh.ps1
    PS /app>              # <= In the container
    ```

    Tee skriptistä helposti luettava. Käytä funktioita, jotta skripti on helposti ylläpidettävissä ja luettavissa. Älä myöskään unohda helppiä (ks. [about_Comment_Based_Help](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comment_based_help)) !

    ??? tip "Vinkki: Dry Run"

        Jos käytät tärpeissä esiteltyä tapaa eli kasaat komennon osatekijät listaksi ja lopulta ajat sen `Invoke-Expression`-funktiolla, kannattaa toteuttaa "Dry Run"-toiminnallisuus. Tämän voi tehdä joko kotikutoisesti tai seuraten PowerShell-käytäntöjä eli käyttämällä `SupportsShouldProcess`-attribuuttia. Näin skriptin voi ajaa `-WhatIf`-parametrilla, ja se tulostaa potentiaalisesti vaaralliset rivit ajamisen sijasta.