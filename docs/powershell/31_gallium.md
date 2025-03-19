---
priority: 231
---

# 💡 Gallium

## Tärpit

### Avainsanat

Aivan kuten Bashissä, myös PowerShellissä on varattuja sanoja, joita ei voi käyttää muuttujaniminä. Tässä on lista niistä:

```plaintext
The following are the reserved words in PowerShell:

    assembly         exit            process
    base             filter          public
    begin            finally         return
    break            for             sequence
    catch            foreach         static
    class            from (*)        switch
    command          function        throw
    configuration    hidden          trap
    continue         if              try
    data             in              type
    define (*)       inlinescript    until
    do               interface       using
    dynamicparam     module          var (*)
    else             namespace       while
    elseif           parallel        workflow
    end              param
    enum             private

    (*) These keywords are reserved for future use.
```

!!! tip "Mistä nämä löytyivät?"

    Olettaen että Help on päivitetty, saat nämä auki komennolla:

    ```powershell
    help about_reserved_words
    ```

    Komennon help löytyy online: [about_Reserved_Words](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_reserved_words).

### Muuttujat

Koko totuus löytyy PowerShellin dokumentaatiosta (esim. [about_Variables](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_variables)), mutta alla on pikaohje, jolla pääset alkuun.

#### Dynaaminen

PowerShell on dynaamisesti tyypitetty kieli. Tämä tarkoittaa, että sama muuttuja voi vaihtua kokoluvusta merkkijonoksi ja niin edelleen. Tämän lisäksi PowerShell päättelee tyypin `=` merkin oikealla puolella olevan komennon palautuvasta tyypistä. Alla on esimerkkejä, joissa muuttuja saa jonkin literaalin arvon tyypin.

```powershell
$x = 1            # Kokonaisluku (Int32)
$x = 3.12         # Liukuluku (Double)
$x = "abc"        # Merkkijono (String)
$x = @("abc", 42) # Taulukko (Array)
$x = @{a=1;b=2}   # Hajautustaulu (Hash table)
```

#### Vaihtaminen

Tyypin voi myös itse määrätä, jolloin se käytännössä castataan kyseiseksi muuttujaksi. Huomaa, että itse muuttuja on kuitenkin yhä dynaaminen:

```powershell
$x = [byte] 255      # Nyt se onkin tavu (Byte)
$x = [int] 255       # ... eiku kokonaisluku (Int32)
$x = [string] "abc"  # ... eiku merkkijono (String)

# Huomaa myös -as operaattori, joka palauttaa null jos castaus ei onnistu
$y = $x -as [int] # ... null, koska "abc" ei taivu luvuksi
```

#### Tyypittäminen

Voit myös käskeä muuttujan käyttämään tiettyä tyyppiä nyt ja jatkossa. Erona yllä olevaan on, että `[type]$variable` on nyt vasemmalla puolella `=`-merkkiä. Kaikki muuttujaan sijoitetut arvot pyritään jatkossa muuttamaan tähän tyyppiin. Jos muutos ei onnistu, saat virheen.

```powershell
[string]$x = 1      # Kerran merkkijono, aina merkkijono
$x = "Kissa"        # ... ja yhä
$x = 1              # ... ja yhä

[int]$y = 12 # Nro
$y = "Koira" # Virhe
```

Sokeasti automaattiseen tyypitykseen luottamisessa on omat riskinsä. Mieti tarkkaan, mitä seuraavassa tapahtuu:

```powershell-session title="🐳 PowerShell"
PS /> 4 + "2"
6
PS /> "4" + 2
42
```

Skriptejä kirjoittaessa tuskin tarvitset muita *simple typejä* kuin yllä listatut, mutta loput löytyvät esimerkiksi [C# Docs: Simple Types](https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/language-specification/types#835-simple-types) tai [DevBlogs: Understanding Numbers in PowerShell](https://devblogs.microsoft.com/scripting/understanding-numbers-in-powershell/). Näiltä sivuilta selviää myös numeraalisten tyyppien minimi- ja maksimiarvot, mikäli tarvitset kertausta asiasta.

#### Selvittäminen

Jos olet epävarma, mitä jotakin cmdlet palauttaa, voit aina selvittää sen näin:

```powershell
# Näin saat myös metodit ja parametrit esille
Get-Location | Get-Member

# Näin saat tyypin tiedot
(Get-Location).GetType()      # itsessään System.RuntimeType
(Get-Location).GetType().Name # itsessään String

# Jos palautunut arvo on jo muuttujassa
$var | Get-Member
# tai
$var.GetType()
```



### Drives

PowerShellissä on käsite "drive", joka on hieman erilainen kuin Linuxin tiedostojärjestelmä. Drive on käytännössä jokin abstrakti käsite, joka voi olla esimerkiksi tiedostojärjestelmä, rekisteri tai jokin muu. Voit listata kaikki drivet komennolla `Get-PSDrive`. Voit vaihtaa driveä komennolla `Set-Location`. Alla on komentoja, joissa aloitetaan /home/-hakemistosta, vaihdetaan env:-driveen ja listataan muuttujia, josta vaihdetaan Variable:-driveen, ja lopulta takaisin kotoisin tieodstojärjestelmän puolelle.

```powershell
cd /home         # Aloitetaan tästä (1)

cd env:          # Vaihdetaan env:-driveen (2) 
Get-ChildItem    # Listataan muuttujat
cd Variable:     # Vaihdetaan Variable:-driveen
cd /             # Vaihdetaan takaisin kotihakemistoon
```

1. Huomaa, että `cd` on Alias `Set-Location`-komentoon.
2. `env:`-drive sisältää ympäristömuuttujat. Huomaa, että Bashissä nämä ovat ihan vain muuttujia samassa namespacessa (esim. `$PATH`). PowerShell abstrahoi nämä omaksi drivekseen.

## Vianetsintä

Voimme käyttää Bash-kielestä tuttuja tapoja, mutta luonnolliseti niille on eri syntaksi. Tuttu `set -x` korvautuu StrictMode-asetuksella ja `set -e` korvautuu ErrorActionPreference-asetuksella.

### StrictMode

PowerShellin StrictMode on hieman monimutkaisempi kuin Bashin `set -x`. Käytännössä se kuitenkin esimerkiksi tarkistaa, että et yritä kutsua käyttämättömiä muuttujia. Voit kytkeä skriptissä sen päälle näin:

```powershell
Set-StrictMode -Version 2.0
```

Voit käyttää myös muita versioita, 1.0 tai 3.0. Tutustu niiden dokumentaatioon: [Set-StrictMode](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/set-strictmode)

??? note "Kuinka testata?"

    Luo ja aja tiedosto:

    ```powershell title="stictmode_yes.ps1"
    Set-StrictMode -Version 2.0

    Write-Host "Starting script with strict mode enabled..."
    Write-Host "We are referencing: $undefinedVar"
    Write-Host "This will never print."
    ```

    Luo myös tiedosto `strictmode_no.ps1`, joka on muutoin identtinen, mutta muokkaa riviä yksi. Aseta se muotoon `Set-StrictMode -Off`. Aja molemmat tiedostot ja vertaa tuloksia.

### ErrorActionPreference

PowerShellissä on useita preference-muuttujia (ks. about_Preference_Variables), joilla voit säätää, kuinka PowerShell käyttäytyy. Näistä `set -x`:ää eli "exit on error"-toiminnallisuutta vastaa parhaiten `ErrorActionPreference`. Voit asettaa sen arvoksi `Stop`, jolloin skripti pysähtyy ensimmäiseen virheeseen. Vakioarvo on `Continue`, jolloin skripti jatkaa virheistä huolimatta.

```powershell
$ErrorActionPreference = "Stop"
```

??? note "Kuinka testata?"

    Luo ja aja tiedosto:

    ```powershell title="preference_stop.ps1"
    $ErrorActionPreference = "Stop"

    Write-Host "Starting script with ErrorActionPreference set to Stop..."
    Set-Location -Path "/thisdoesnotexist" 2>$null
    Write-Host "This will never print."
    ```

    Luo myös tiedosto `preference_continue.ps1`, joka on muutoin identtinen, mutta muokkaa riviä yksi. Aseta se muotoon `$ErrorActionPreference = "Continue"`. Aja molemmat tiedostot ja vertaa tuloksia.

### Write-Something

Yksi luonnollinen tapa debugata lähes mitä tahansa ohjelmointikieltä on tulostaa muuttujien arvo kesken skriptin terminaaliin. Tämä ei kuulosta rakettitieteeltä, mutta voi olla hyvin tehokas tapa debugata. Bashin kanssa ehkä opit, että `echo`-komentoja on ärsyttävä lisätä ja poistaa tarpeen mukaan. Käsin lisätty `-v` option (verbose) auttaa, mutta vaatii argumenttien parsimista ja if-lausekkeita. Yksi tapa on ohjata komennot `stderr`-virtaan, mutta se on sinänsä vääräoppista, että debug-viestit eivät varsinaisesti ole virheitä.

PowerShell tarjoaa tähän ratkaisun tukemalla useita eri virtoja. Näitä on useita. Alla olevassa esimerkissä käytämme virtoja: Success (1), Verbose (4) ja Warning(3). Verbose ei tulostu ruudulle tavallisesti, mutta jos asetat preference variablen `VerbosePreference` arvoksi `Continue`, näet myös Debug-virran tulosteet. Lue lisää ohjeista about_Output_Streams sekä about_Preference_Variables.

```powershell title="streams.ps1"
Write-Output "I am typical output!"
Write-Verbose "Ah, you must have VerbosePreference set up properly! 🕵️‍♀️"
Write-Warning "Warning! Warning! 🚨"
```

### Debuggaus

PowerShellissä on myös debugger, joka on käytettävissä Visual Studion Code -editorissa, olettaen, että PowerShell Extension on asennettuna. Voit käynnistää sen painamalla `F5`. Se on erityisen hyödyllinen breakpoint-toiminnon avulla esimerkiksi silmukoiden debuggaamisessa.

Tutustumme tämän käyttöön live-tunneilla.

## Tehtävät

??? question "Tehtävä: Devausympäristö ja runpwsh.sh"

    !!! warning

        Huomaa, että jos työskentelet siten, että Windows on host-käyttöjärjestelmäsi, voit kirjoittaa tämän saman skriptin PowerShell-kielellä. Tässä esimerkissä käytetään Bashia, koska kurssin oletuksena on Linux-host.

    PowerShell-osion ensimmäisessä koodaustehtävässä luot itsellesi devausympäristön. Pohja tätä varten sinulla pitäisi olla jo olemassa Bash-osiosta. Käytännössä luot:

    *  Hakemistorakenteen tehtävien vastauksia varten
    *  Skriptin `runpwsh.sh`, joka joko:
        *  Ajaa valitun skriptin kontissa
        *  Käynnistää interaktiivisen shellin (pwsh)
    *  Varmistat, että kaikki on versionhallinnassa
  
    Jatka samassa repositoriossa työskentelyä, missä olet jo aiemmin työskenenlly. Jatka rakennetta seuraavanalaisesti:

    ```plaintext
    johnanderton
    ├── README.md
    ├── bash/
    ├── pwsh
    |   ├── README.md
    │   ├── runpwsh.sh  # Uusi tiedosto
    │   ├── .help/      # Uusi hakemisto
    │   └── scripts/    # Uusi hakemisto
    └── python
        └── .gitkeep
    ```

    Tiedoston `runpwsh.sh` luominen olisi hyvää kertausta Bash-osiosta, mutta jotta voimme keskittyä PowerShell-osioon, voit ladata skriptin tämän repositorion polusta: [gh:sourander/skriptiohjelmointi/exercise-assets/scripts/runpwsh.sh](https://raw.githubusercontent.com/sourander/skriptiohjelmointi/refs/heads/main/exercise-assets/scripts/runpwsh.sh)

??? question "Tehtävä: PowerShell Hello World"

    Luo skripti `hello.ps1, joka tulostaa terminaaliin tekstin "Hello World!".

    Sijoita se repositorion juuresta lukien relatiiviseen polkuun `pwsh/scripts/hello.ps1`. Aja skripti `./runpwsh.sh scripts/hello.ps1` ja varmista, että se tulostaa "Hello World!". Käytä alla olevaa templaattia:

    ```powershell title="hello.ps1"
    # IMPLEMENT
    ```


??? question "Tehtävä: PowerShell Turboahdettu Hello World"

    ```powershell title="hello_turbo.ps1"
    <#
    .SYNOPSIS
        Prints "Hello World!" to the terminal.

    ... ADD MORE HELP HERE ...
    #>

    # IMPLEMENT
    ```

    Jalosta yllä näkyvää skriptin alkua. Lopullisen skriptin tulisi:

    * tulostaa absoluuttinen polku työhakemistoon
    * tulostaa absoluuttinen polku skriptin sijaintiin
    * tulostaa `PSEdition`-muuttujan arvon, mutta vain Debug-virtaan.
    * tukea `Get-Help`-komentoa. Implementoi ainakin:
        * Synopsis (yllä)
        * Description
        * Example

    Ohjelman tulosteen pitäisi käyttäytyä seuraavanlaisesti:

    ```pwsh-session title="🐳 PowerShell"
    PS> pwsh /app/scripts/hello_turbo.ps1
    ========= Turbo Hello World! =========
    Current working directory:     /
    Script directory:              /app/scripts
    
    PS> cd root

    PS> $VerbosePreference = "Continue"
    
    PS> pwsh /app/scripts/hello_turbo.ps1
    ========= Turbo Hello World! =========
    Current working directory:     /root
    Script directory:              /app/scripts
    VERBOSE: Your PowerShell Edition:       Core
    ```

    Varmista, että osaat tulostaa komennon helpin termiinaaliin.

    ??? tip "Vinkki: Get-Help"

        Huomaa `<# ... #>` tiedoston alussa. Tämä on monirivinen kommentti.

    ??? tip "Vinkki: src_path"

        Katso `about_automatic_variables` ja `$MyInvocation`.



??? question "Tehtävä: Save-Help"

    Tehtävänäsi on tallentaa `.help/powershell-help`-hakemistoon PowerShellin help-tiedostot.

    Jos ajoit [PowerShell 101](aloita.md)-osion komentoja, huomasit varmasti, että `Update-Help`-komennon suorittamisessa kestää tovin. Se lataa Help-tiedostot verkosta. Tämä pitäisi ajaa joka kerta uusiksi, kun avaamme PowerShellin konttiin. Nopeutetaan tätä siten, että tallennetaan meille lokaali offline-kopio helpistä.

    Skriptissä `runpwsh.sh` on määritetty bind mount read-write oikeuksin seuraavasti:

    | Host                    | Container              |
    | ----------------------- | ---------------------- |
    | `.help/powershell-help` | `/srv/powershell-help` |


    Nyt tehtävänäsi on tallentaa help-tiedostot kontin hakemistoon, joka on bind-mountattu sinun host-koneellesi. Alla on ajettavat komennot. Huomaa, että komennot tulee ajaa kontissa, ei sinun host-koneellasi.

    ```powershell title="🐳 PowerShell"
    # Create the directory
    New-Item -ItemType Directory -Path /.help/PowerShellHelp

    # Save the help files
    Save-Help -DestinationPath /.help/PowerShellHelp
    ```

    !!! tip

        Vaihtoehtoinen tapa tälle tehtävälle olisi luoda oma Dockerfile ja rakentaa siltä pohjalta image, joka sisältää päivitetyn helpin. Vältellään kuitenkin `docker buildx`:ää tällä kursilla ja pysytään skriptien ajamisen parissa.


??? question "Tehtävä: gitignore .help"

    Lisää lopuksi `.help/`-hakemisto sinun `.gitignore`-tiedostoon. Tiedostot ovat aina ladattavissa netistä, joten niiden säilöminen pitkäaikaisesti omana kopiona Gitlabiin olisi turhuutta.

    ```bash title=".gitignore"
    # ...ehkä jotain muuta...

    # PowerShell help
    .help/
    ```


??? question "Tehtävä: localhelp.ps1"

    Jatkossa voit instansoida uuden kontin ja ottaa lokaalisti tallennetun helpin käyttöön näin:

    ```powershell title="🐳 PowerShell"
    Update-Help -SourcePath /srv/powershell-help
    ```

    Hakemisto on kuitenkin `.gitignore`-tiedostossa, joten voi olla, että päädyt ajamaan tätä koodia uudella koneella. Siispä on tarpeellista luoda `localhelp.ps1`-skripti, joka:

    * Päivittää helpin aina, jos `-Update`-parametri on annettu
        * Ajaa: `Save-Help -DestinationPath /var/powershell-help`
    * Lataa helpin, päivittyi se tai ei.
        * Ajaa: `Update-Help -SourcePath /var/powershell-help`

