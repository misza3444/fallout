# ☢️ STREFA ZERO — RPG 3D (Web)

**Status:** etap 1 rozpoczęty, weryfikacja wydania 0.1 w toku.  
**Silnik:** Godot 4.7.2 / GDScript / renderer Compatibility (WebGL 2).  
**Platforma priorytetowa:** przeglądarka internetowa, również iPhone/Android po weryfikacji wydajności i dotyku.  
**Docelowo:** autorskie RPG z otwartym światem, eksploracją, walką, NPC, dialogami, frakcjami i konsekwencjami decyzji.

## Zrealizowane w kodzie (nie oznacza jeszcze zaliczonego testu rozgrywki)

- Działający szkielet projektu Godot i scena startowa.
- Autorski pustynny krajobraz z ruinami, drogą, stacją paliw, autami, wieżą radiową, posterunkiem, daleką panoramą miasta i detalami środowiska.
- Cinematic menu z widokiem na świat gry oraz HUD.
- Sterowanie postacią FPP, sprint, kucanie, skok, rozglądanie myszą.
- Wstępne sterowanie dotykowe i obrót kamery przeciągnięciem po ekranie.
- Menu ustawień, zapisywanie pozycji i ustawień w `user://`.
- GitHub Actions: walidacja skryptów, test headless, eksport HTML5 do `public/`, automatyczna publikacja na gałęzi `gh-pages` i artefakt do pobrania.

**Uwaga:** to pierwszy etap techniczno-wizualny; NIE jest to jeszcze pełna gra, system questów ani otwarty świat docelowej skali.

## Uruchomienie lokalnie

1. Zainstaluj [Godot 4.7.2](https://godotengine.org/download/archive/4.7.2-stable/) (wersja zwykła, bez .NET).
2. Sklonuj repozytorium i otwórz plik `project.godot`.
3. Kliknij **F6/F5** w edytorze Godot, aby uruchomić scenę lub cały projekt.
4. Eksport do przeglądarki: zainstaluj szablony eksportu, wybierz preset `Web`, eksportuj do `public/index.html`. Uruchom go przez serwer HTTP, nie z pliku `file://`.

### Sterowanie

| Klawisz / gest | Działanie |
| --- | --- |
| WASD / strzałki | Ruch |
| Mysz | Rozglądanie |
| Shift | Sprint |
| Ctrl | Kucanie |
| Spacja | Skok |
| E | Skan otoczenia |
| Esc | Menu/pauza |
| Telefon: lewy panel | Przyciski ruchu |
| Telefon: przeciągnięcie po prawej stronie | Rozglądanie |

## Gra online — GitHub Pages

**Aktualna droga publikacji: GitHub Pages**. Nie wymaga Vercel ani osobnego serwera. Gałąź [gh-pages](https://github.com/misza3444/fallout/tree/gh-pages) zawiera pliki gry HTML5 w katalogu głównym. Każda zmiana skryptów, scen lub shaderów na `main` powoduje automatyczne zbudowanie nowego eksportu Godot i aktualizację `gh-pages` przez [GitHub Actions](https://github.com/misza3444/fallout/actions/workflows/web.yml).

### Jednorazowe włączenie strony

1. Otwórz [Settings → Pages](https://github.com/misza3444/fallout/settings/pages) w repozytorium.
2. W **Build and deployment → Source** wybierz **Deploy from a branch**.
3. W **Branch** ustaw `gh-pages`, katalog `/(root)`, a następnie kliknij **Save**.
4. Poczekaj na publikację w [Actions](https://github.com/misza3444/fallout/actions). Po sukcesie sprawdź adres: **https://misza3444.github.io/fallout/**.

**Uwaga:** przed włączeniem Pages ten adres nie musi działać. Eksport headless (silnik, pliki, startup) to nie to samo co ręczny test gry w prawdziwej przeglądarce. Sterowanie dotykowe i wydajność na iPhonie wymagają sprawdzenia.

Dla osób chcących hostować statyczny eksport inaczej (np. Netlify Drop) nadal można pobrać artefakt `strefa-zero-web` z uruchomienia GitHub Actions, rozpakować go i wgrać gotowe pliki na hosting. `vercel.json` pozostaje jako opcjonalna konfiguracja, ale Vercel nie jest wymagany.

## Dokumentacja

- [ROADMAP.md](ROADMAP.md) — 10 etapów, kryteria odbioru, wersje 0.1–1.0.
- [DEVELOPMENT_RULES.md](DEVELOPMENT_RULES.md) — decyzje o platformie i wymagania dotyczące jakości wizualnej.

### Zasada jakości

Od początku traktujemy oprawę 3D jako część produktu. Proste bryły nie stanowią zaakceptowanych docelowych modeli. Każda lokacja docelowo wymaga dopracowanego modelowania, materiałów, oświetlenia i charakteru. Jeżeli wymaga to większego nakładu pracy, trzeba poinformować użytkownika i uzyskać zgodę na dalszą pracę nad tym samym elementem.

**Ważne:** ten prototyp wykorzystuje wciąż geometryczne modele autorskich obiektów; są wstępne, nie finalne. Brak jeszcze fotograficznej jakości AAA ani potwierdzonych pomiarów wydajności na iPhonie.
