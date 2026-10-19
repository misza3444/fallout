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
- GitHub Actions: walidacja skryptów, test headless, eksport HTML5 do `public/`, zapis gotowych plików na gałęzi `main` i artefakt do pobrania.

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

## Wersja web — Vercel (stan na 2026-10-19)

**Eksport HTML5 został wykonany i zweryfikowany w GitHub Actions.** Pliki `public/index.html`, `public/index.js`, `public/index.wasm`, `public/index.pck` oraz zasoby dodatkowe zostały zapisane w repozytorium przez workflow.

- [Wynik poprawnego buildu](https://github.com/misza3444/fallout/actions/runs/39201649502)
- [Gotowe pliki public/](public/)
- [Konfiguracja Vercel](vercel.json)
- [Workflow budowania i zapisu eksportu](.github/workflows/web.yml)

**Adres Vercel jeszcze nie istnieje.** Automatyczna próba stworzenia projektu `strefa-zero` w zespole `michalkozlowski3444-gmailcoms-projects` nie powiodła się: integracja zwróciła `403 Forbidden` z informacją o braku autoryzacji dla tego scope. Nie oznaczamy publikacji jako gotowej.

### Jednorazowe podłączenie Vercel

1. Otwórz [Vercel — New Project](https://vercel.com/new).
2. Wybierz własny zespół `michalkozlowski3444-gmailcoms-projects`.
3. Zaimportuj repozytorium GitHub `misza3444/fallout` (jeśli go nie widzisz, nadaj Vercel dostęp do tego repozytorium w integracji GitHub).
4. Wybierz nazwę projektu `strefa-zero`, gałąź produkcyjną `main`, Framework Preset: **Other**, Root Directory: **.** (root repozytorium).
5. `vercel.json` deklaruje `framework: null` i `outputDirectory: "public"`. Nie jest wymagany proces kompilacji Godot w Vercel, ponieważ gotowy eksport jest już w `public/`.
6. Kliknij **Deploy**. Dopiero po udanym wdrożeniu zweryfikuj adres projektu na Vercel w przeglądarce.

Przy kolejnych zmianach kodu gry GitHub Actions przebudowuje `public/` i zapisuje gotową wersję na `main`. Po poprawnym połączeniu z repozytorium Vercel może wdrażać jego aktualne commity.

## Dokumentacja

- [ROADMAP.md](ROADMAP.md) — 10 etapów, kryteria odbioru, wersje 0.1–1.0.
- [DEVELOPMENT_RULES.md](DEVELOPMENT_RULES.md) — decyzje o platformie i wymagania dotyczące jakości wizualnej.

### Zasada jakości

Od początku traktujemy oprawę 3D jako część produktu. Proste bryły nie stanowią zaakceptowanych docelowych modeli. Każda lokacja docelowo wymaga dopracowanego modelowania, materiałów, oświetlenia i charakteru. Jeżeli wymaga to większego nakładu pracy, trzeba poinformować użytkownika i uzyskać zgodę na dalszą pracę nad tym samym elementem.

**Ważne:** ten prototyp wykorzystuje wciąż geometryczne modele autorskich obiektów; są wstępne, nie finalne. Brak jeszcze fotograficznej jakości AAA ani potwierdzonych pomiarów wydajności na iPhonie.
