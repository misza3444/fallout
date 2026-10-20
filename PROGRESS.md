# STREFA ZERO — STAN REALIZACJI

Ostatnia aktualizacja: 2026-10-20. Projekt: https://github.com/misza3444/fallout

## Windows Portable — zmiana platformy (2026-10-20)

Na prośbę użytkownika głównym wydaniem jest Windows x64: EXE + PCK w paczce `STREFA_ZERO_Windows_Portable.zip`, bez instalatora. Zapisy, ustawienia i preferencje terminala w `userdata/` obok EXE. Dane przeglądarkowe nie migrują automatycznie. Przy aktualizacji zachować userdata.

Workflow `desktop.yml` eksportuje grę i uruchamia wyeksportowane EXE na Windows. Osobne zadanie renderuje rzeczywiste kadry menu, startu gracza, stacji i wraku z desktopowego Godota Linux/Mesa. To odbiór grafiki, nie pomiar wydajności Windows. Kadry trafiają do artefaktu i osobnej gałęzi `desktop-previews`; po powodzeniu powstaje wydanie do pobrania w Releases.

Wynik pierwszego buildu: oczekuje. Etap 1 pozostaje ACTIVE. Testy mobilne nie są bramką etapu desktop. Web jest opcjonalny; workflow web uruchamiany ręcznie.

## Status

- **Etap:** 1/10 — ACTIVE (nieukończony).
- **Priorytetowe środowisko:** Windows x64 / portable ZIP; web i dotyk są opcjonalne.
- **Silnik:** Godot 4.7.2, GDScript, renderer Compatibility.
- **Ostatnia potwierdzona kompilacja:** commit `93f51c9d`, GitHub Actions run `39245688236` — SUCCESS (import projektu, uruchomienie sceny w headless, eksport Web; bez błędów wykrytych przez kontrolę logów).
- **Ekran informacji o projekcie:** dołączony i uwzględniony w udanym buildzie.
- **Wizualny odbiór gry w przeglądarce:** NIEZWERYFIKOWANY.
- **Publikacja pod publicznym adresem:** https://misza3444.github.io/fallout/ odpowiada HTTP 200. Eksport jest automatycznie zapisywany na `gh-pages`, następnie publikowany przez GitHub Pages. Sam kod HTTP nie potwierdza wyglądu ani grywalności.

## Uszczelnienie fundamentów (2026-10-19)

- Zapis pozycji i ustawień zwraca rzeczywisty wynik zapisu pliku; błąd nie jest przedstawiany jako sukces.
- Komunikat zapisu wyprawy jest widoczny na stronie wyjścia, również podczas pauzy. Przycisk zapisu nie jest aktywny przed rozpoczęciem sesji.
- Kontynuacja odrzuca brakujące/uszkodzone współrzędne i kąty oraz pozycję spoza sektora. Nie uruchamia po cichu nowej gry.
- Pauza czyści dotykowe przyciski, skok i prędkość; nowa wyprawa również resetuje ruch.
- Dodano krótki test zapisu/odczytu ustawień i pozycji oraz uszkodzonych danych: `tools/check_foundation.gd`. Wynik CI: **SUCCESS**, commit `93f51c9d`, run `39245688236`. Kontrola obejmuje również przyciski dotykowe, pauzę, wznowienie, zerowanie prędkości nowej wyprawy i komunikat zapisu. Import, start sceny, test fundamentów, eksport Web i zapis na gh-pages zaliczone.
- ROADMAP i DEVELOPMENT_RULES uzgodnione z platformą web i istniejącym buildem.
- Próba uruchomienia opublikowanej gry w zdalnym Chrome: **BLOCKED — brak WebGL2**. Nie zaliczono testu menu, świata, sterowania ani FPS. Etap 1 pozostaje ACTIVE.

## Modele i materiały stacji — asset pass v1 (2026-10-19)

Commit `4e70a0d2`, GitHub Actions run `39242202575`: SUCCESS — import, start headless, eksport HTML5 i zapis na `gh-pages`.

- Cztery dystrybutory zastąpione modelem GLB z zaokrągloną obudową, licznikiem i wężem.
- Jeden wrak zastąpiony modelem GLB z nadkolami, otworami okiennymi i podniesioną maską.
- Asfalt, beton i rdza używają lokalnych tekstur PBR Poly Haven (CC0), 1024 px.
- Edytowalne źródła Blendera w `art_source/`, generator w `tools/build_station_assets.py`, źródła/licencje w `assets/ASSET_SOURCES.md`.
- Wygląd w grze, kolizje i wydajność na telefonie nadal wymagają odbioru. Pozostałe auta pozostają proceduralne.

## Stacja paliw — art pass v1 (2026-10-19)

Zmiany w `scripts/wasteland.gd`: pusty w środku budynek z otwartymi drzwiami, lada i regały, podjazd oraz kolizja posadzki, przebudowane okna i deski z mocowaniami; segmentowe zadaszenie z uszkodzonym narożnikiem i odsłoniętymi belkami; numerowane dystrybutory, węże, kratki i oznaczenie NIECZYNNE; attyki, wentylacja, rynna, skrzynka elektryczna, zwisające przewody, skrzynie na palecie i złom. Oznaczenia BRAK PALIWA / EWAKUACJA / OSTATNI KONWOJ budują historię lokacji.

Commit `998176ca`, GitHub Actions run `39209924129`: SUCCESS. Import, start headless, eksport HTML5 i publikacja na gh-pages zaliczone. Próba otwarcia przeglądarki zakończyła się timeoutem narzędzia; wygląd, przejście przez wejście i FPS nadal wymagają odbioru w grze. To iteracja proceduralnej scenografii, nie końcowe modele z UV i teksturami.

## UI scaling fix (2026-10-19)

Przebudowano layout terminala według zgłoszonego zrzutu ekranu: zależne od szerokości i wysokości wymiary typografii, przycisków i marginesów; przewijanie menu i podstron wewnątrz stałych pasków systemowych; mniejszy radar widoczny wyłącznie przy odpowiednio dużej rozdzielczości. Zmiany w `scripts/terminal_menu.gd`. GitHub Actions run `39208855746` — kompilacja skryptów, start headless, eksport HTML5 oraz publikacja na `gh-pages` zaliczone. Odbiór na telefonie i PC wymaga nadal ręcznego sprawdzenia.

## Redesign UI v1 (2026-10-19)

Nowy moduł `scripts/terminal_menu.gd` z dedykowanymi podmenu, archiwum, ustawieniami, responsywną kompozycją, paletami CRT, dźwiękami i animowaną kartografią (`scripts/ui_radar.gd`, `shaders/terminal_crt.gdshader`). Stary moduł menu w `main.gd` zastąpiony nowym wywołaniem. Weryfikacja przez kompilację/test headless; odbiór wizualny w przeglądarce wciąż otwarty.

## Wykonana praca

- Godot project + scene.
- Składana proceduralnie sceneria postapokaliptycznej stacji paliw, opuszczonego posterunku, wraków, pękniętej drogi, wieży radiowej i ruin w oddali.
- Barwna stylizacja pustkowia: niebo, mgła, kierunkowe światło, materiały typu patina/grunge, detale budynków, neonowe oznaczenia.
- Menu główne i kamera prezentacyjna, HUD, podstawowe ustawienia i zapis/odczyt.
- Kontroler postaci FPP, klawiatura/mysz oraz wstępne sterowanie dotykowe.
- CI/CD: import, smoke test uruchomienia, eksport web, artefakt oraz publikacja eksportu na osobną gałąź `gh-pages`; Vercel nie jest wymagany.

## Znane ograniczenia

1. Wiele obiektów środowiskowych to modele proceduralne z prostej geometrii, choć z detalami, materiałami i aranżacją sceny. **Nie są końcową oprawą wizualną** — konieczny etap szczegółowego modelowania, UV, tekstur i animacji.
2. Nie przeprowadzono rzeczywistego testu graficznego ani wydajnościowego w przeglądarce na iPhonie/Androidzie/PC.
3. Interakcje są na razie pokazowe, NPC, walkę, zadania i ekwipunek obejmują kolejne etapy.
4. Nie ma jeszcze pomiarów FPS, ograniczenia draw calls wymagają profilowania mobilnego.
5. Przeglądarka testowa 2026-10-19 wyświetliła komunikat o braku WebGL2. Nie uruchomiła menu ani sceny; brak możliwości oceny wizualnej w tym środowisku. Vercel nie jest potrzebny do publikacji.

## Konfiguracja GitHub Pages (już włączona; instrukcja odtworzenia)

1. Wejdź w `https://github.com/misza3444/fallout/settings/pages`.
2. Ustaw **Build and deployment → Source: Deploy from a branch**.
3. Wybierz **Branch: gh-pages**, **Folder: /(root)** i kliknij **Save**.
4. Po udanym wdrożeniu sprawdź `https://misza3444.github.io/fallout/`, w tym mobilne Safari.
5. GitHub Actions ma automatycznie aktualizować `gh-pages` po zmianach w projekcie. Bez realnych testów przeglądarkowych pozostaw etap aktywny.

## Definicja ukończenia etapu 1

- [x] Podstawowy projekt i struktura repozytorium
- [x] Menu i HUD obecne w kodzie
- [x] Sterowanie i ustawienia obecne w kodzie
- [x] Pierwsza scenografia 3D i autorskie materiały obecne w kodzie
- [x] Co najmniej jeden udany test uruchomienia headless oraz eksport HTML5
- [x] Publikacja adresu przeglądarkowego (GitHub Pages; HTTP 200 i udane wdrożenie — nie oznacza odbioru rozgrywki)
- [ ] Ręczna weryfikacja menu, sterowania, zapisu i wyglądu wydania Windows
- [ ] Dopracowanie i zatwierdzenie oprawy wizualnej pierwszej sceny
- [ ] Odbiór działania i wydajności wydania Windows Portable (iPhone: opcjonalny)

Nie oznaczać tego etapu jako DONE, dopóki wszystkie wymagane kryteria nie zostaną zweryfikowane.

## Zasady współpracy

Oprawa ma być priorytetem od początku, nie tylko na końcu. Nie przyjmować uproszczonych brył jako jakości docelowej. Przy dużym nakładzie pracy poinformować użytkownika, poprosić o zgodę na dalszą pracę nad tym samym zadaniem i nie zmieniać celu bez uzgodnienia.

Pełna roadmapa: [ROADMAP.md](ROADMAP.md), zasady: [DEVELOPMENT_RULES.md](DEVELOPMENT_RULES.md).
