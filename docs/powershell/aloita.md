---
priority: 200
---

# PowerShell 101

## Perusteet

### Missä ajetaan?

Jotta sinun on mahdollista tehdä tämän kurssin tehtäviä, sinulla on oltava PowerShell käytössä. Jos teet skriptejä, jotka poistavat tiedostoja tai tekevät jotakin muuta vaarallista, on suositeltavaa ajaa PowerShelliä Docker-kontissa. Tämän pitäisi olla sinulle tuttua jo aiemmasta Bash-osiosta.

```pwsh title="Bash | Git Bash | PowerShell | CMD"
docker container run --rm -it mcr.microsoft.com/powershell 
```

??? warning "🍎 Apple Silicon -käyttäjille"

    Jos olet macOS-käyttäjä, yllä mainittu image ei välttämättä toimi. Jos kyseinen image kaataa Terminaalin jatkuvasti, kokeile arm64:lle käännettyä imagea, joka perustuu Microsoftin kehittämään Mariner-jakeluun (alias Azure Linux).

    ```
    # macOS ARM64
    docker container run --rm -it mcr.microsoft.com/powershell:mariner-2.0-arm64
    ```

Docker-komento ja sen parametrit (`--rm` ja `-it`) ovat sinulle jo tuttuja Bash-osiosta. Alla olevassa koodissa tulostetaan PowerShellin versio Docker-kontissa, jota ajetaan arm64-arkkitehtuurin päällä.

```pwsh title="PowerShell @ Docker"
$PSVersionTable
```

```plaintext title="stdout @ Docker"
Name                           Value
----                           -----
PSVersion                      7.4.6
PSEdition                      Core
GitCommitId                    7.4.6
OS                             CBL-Mariner/Linux
Platform                       Unix
PSCompatibleVersions           {1.0, 2.0, 3.0, 4.0…}
PSRemotingProtocolVersion      2.3
SerializationVersion           1.1.0.1
WSManStackVersion              3.0
```

!!! tip

    Jos haluat harjoitella Microsoft Windows -spesifisiä komentoja, kuten `Get-Service`, tarvitset Windows-ympäristön. Docker on tyypillisesti vain ja ainoastaan Linux-ympäristöjä varten, joten helpoimmalla pääset todennäköisesti virtuaalikoneen avulla.

### Mikä se on?

PowerShell on Microsoftin kehittämä skriptauskieli ja komentotulkki. Se on suunniteltu erityisesti Windows-ympäristöön, mutta nykyään se on saatavilla myös Linuxille ja macOS:lle. Jos tarkkoja ollaan, niin tuotteita on kaksi, joista vain toinen on saatavilla muille kuin Windowsille:

* Windows PowerShell
    * Asentuu Windowsin mukana. Perustuu kaupalliseen .NET Frameworkiin. Tuorein versio on 5.1 eikä Microsoft enää kehitä sitä.
    * Executable: `powershell.exe`
* PowerShell (Core)
    * Asennetaan erikseen. Perustuu avoimeen .NET Coreen. Tuorein versio on 7.x ja Microsoft kehittää sitä aktiivisesti. Tarkista tuorein versio [What is PowerShell](https://learn.microsoft.com/en-us/powershell/scripting/overview)-dokumentaatiosta.
    * Executable: `pwsh`

Huomaa, että PowerShell ei ole täysin alustariippumaton. Et voi kehittää Microsoft Windows -ympäristössä skriptiä ja olettaa sen toimivan sellaisenaan Linuxissa - riippuen tietysti siitä, mitä skripti tekee. Esimerkiksi moduulin `Microsoft.PowerShell.Management` komento `Get-Service` ei toimi Linuxissa.

> "A key difference with Bash is that it is mostly objects that you manipulate rather than plain text" [^learn_pwsh_in_y_minutes]

[^learn_pwsh_in_y_minutes]: Schandevijl et. al. 2025. Learning PowerShell in Y Minutes. https://learnxinyminutes.com/powershell/

Kuten yllä olevassa lainauksessa todetaan, PowerShellissä käsitellään pääasiassa objekteja. Tämä tulee jatkumaan myöhemmin Python-osiossa: myös se kieli on rankasti objekteihin suuntautunut. Käytännössä tämä tarkoittaa sitä, että esimerkiksi kokonaisluku on objekti, ja objektilla on metodeja. Voit siis kutsua yhden rivin rimpsun, jossa muodostetaan muuttuja ja kutsutaan sen metodia näin: `$number = 10; $number.GetType()`. Ruutuun tulostuu taulukkomuotoinen näkymä, jonka sisällöstä ja muodosta vastaa [Out-Default](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/out-default).

Varsinaiset komennot ovat `cmdlet`-tyyppisiä. Ne koostuvat verbistä ja substantiivista. Alla esimerkki:

* `Verb-Noun`: pseudoesimerkki
* `Get-Process`: hakee prosessit
* `Get-Alias`: hakee aliasit komennoilla (esim. `dir` on `Get-ChildItem` komennon alias)
* `Update-Help`: päivittää PowerShellin helpin, ladaten rutkasti esimerkkejä ja lisäapua.

Mistä tahansa komennosta saat helpin muutamalla eri tavalla. Alla esimerkkejä, joissa halutaan saada lisää tietoa Get-ChildItem-komennosta:

```pwsh
# Kenties alkuun haluat ajaa:
Update-Help

# Get-Noun muoto
Get-Help Get-ChildItem

# Huomaa, että se ei ole case-sensitiivinen
get-help get-childitem

# Lyhyt muoto
help Get-ChildItem

# Kysymysmerkki
Get-ChildItem -?
```

```pwsh
Verb-Noun -parameter value -anotherparameter anothervalue -switch
```

Kyseinen `Verb-Noun`-cmdlet-pohjainen syntaksi on PowerShellin ydin. Esimerkiksi `Get-Process` hakee prosessit ja `Stop-Process` pysäyttää prosessin.




## Skripti

Aivan kuten Bashin kohdalla, myös PowerShellissä skripti on tiedosto, joka sisältää yhden tai useamman komennon.

### Tiedoston sisältö

```pwsh title="hello.ps1"
Write-Host "Hello, World!"
```

### Skriptien suorituspolitiikka

On tärkeää huomata, että jos ajat PowerShelliä Windows-ympäristössä, sinun tulee ottaa huomioon execution policy. Kyseinen asetus säätää sitä, missä tapauksissa skriptejä saa suorittaa. Tavallisessa Windows Home/Pro -ympäristössä execution policy on **Restricted**, joka tarkoittaa, että ==mitään skriptejä ei saa ajaa==. Tämä on toki turvallinen asetus, mutta se estää sinua ajamasta omia skriptejäsi. Yleisesti suositeltu asetus on **RemoteSigned**, joka sallii paikallisesti luodut skriptit ja ulkopuoliset skriptit, jotka on allekirjoitettu. 

Jos et ole aikaisemmin tehnyt mitään PowerShell-skriptien ajoon liittyviä toimenpiteitä, suorita seuraava komento:

```pwsh title="PowerShell in Windows"
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

!!! tip

    Jos ajat PowerShelliä Docker-kontissa, sinun ei tarvitse huolehtia tästä: policy on vakiona Unrestricted, eikä RemoteSigned ole edes tuettu.

??? warning "Tietoturva-offtopic"

    RemoteSigned ei välttämättä toimi aivan kuten sen arvaisi toimivan. Se, onko tiedosto Internetistä ladattu vai ei, määrittyy `Zone.Identifier` -attribuutin perusteella. Tämä on Windowsin turvamekanismi, joka estää tiedostojen suorittamisen, jos ne ovat tulleet Internetistä. Tämä ongelma on kuitenkin helppo kiertää: poista attribuutti tiedostosta. Jos kokeilet ladata `Invoke-RestMethod`-komennolla skriptin, saatat yllättyä, kun sillä ei olekaan koko Zone.Identifieriä asetettuna, vaikka voisi kuvitella. Tiedoston saa siis ladata aivan kuin se olisi paikallisesti luotu, vaikka juuri latasit sen Internetistä.

### Tiedoston luominen

Tiedoston voi luoda millä tahansa tekstieditorilla, mutta on suositeltavaa käyttää Visual Studio Codea. Lue lisää Microsoftin ohjeesta [Using Visual Studio Code for PowerShell Development](https://learn.microsoft.com/en-us/powershell/scripting/dev-cross-plat/vscode/using-vscode). Legacy Windows PowerShelliä voi kehittää myös sen mukana saapuvassa PowerShell ISE -ohjelmassa, mutta emme käsittele sitä laisinkaan tässä kurssissa. Käytämme VS Codea, PowerShell Corea ja PowerShell Extensionia VS Codessa.

Luodaan ensimmäinen tiedosto kuitenkin echottamalla tekstiä tiedoston hello.ps1 sisään:

```pwsh
echo 'Write-Host "Hello World!"' > hello.ps1
```

### Skriptin ajaminen

Syntynyeen tiedoston voi ajaa monella tapaa. Tyypillinen tapa on relatiivinen polku. Koska me olemme samassa hakemistossa kuin skripti, relatiivinen polku on yksintaisesti `./<tiedostonimi>`:

```pwsh
# Relatiivinen polku
./hello.ps1
```

Absoluuttista polkua käyttäen:

```pwsh
# Linux
/root/hello.ps1

# Windows
C:\Users\user\hello.ps1
```

Kyseisen binäärin argumenttina:

```pwsh
# PowerShell Core
pwsh ./hello.ps1

# Windows PowerShell
powershell.exe ./hello.ps1
```

## Tehtävät 

!!! question "Tehtävä: PowerShell Hello World"

    Luo skriptitiedosto `hello.ps1`, joka tulostaa tekstin "Hello World". 

    Varmista, että saat sen ajettua ympäristössä, jossa koet kehittämisen mieluisaksi. Saat käyttää fyysistä konetta, virtuaalikonetta, Dockeria tai vastaavaa.

    **Suositus**: Docker (PowerShell Core)

!!! question "Tehtävä: PowerShell informaatiohaku"

    Toimi kuten aiemmassa Bash-tiedonhakutehtävässä. Muodosta itsellesi hyödyllinen katalogi lähteistä. Alla muutama suositus, mistä aloittaa etsintä:

    1. [PowerShell Documentation](https://docs.microsoft.com/en-us/powershell/). Virallinen dokumentaatio. Varmista, että seuraat oikean version dokumentaatiota.
    2. [Markus Fleschutzin PowerShell repo](https://github.com/fleschutz/PowerShell). Sisältää sekä [cheat sheetin](https://github.com/fleschutz/PowerShell/blob/main/docs/cheat-sheet.md) että satoja PowerShell-skriptejä.
    3. [Learn PowerShell in Y Minutes](https://learnxinyminutes.com/powershell/). Cheat Sheet -tyylinen opas, josta selviää ydinasiat.
    4. [KAMK Finna](https://kamk.finna.fi/). Hakusanalla "PowerShell" löytyy esimerkiksi Jonathan Hassellin kirja "Learning PowerShell" vuodelta 2017.

    Myös Bashin kohdalla mainitut kirjalähteet eli KAMK Finna, Humble Bundlen ja O'Reillyn kirjasto ovat toimivia paikkoja etsiä tietoa - jälkimmäiset kaksi ovat toki maksullisia. Erityismaininnan arvoinen maksullinen kirja on Don Jones ja Jeffrey Hicksin [Learn PowerShell Scripting in a Month of Lunches 2nd ed. (Manning)](https://www.manning.com/books/learn-windows-powershell-in-a-month-of-lunches-second-edition).


## Lähteet