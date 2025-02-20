---
priority: 296
---

# 👩‍🔬 Curium

## Tärpit

### Pipeline

PowerShellissä on huomattavan tehokasta hyödyntää sitä, että merkkijonon sijasta meillä on käsiteltävänä objekteja. Tähän voi tutustua esimerkiksi seuraavan koodin avulla:

```powershell title="🐳 PowerShell"
Get-Item Env:PATH `
    | Select-Object -ExpandProperty Value `
    | ForEach-Object { $_ -Split [System.IO.Path]::PathSeparator } `
    | Resolve-Path `
    | Select-Object -Property Drive, Path, Provider 
```

Kyseinen koodi ajaa `Get-Item` komennon `Env:PATH`:iin. Palautuva entiteetti on tyyppiä `System.Collections.DictionaryEntry`. Tässä tyypissä, eli dictionarystä, on kentät `Key` ja `Value`. Näistä meitä kiinnostaa vain `Value`, joka on jatkossa vain tavallinen `[System.String]` eli merkkijono. Sen sijaan `Resolve-Path`:n jälkeen merkkijonosta muotoutuu merkittävästi abstraktimpi olio `[System.Management.Automation.PathInfo]`. Tämä olio sisältää tietoa polusta, asemasta ja palveluntarjoajasta - ja se automaattisesti tarkistaa, onko koko hakemisto olemassa.

Jos haluat muotoilla jotakin kenttää `Select-Object`-yhteydessä, se onnistuu alla olevalla komennolla. Kentän nimen sijasta syötät `@{}`-kentän eli hashtaulun, jossa on `Name` ja `Expression`-kentät. Expressinin sisällä `$_` viittaa jokaiseen objektiin pipelinesta eli tässä tapauksessa `PathInfo`-olioon.

```powershell title="env_objects.ps1"
$custom = @{ Name="Provider"; Expression={$_.Provider.Name} }

Get-Item Env:PATH 
    | Select-Object -ExpandProperty Value 
    | ForEach-Object { $_ -Split [System.IO.Path]::PathSeparator } 
    | Resolve-Path 
    | Select-Object -Property Drive, Path, $custom
```

```powershell-session title="🐳 Tuloste"
PS/> /app/scripts/env_objects.ps1
Drive Path                        Provider
----- ----                        --------
/     /opt/microsoft/powershell/7 FileSystem
/     /usr/local/sbin             FileSystem
/     /usr/local/bin              FileSystem
/     /usr/sbin                   FileSystem
/     /usr/bin                    FileSystem
/     /sbin                       FileSystem
/     /bin                        FileSystem
```

!!! tip

    Huomaa, että yllä oleva esimerkki on tarpeettoman monimutkainen tähän use caseen. Se on esillä, koska ympäristömuuttuja PATH on meille jo entuudestaan tuttu. Jos haluat yksinkertaisesti listata, mitä PATH sisältää, riittää käyttöjärjestelmän mukaan jompi kumpi seuraavista riveistä:

    ```powershell
    $env:PATH -Split ":"  # Linux
    $env:PATH -Split ";"  # Windows
    ```

## Tehtävät

??? question "Tehtävä: Pingviinien laskeminen"

    PowerShellissä pipeline siirtää datan objektin muodossa. Joskus se on ihan vain `System.String`, joskus se edustaa jotakin spesifiä luokkaa. Huomaa, että aiemmin oppimassamme Bashissä data on aina tekstirivejä. Jos haluaisit parsia sarakkeita, joudut käyttämään `awk`-työkalua tai vastaavaa.
    
    Selvitä, mitä kukin rivi alla olevassa koodissa tekee. Tutki, mitä dataa kukin komento saa ja mitä se palauttaa. Mikä olio on kyseeessä missäkin välissä?

    Koodirivit on valmiiksi numeroitu. Käytä kyseisiä numeroita viittaamaan riveihin ja kirjoita vastauksesi erilliseen moniriviseen kommenttiblokkiin. Halutessasi voit kirjoittaa dokumentaation esimerkiksi erilliseen Markdown-tiedostoon ja viitata siihen.

    ```powershell title="penguins.ps1"
    $URL = "https://raw.githubusercontent.com/mwaskom/seaborn-data/master/penguins.csv"
    $df = Invoke-WebRequest -Uri $URL               # 1
        | Select-Object -ExpandProperty Content     # 2
        | ConvertFrom-Csv                           # 3
        | Group-Object -Property species            # 4
        | Sort-Object -Property Count -Descending   # 5
        | Select-Object -Property Name, Count       # 6

    <#
    1: Select-Object
        Dokumentoi tähän ensimmäinen komento eli Select-Object.
        Tekstiä tekstiä tekstiä ja tekstiä et cetera et cetera.
        Tekstiä tekstiä tekstiä ja tekstiä et cetera et cetera.
    2: ConvertFromCsv
        ...
    6: Select-Object
        ...
    #>

    Write-Output $df
    ```

    ??? tip "Vinkki"

        Kommentoi muut paitsi ensimmäinen rivi blokista pois ja lisää seuraavaksi elementiksi pipelineen `| Get-Member` tai `| Format-Table`. Sitten tää tämä seuraavalle riville ja niin edelleen.

??? question "Tehtävä: Suurimmat ohjelmat"

    Luo skripti, joka tulostaa `n` kappaletta suurimpia binääritiedostoja `/usr/bin`-hakemistossa. Vakio `n = 5`, mutta käyttäjä voi syöttää sen. Esimerkki käytöstä alla:

    ```pwsh-session title="🐳 PowerShell"
    PS/> /app/scripts/largest_binaries.ps1 -n 7
    Name       Size (MB)
    ----       ---------
    gpg2           1.124
    bash           0.938
    ssh            0.825
    openssl        0.818
    gpgsm          0.566
    gpgv2          0.520
    ssh-keygen     0.499
    ```

??? question "Tehtävä: Duplikaattitiedostojen luominen"

    Tämä tehtävä toimii esiasteena seuraavalle tehtävälle. Luo skripti, joka kirjoittaa tiedostoihin sisältöä siten, että osa tiedostoista on tarkoituksella toistensa kopioita. Osa tiedostoista tulee sen sijaan olla uniikkeja. Voit käyttää apuna seuraavanlaista jakoa:

    ```powershell title="add_duplicates.ps1"
    $duplicateFiles = @(
        "$DTEMP/foo.txt",
        "$DTEMP/foo_copy.txt",
        "$DTEMP/nested/foo_copy_nested.txt"
    )

    $uniqueFiles = @(
        "$DTEMP/unicorn_a.txt",
        "$DTEMP/nested/unicorn_b.txt"
    )
    ```

    Lopulta ohjelmaa tulisi voida käyttää seuraavanlaisesti:

    ```pwsh-session title="🐳 PowerShell"
    PS /> /app/scripts/add_duplicates.ps1
    Duplicate files have been created in: /tmp/20250217_duplicates

    PS /> Get-Content /tmp/20250217_duplicates/foo.txt
    This is some duplicate content.

    PS /> Get-Content /tmp/20250217_duplicates/nested/foo_copy_nested.txt
    This is some duplicate content.

    PS /> Get-Content /tmp/20250217_duplicates/unicorn_a.txt             
    5f976325-d704-403f-8442-66b626989aa0

    PS /> Get-Content /tmp/20250217_duplicates/nested/unicorn_b.txt      
    e3c216bf-f020-402a-beb4-7e838044776d
    ```

    !!! tip "Uniikki sisältö"

        Uniikkiä sisältöä on helppo luoda `Get-Uuid`-funktiolla.

??? question "Tehtävä: Duplikaattien tunnistaminen"

    Luo skripti, joka tunnistaa duplikaatit annetussa hakemistossa. Mikäli `-Recurse` option on annettu, sen tulisi käydä myös alihakemistot läpi. Duplikaatit tulisi tunnistaa tiedoston MD5-hashin perusteella. Lopullisen sovelluksen tulisi vastata `Get-Help`-komentoon seuraavaa sisältöä myötäilevällä tavalla:

    ```plaintext
    NAME
    /app/scripts/find_duplicates.ps1
    
    SYNOPSIS
        Find duplicate files in a directory (or recursively in subdirectories).
    
    SYNTAX
        /app/scripts/find_duplicates.ps1 [[-Path] <String>] [-Recurse] [<CommonParameters>]
    ```

    Testaa ohjelma sekä `-Recurse` parametrilla että ilman käyttäen kohteena aiemman `add_duplicates.ps1`-skriptin luomaa hakemistoa. Esimerkki alla:

    ```pwsh-session title="🐳 PowerShell"
    PS /> /app/scripts/find_duplicates.ps1 /tmp/20250217_duplicates/ -Recurse
    WARNING: Duplicate files found:

    FullName                                            Hash
    --------                                            ----
    /tmp/20250217_duplicates/foo_copy.txt               EAACC3FB772804B7670032CF1ACCBF79
    /tmp/20250217_duplicates/foo.txt                    EAACC3FB772804B7670032CF1ACCBF79
    /tmp/20250217_duplicates/nested/foo_copy_nested.txt EAACC3FB772804B7670032CF1ACCBF79
    ```

    !!! warning

        Varmista, että uniikit `/tmp/yyyymmdd_duplicates/unicorn_a.txt` ja `.../nested/unicorn_b.txt` eivät näy duplikaatteina.

    !!! tip

        Muistathan yhä ajaa `Invoke-ScriptAnalyzer`-komennon kaikille skripteillesi! Tämän skriptin kohdalla tulet huomaamaan varoituksen: `The Algorithm parameter of cmdlet 'Get-FileHash' was used with the broken algorithm 'MD5'.`

        MD5 ei suinkaan ole *rikki*, mutta se ei ole kryptaukseen liittyvissä yhteyksissä riittävän vahva. Voit sivuuttaa tämän varoituksen lisäämällä seuraavat rivit skriptisi alkuun:

        ```powershell
        [Diagnostics.CodeAnalysis.SuppressMessage(
        "PSAvoidUsingBrokenHashAlgorithms",
        "",
        Justification = "We are using MD5 for non-cryptographic purposes."
        )]
        ```