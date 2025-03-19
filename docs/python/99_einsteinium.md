---
priority: 399
---

# 👨‍🔬 Einsteinium

## Tärpit

TODO

## Tehtävät

??? question "Tehtävä: Arvaa luku botti"

    Tämän tehtävän voi tehdä helpotettuna tai haastavana versiona. Helpostetussa versiossa korjaat tämän alla olevan koodin siten, että se pelaa `arvaaluku.py`-pelin läpi brute forcena eli syöttäen kaikki numerot 1:stä 1000:een, kunnes oikea ratkaisu löytyy. Lisäksi sinun tulee kommentoida koodi tai muutoin varmistaa, että ymmärrät, mitä koodi tekee.
    
    Haastavassa versiossa jatkat koodia siten, että implementoit kesken jääneen `binary_search()`-funktion loppuun ja lisäät mahdollisuuden vaihtaa ko. *solveriin* skriptin argumenttien avulla.

    Huomaa, että skriptiin on rautakoodattuna oletuksia `arvaaluku.py`-skriptin toiminnasta. Muokkaa jompaa kumpaa skriptiä, jotta ne toimivat yhteen.

    !!! note "Oletus 1"

        On oletus, että pyyntö sisältää sanan `syötä`, ja että tämä tulostetaan *erikseen* ennen `input()`-funktiota. Muutoin Pipe on huomattavan vaikea saada toimimaan reaktiivisesti kysymysten kanssa.

        ```python
        print("\nSyötä arvaus:")
        guess = int(input())
        ```

    !!! note "Oletus 2"

        On oletus, että ohjelman tuloste sisältää sanan `oikein` kun arvaus on oikein. Tämä on tärkeää, jotta solveri voi tietää, milloin lopettaa arvaaminen.

        ```python
        print(f"🎉 Oikein! ...")
        ```

    !!! tip 

        Kannattaa myös lisätä koodiin rivi, joka tulostaa oikean vastauksen. Tämä helpottaa testaamista ja sen tulkitsemista, että löytääkö `arvaaluku_bot.py` oikean vastauksen vai ei.

    ??? tip "Opettajan vihjekoodi"

        ```python title="arvaaluku_bot.py"
        import subprocess
        from pathlib import Path

        def brute_force(pipe: subprocess.Popen) -> int:
            guess = 1
            while guess < 1001:

                output = pipe.stdout.readline().strip()
                reply = None

                if output.startswith("Oikea"):
                    print(f"[PRE-GAME] {output}")
                    continue

                if "syötä" in output.lower():
                    pipe.stdin.write("500\n")
                    pipe.stdin.flush()
                    reply = pipe.stdout.readline().strip().lower()
                
                if reply:
                    if "oikein" in reply:
                        return guess
                    guess += 1

            return -1 # Not found

        def binary_search(pipe: subprocess.Popen) -> int:
            pass

        def guess_number(script: Path, solver):
            process = subprocess.Popen(
                [ "python", script],
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                text=True, 
                encoding="utf-8"
            )

            # Call the solver function
            print(f"[INFO] Solver: {solver.__name__}")
            correct = solver(process)
            process.terminate()

            return correct

        if __name__ == "__main__":
            
            SCRIPT = Path("./scripts/arvaaluku.py")
            assert SCRIPT.exists(), f"Script not found: {SCRIPT.resolve()}"
            
            # Extra challenge: Handle different solvers with argparse
            # solvers = [brute_force, binary_search]
            # ...
            # solver = solvers[args.solver]
            solver = brute_force

            correct = guess_number(SCRIPT, solver)
            print(f"[MAIN] Correct number: {correct}")
        ```

    Alla on esiteltynä lopullinen koodin toimivuus ja käyttö `brute_force`-solverilla. Huomaa, että tuloste on säädetty siten, että se tulostaa vain `guess == 1` tai `guess % 50` arvaukset, jotta tuloste ei ole liian pitkä. Siksi vain joka viideskymmenes arvaus tulostetaan.

    ```console title="🐳 Bash"
    $ python scripts/arvaaluku_bot.py 
    [INFO] Solver: brute_force
    [PRE-GAME] Oikea vastaus: 380
    [BOT] Guessing: 1
    [>>>] 📈 luku on suurempi kuin 1.
    [BOT] Guessing: 50
    [>>>] 📈 luku on suurempi kuin 50.
    [BOT] Guessing: 100
    [>>>] 📈 luku on suurempi kuin 100.
    [BOT] Guessing: 150
    [>>>] 📈 luku on suurempi kuin 150.
    [BOT] Guessing: 200
    [>>>] 📈 luku on suurempi kuin 200.
    [BOT] Guessing: 250
    [>>>] 📈 luku on suurempi kuin 250.
    [BOT] Guessing: 300
    [>>>] 📈 luku on suurempi kuin 300.
    [BOT] Guessing: 350
    [>>>] 📈 luku on suurempi kuin 350.

    === Found ===
    [>>>] 🎉 oikein! arvasit luvun 380. (peliaika: 0h 0m 0s)
    [MAIN] Correct number: 380
    ```

    Alta voit klikata auki binary search -tulosteesta esimerkin:

    ??? tip "Binary Search tuloste"

        ```console
        python scripts/arvaaluku_bot.py 1
        [INFO] Solver: binary_search
        [PRE-GAME] Arvaa luku väliltä 1-1000.
        [PRE-GAME] Muu syöte kuin positiviinen kokoluku poistuu ohjelmasta.
        [PRE-GAME] Oikea vastaus: 622
        [PRE-GAME] 
        [PRE-GAME] Syötä arvaus:
        [BOT] Guessing: 500 (1⸺1000)
        [>>>] 📈 luku on suurempi kuin 500.
        [BOT] Guessing: 750 (501⸺1000)
        [>>>] 📉 luku on pienempi kuin 750.
        [BOT] Guessing: 625 (501⸺749)
        [>>>] 📉 luku on pienempi kuin 625.
        [BOT] Guessing: 562 (501⸺624)
        [>>>] 📈 luku on suurempi kuin 562.
        [BOT] Guessing: 593 (563⸺624)
        [>>>] 📈 luku on suurempi kuin 593.
        [BOT] Guessing: 609 (594⸺624)
        [>>>] 📈 luku on suurempi kuin 609.
        [BOT] Guessing: 617 (610⸺624)
        [>>>] 📈 luku on suurempi kuin 617.
        [BOT] Guessing: 621 (618⸺624)
        [>>>] 📈 luku on suurempi kuin 621.
        [BOT] Guessing: 623 (622⸺624)
        [>>>] 📉 luku on pienempi kuin 623.
        [BOT] Guessing: 622 (622⸺622)
        [>>>] 🎉 oikein! arvasit luvun 622. (peliaika: 0h 0m 0s)
        [MAIN] Correct number: 622
        ```

        Huomaa, että vastaus löytyy huonoimmassa tapauksessa `log2(1000)` eli ==kymmenellä arvauksella==, mikä on huomattavasti nopeampaa kuin brute force -ratkaisu, joka vaatii huonoimmassa tapauksessa 1000 arvausta.

!!! question "Tehtävä: Paste.ee"

    TODO.

!!! question "Tehtävä: Premiere Markers to YouTube"

    Lataa tämä tiedosto: [gh:sourander/skriptiohjelmointi/exercise-assets/data/premieremarkers.txt](https://raw.githubusercontent.com/sourander/skriptiohjelmointi/refs/heads/main/exercise-assets/data/premieremarkers.txt).
