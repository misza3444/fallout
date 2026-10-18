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
- GitHub Actions: import, kontrola błędów skryptów, eksport HTML5, artefakt do pobrania i próba wdrożenia GitHub Pages.

**Uwaga:** to pierwszy etap techniczno-wizualny; NIE jest to jeszcze pełna gra, system questów ani otwarty świat docelowej skali.

## Uruchomienie lokalnie

1. Zainstaluj [Godot 4.7.2](https://godotengine.org/download/archive/4.7.2-stable/) (wersja zwykła, bez .NET).
2. Sklonuj repozytorium i otwórz plik `project.godot`.
3. Kliknij **F6/F5** w edytorze Godot, aby uruchomić scenę lub cały projekt.
4. Eksport do przeglądarki: zainstaluj szablony eksportu, wybierz preset `Web`, eksportuj do `build/web/index.html`. Uruchom go przez serwer HTTP, nie z pliku `file://`.

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

## Wersja web

Próba eksportu web jest wykonywana automatycznie przez workflow [Build and deploy Godot Web](https://github.com/misza3444/fallout/actions/workflows/web.yml). Nawet jeśli Pages nie zostało jeszcze aktywowane, przygotowany plik gry może być dostępny jako artefakt workflow `strefa-zero-web`, o ile build przejdzie kontrolę błędów.

Po udanym wdrożeniu GitHub Pages przewidywany adres to `https://misza3444.github.io/fallout/`. **Nie zakładamy, że adres już działa — zależy to od potwierdzonego wdrożenia.**

## Dokumentacja

- [ROADMAP.md](ROADMAP.md) — 10 etapów, kryteria odbioru, wersje 0.1–1.0.
- [DEVELOPMENT_RULES.md](DEVELOPMENT_RULES.md) — decyzje o platformie i wymagania dotyczące jakości wizualnej.

### Zasada jakości

Od początku traktujemy oprawę 3D jako część produktu. Proste bryły nie stanowią zaakceptowanych docelowych modeli. Każda lokacja docelowo wymaga dopracowanego modelowania, materiałów, oświetlenia i charakteru. Jeżeli wymaga to większego nakładu pracy, trzeba poinformować użytkownika i uzyskać zgodę na dalszą pracę nad tym samym elementem.

**Ważne:** ten prototyp wykorzystuje wciąż geometryczne modele autorskich obiektów; są wstępne, nie finalne. Brak jeszcze fotograficznej jakości AAA ani potwierdzonych pomiarów wydajności na iPhonie.
