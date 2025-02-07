# Tervetuloa kurssille

Kurssilla tutustutaan skriptiautomaatioon eri skriptauskielien kautta. Kurssi nojaa Linuxin suuntaan, mutta käsittelee myös pintapuoleisesti Windows-ympäristöjä - erityisesti PowerShell-osiossa. Kursin ohjeistus on kirjoitettu Ubuntu-järjestelmää silmällä pitäen. Valtaosa tehtävistä suoritetaan Docker-konteissa, mitkä toimivat kaikilla käyttöjärjestelmillä, mutta tietyt tehtävät vaativat merkittävästi vähemmän säätöä Linux-ympäristössä. Helpoimman kokemuksen saat fyysisesti koneelle asennetulla Ubuntulla.

!!! warning
    
    Kurssilla käytetään Ansiblea. Ansible Control Noden *requirement* on UNIX-like -käyttöjärjestelmä. Microsoft WSL2 voi toimia, mutta ei ole natiivisti tuettu. Lisäksi käytämme **multipassia** Ansible Managed Nodejen luomiseen. Nestattu virtualisointi voi aiheuttaa ongelmia; todennäköisesti Windows-käyttäjien on pakko tarttua VirtualBoxiin [Multipassin driverinä](https://canonical.com/multipass/docs/local-driver). Virtuaalikoneiden luomiseen käytetyt Multipassin korvaaminen Vagrantilla ei poista ongelmaa.

    Opettaja auttaa toki resurssien salliessa, mutta sinua on varoitettu!

Kurssin tavoitteena on antaa opiskelijalle valmiudet lukea ja kirjoittaa skriptejä, jotka automatisoivat arkipäiväisiä tehtäviä. Skriptien käyttö edesauttaa automatisointia, vähentää inhimillisiä virheitä, mahdollistaa tehdyn työn toistettavuuden sekä muutosten jäljitettävyyden versionhallinnan avulla. Kurssi on vain pintaraapaisu: varsinaiset taidot karttuvat, kun otat nämä opit käyttöön tulevissa kursseissa, projekteissa ja työelämässä.

![](images/automation-by-dalle.jpg)

**Kuva 1.** DALL-E 3:n näkemys skriptiautomaatiosta.

## Kurssin laajuus

Kurssialue on jaettu eri otsakkeiden alle (Bash, PowerShell, ...). Tyypillisesti kurssi käydään 5 opintopisteen kokonaisuutena, mutta moduulien lainaaminen muille kursseille ei ole aivan tavatonta. Tavoitellut laajuudet ovat:

| Otsikko    | Laajuus | Avg. kuormitus |
| ---------- | ------- | -------------- |
| Bash       | 1 op    | 27 h           |
| PowerShell | 1 op    | 27 h           |
| Python     | 1 op    | 27 h           |
| Ansible    | 2 op    | 54 h           |

## Kursin rakenne

Kurssin kukin osio (Bash, PowerShell, ...) rakentuu edellisen päälle siten, että Bashistä opittuja taitoja voidaan hyödyntää seuraavissa osioissa ja niin edelleen. Tällä kurssilla ei opetella teoriaa ulkoa vaan tehdään kasapäin harjoituksia. Kussakin osiossa sinua neuvotaan, mistä lähteistä löytää avaimet ratkaisuihin - yleensä lähde on *cheat sheet*-tyylinen opas, referenssimanuaali tai kirja. Myös tekoälyä (kielimalleja) kannattaa hyödyntää. Noudata kuitenkin Dowstin neuvoa:

> "At the same time, do not just copy and paste code from GitHub or StackOverflow into your script and expect everything to work. Instead, look at the code" 
> 
> — Matthew Dowst, Practical Automation with PowerShell

Skriptauskielten (Bash, PowerShell, Python) osiot eivät juuri esittele teoriaa. Ne käydään läpi seuraavanlaisesti:

* **Kieli 101:** Kokonaiskuva kielestä ja lähteiden kartoitus.
* **Lukeminen:** Tutustutaan syntaksiin valmiin skriptin avulla.
* **Harjoitusosiot:** Tehtäväpaketteja alkuaineittain.
    * **💡 Gallium**. Devausympäristön pystytys.
    * **🎆 Strontium**. Harjoituksia.
    * **👩‍🔬 Curium**. Lisää harjoituksia.
    * **👨‍🔬 Einsteinium**. Viimeiset harjoitukset.

Alkuaineittain järjestetyt tehtävät Galliumista Einsteiniumiin on tarkoitettu tehtäväksi järjestyksessä. Tehtävät on jaoteltu näin siksi, että sinun on helpompi ottaa työlistalle viikoittain muutama tehtävä kerrallaan. Yhden otsakkeen alla olevat tehtävät liittyvät usein toiminnallisesti tai teemallisesti toisiinsa, joten ne on luonteva tehdä kerralla.

## Edeltävyysvaatimukset

Sinun täytyy olla valmiiksi sinut komentorivin kanssa. Linux Perusteet -kurssin käyminen ennen tätä kurssia on edellytys. Lisäksi on äärimmäisen suositeltavaa, että osaat vähintään yhdestä ohjelmointikielestä perusteet siten, että alla esitellyt termit eivät ole sinulle täysin vieraita.  ==Jos esimerkiksi muuttujan käsite on sinulle vieras==, tästä kurssista voi tulla haastavampi kuin on tarpeellista — käy ensin jokin peruskurssi ohjelmoinnista. Kurssi voi olla hyvää kertausta näistä aiheista, mutta ethän saavu paikalle täysin vihreänä.

* **Muuttujat:** int, float, string, ...
* **Ehtolauseet:** if, else, case/switch
* **Silmukat:** for, while, foreach
* **Funktiot:** do_something(param1, param2)
