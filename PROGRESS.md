# STREFA ZERO — STAN REALIZACJI

Ostatnia aktualizacja: 2026-10-18. Projekt: https://github.com/misza3444/fallout

## Status

- **Etap:** 1/10 — ACTIVE (nieukończony).
- **Priorytetowe środowisko:** przeglądarka HTML5 / WebGL 2; sterowanie mobilne jako cel wymagający weryfikacji.
- **Silnik:** Godot 4.7.2, GDScript, renderer Compatibility.
- **Ostatnia potwierdzona kompilacja:** commit `c23ba28`, GitHub Actions run `39170139386` — SUCCESS (import projektu, uruchomienie sceny w headless, eksport Web; bez błędów wykrytych przez kontrolę logów).
- **Ekran informacji o projekcie:** dołączony i uwzględniony w udanym buildzie.
- **Wizualny odbiór gry w przeglądarce:** NIEZWERYFIKOWANY.
- **Publikacja pod publicznym adresem:** BLOKADA — GitHub Pages nie zostało włączone w repozytorium. Automatyczne tworzenie Pages przez token Actions odmówiło dostępu. Artefakt HTML5 dostępny w udanym workflow.

## Wykonana praca

- Godot project + scene.
- Składana proceduralnie sceneria postapokaliptycznej stacji paliw, opuszczonego posterunku, wraków, pękniętej drogi, wieży radiowej i ruin w oddali.
- Barwna stylizacja pustkowia: niebo, mgła, kierunkowe światło, materiały typu patina/grunge, detale budynków, neonowe oznaczenia.
- Menu główne i kamera prezentacyjna, HUD, podstawowe ustawienia i zapis/odczyt.
- Kontroler postaci FPP, klawiatura/mysz oraz wstępne sterowanie dotykowe.
- CI/CD: import, smoke test uruchomienia, eksport web, artefakty i warunkowe wdrożenie Pages.

## Znane ograniczenia

1. Wiele obiektów środowiskowych to modele proceduralne z prostej geometrii, choć z detalami, materiałami i aranżacją sceny. **Nie są końcową oprawą wizualną** — konieczny etap szczegółowego modelowania, UV, tekstur i animacji.
2. Nie przeprowadzono rzeczywistego testu graficznego ani wydajnościowego w przeglądarce na iPhonie/Androidzie/PC.
3. Interakcje są na razie pokazowe, NPC, walkę, zadania i ekwipunek obejmują kolejne etapy.
4. Nie ma jeszcze pomiarów FPS, ograniczenia draw calls wymagają profilowania mobilnego.
5. Web deployment jest gotowy w workflow, ale wymaga konfiguracji Pages przez właściciela repozytorium.

## Odblokowanie Pages (wymaga działania użytkownika)

1. Otwórz `https://github.com/misza3444/fallout/settings/pages`.
2. W sekcji **Build and deployment → Source** wybierz **GitHub Actions** i zapisz.
3. Otwórz `https://github.com/misza3444/fallout/actions/workflows/web.yml` i kliknij **Run workflow** na gałęzi `main`.
4. Po udanym wdrożeniu gra powinna być dostępna pod `https://misza3444.github.io/fallout/`. Ten URL nie jest potwierdzony jako działający do czasu sukcesu wdrożenia.

## Definicja ukończenia etapu 1

- [x] Podstawowy projekt i struktura repozytorium
- [x] Menu i HUD obecne w kodzie
- [x] Sterowanie i ustawienia obecne w kodzie
- [x] Pierwsza scenografia 3D i autorskie materiały obecne w kodzie
- [x] Co najmniej jeden udany test uruchomienia headless oraz eksport HTML5
- [ ] Publikacja działającego adresu przeglądarkowego (Pages)
- [ ] Ręczna weryfikacja menu, sterowania, zapisu i wyglądu w realnej przeglądarce
- [ ] Dopracowanie i zatwierdzenie oprawy wizualnej pierwszej sceny
- [ ] Test podstawowych funkcji i wydajności na iPhonie

Nie oznaczać tego etapu jako DONE, dopóki wszystkie wymagane kryteria nie zostaną zweryfikowane.

## Zasady współpracy

Oprawa ma być priorytetem od początku, nie tylko na końcu. Nie przyjmować uproszczonych brył jako jakości docelowej. Przy dużym nakładzie pracy poinformować użytkownika, poprosić o zgodę na dalszą pracę nad tym samym zadaniem i nie zmieniać celu bez uzgodnienia.

Pełna roadmapa: [ROADMAP.md](ROADMAP.md), zasady: [DEVELOPMENT_RULES.md](DEVELOPMENT_RULES.md).
