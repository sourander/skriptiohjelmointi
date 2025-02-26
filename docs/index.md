# Tervetuloa kurssille

Kurssilla tutustutaan skriptiautomaatioon eri skriptauskielien kautta. Kurssin ohjeistus on kirjoitettu Ubuntu-jakelua ajatellen. Valtaosa tehtävistä suoritetaan Docker-konteissa, mitkä toimivat kaikilla käyttöjärjestelmillä, mutta tietyt tehtävät vaativat merkittävästi vähemmän säätöä Linux-ympäristössä. Helpoimman kokemuksen saat fyysisesti koneelle asennetulla Ubuntulla. Mikäli sinulla ei ole pääsyä omaan Linux-koneeseen, suosittelen tekemään tehtävät Linux-luokassa.

!!! warning
    
    Käytämme kurssilla Ansiblea. Ansible Control Noden *requirement* on UNIX-like -käyttöjärjestelmä. Microsoft WSL2-virtuaalikone voi toimia, mutta ei ole Ansiblen dokumentaation mukaan natiivisti tuettu. Myös verkotukset control nodejen ja managed noden välillä voivat aiheuttaa ongelmia, kuten myös mahdollinen nestattu virtualisointi.
    
    Käytämme myös **multipassia**, jolla luodaan lyhytikäisiä virtuaalikoneita silloin, kun tarvitaan kone, joka edustaa *koko käyttöjärjestelmää* varmemmin kuin kontti, joka on pikemminkin eristetty yksittäinen prosessi. Myös tätä voit korvata WSL2:n avulla, mutta se vaatii huomattavaa oma-aloitteisuutta viankorjauksessa. Muut työkalut, kuten Vagrant, eivät poista ongelman juurisyytä.

    Opettaja auttaa toki resurssien salliessa, mutta sinua on varoitettu!

Kurssin tavoitteena on antaa opiskelijalle valmiudet lukea ja kirjoittaa skriptejä, jotka automatisoivat arkipäiväisiä tehtäviä. Tämä opetellaan siten, että skriptejä testataan lyhytikäisessä, väliaikaisessa ympäristössä, joka on helppo tuhota ja luoda uudelleen – eli konteissa ja virtuaalikoneissa. Skriptien käyttö edesauttaa automatisointia, vähentää inhimillisiä virheitä, mahdollistaa tehdyn työn toistettavuuden sekä muutosten jäljitettävyyden versionhallinnan avulla. Kurssi on vain pintaraapaisu: varsinaiset taidot karttuvat, kun otat nämä opit käyttöön tulevissa kursseissa, projekteissa ja työelämässä.

![](images/automation-by-dalle.jpg)

**Kuva 1.** DALL-E 3:n näkemys skriptiautomaatiosta.


## Kursin rakenne

Kurssin kukin osio (Bash, PowerShell, ...) rakentuu edellisen päälle siten, että Bashistä opittuja taitoja voidaan hyödyntää seuraavissa osioissa ja niin edelleen. Tällä kurssilla ei opetella teoriaa tenttiä varten vaan tehdään kasapäin harjoituksia. Kussakin osiossa sinua neuvotaan, mistä lähteistä löytää avaimet ratkaisuihin - yleensä lähde on *cheat sheet*-tyylinen opas, referenssimanuaali tai kirja. Myös tekoälyä (kielimalleja) ja Cookbook-tyylisiä valmiita aihioita kannattaa hyödyntää. Noudata kuitenkin Dowstin neuvoa:

> "At the same time, do not just copy and paste code from GitHub or StackOverflow into your script and expect everything to work. Instead, look at the code" 
> 
> – Matthew Dowst, Practical Automation with PowerShell

Skriptauskielten (Bash, PowerShell, Python) osiot käydään läpi seuraavanlaisesti:

* **Kieli 101:** Kokonaiskuva kielestä ja lähteiden kartoitus.
* **Lukeminen:** Tutustutaan syntaksiin valmiin skriptin avulla.
* **Harjoitusosiot:** Tehtäväpaketteja alkuaineittain.
    * **💡 Gallium**. Devausympäristön pystytys.
    * **🎆 Strontium**. Harjoituksia.
    * **👩‍🔬 Curium**. Lisää harjoituksia.
    * **👨‍🔬 Einsteinium**. Viimeiset harjoitukset.

Alkuaineittain järjestetyt tehtävät Galliumista Einsteiniumiin ovat tarkoitetut järjestyksessä suoritettaviksi. Jaottelu auttaa sinua palastelemaan tehtäviä omalle TODO-listallesi. Huolehdithan omasta ajankäytöstäsi ja kurssin harjoitusten tasaisesta etenemisestä. Älä missään nimessä yritä jättää kaikkea viimeiseen iltaan!

## Edeltävyysvaatimukset

Sinun täytyy olla valmiiksi sinut komentorivin kanssa. Linux Perusteet -kurssin käyminen ennen tätä kurssia on edellytys. Lisäksi on äärimmäisen suositeltavaa, että osaat vähintään yhdestä ohjelmointikielestä perusteet siten, että alla esitellyt termit eivät ole sinulle täysin vieraita. Kurssi voi olla hyvää kertausta näistä aiheista, mutta ethän saavu paikalle täysin vihreänä. Muutoin oppimiskokemus voi olla turhauttava.

* **Muuttujat:** int, float, string, ...
* **Ehtolauseet:** if, else, case/switch
* **Silmukat:** for, while, foreach
* **Funktiot:** do_something(param1, param2)
