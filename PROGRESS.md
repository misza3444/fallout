# STREFA ZERO — STAN REALIZACJI

Ostatnia aktualizacja: 2026-10-19. Projekt: https://github.com/misza3444/fallout

## Status

- **Etap:** 1/10 — ACTIVE (nieukończony).
- **Priorytetowe środowisko:** przeglądarka HTML5 / WebGL 2; sterowanie mobilne jako cel wymagający weryfikacji.
- **Silnik:** Godot 4.7.2, GDScript, renderer Compatibility.
- **Ostatnia potwierdzona kompilacja:** commit `8483f005`, GitHub Actions run `39201649502` — SUCCESS (import projektu, uruchomienie sceny w headless, eksport Web; bez błędów wykrytych przez kontrolę logów).
- **Ekran informacji o projekcie:** dołączony i uwzględniony w udanym buildzie.
- **Wizualny odbiór gry w przeglądarce:** NIEZWERYFIKOWANY.
- **Publikacja pod publicznym adresem:** Gałąź `gh-pages` z kompletnym eksportem Godot HTML5 przygotowana i zasilana przez GitHub Actions. **Hosting wymaga jednorazowego włączenia Pages** w Settings → Pages (Deploy from a branch, `gh-pages`, `/(root)`). Adres nie jest jeszcze potwierdzony jako dostępny.

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
5. Wdrożenie Vercel wymaga podłączenia repozytorium w panelu użytkownika albo odświeżenia autoryzacji zespołu w konektorze.

## Włączenie GitHub Pages (jednorazowo)

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
- [ ] Publikacja działającego adresu przeglądarkowego (GitHub Pages)
- [ ] Ręczna weryfikacja menu, sterowania, zapisu i wyglądu w realnej przeglądarce
- [ ] Dopracowanie i zatwierdzenie oprawy wizualnej pierwszej sceny
- [ ] Test podstawowych funkcji i wydajności na iPhonie

Nie oznaczać tego etapu jako DONE, dopóki wszystkie wymagane kryteria nie zostaną zweryfikowane.

## Zasady współpracy

Oprawa ma być priorytetem od początku, nie tylko na końcu. Nie przyjmować uproszczonych brył jako jakości docelowej. Przy dużym nakładzie pracy poinformować użytkownika, poprosić o zgodę na dalszą pracę nad tym samym zadaniem i nie zmieniać celu bez uzgodnienia.

Pełna roadmapa: [ROADMAP.md](ROADMAP.md), zasady: [DEVELOPMENT_RULES.md](DEVELOPMENT_RULES.md).
