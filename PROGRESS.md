# STREFA ZERO — STAN REALIZACJI

Ostatnia aktualizacja: 2026-10-19. Projekt: https://github.com/misza3444/fallout

## Status

- **Etap:** 1/10 — ACTIVE (nieukończony).
- **Priorytetowe środowisko:** przeglądarka HTML5 / WebGL 2; sterowanie mobilne jako cel wymagający weryfikacji.
- **Silnik:** Godot 4.7.2, GDScript, renderer Compatibility.
- **Ostatnia potwierdzona kompilacja:** commit `8483f005`, GitHub Actions run `39201649502` — SUCCESS (import projektu, uruchomienie sceny w headless, eksport Web; bez błędów wykrytych przez kontrolę logów).
- **Ekran informacji o projekcie:** dołączony i uwzględniony w udanym buildzie.
- **Wizualny odbiór gry w przeglądarce:** NIEZWERYFIKOWANY.
- **Publikacja pod publicznym adresem:** BLOKADA — próba utworzenia projektu na Vercel zakończyła się `403 Forbidden` z powodu braku autoryzacji do zespołu `michalkozlowski3444-gmailcoms-projects`. Godot Web eksportuje poprawnie, a kompletna zawartość `public/` (w tym `.wasm` i `.pck`) jest już skomitowana na `main` i przygotowana do hostingu statycznego.

## Wykonana praca

- Godot project + scene.
- Składana proceduralnie sceneria postapokaliptycznej stacji paliw, opuszczonego posterunku, wraków, pękniętej drogi, wieży radiowej i ruin w oddali.
- Barwna stylizacja pustkowia: niebo, mgła, kierunkowe światło, materiały typu patina/grunge, detale budynków, neonowe oznaczenia.
- Menu główne i kamera prezentacyjna, HUD, podstawowe ustawienia i zapis/odczyt.
- Kontroler postaci FPP, klawiatura/mysz oraz wstępne sterowanie dotykowe.
- CI/CD: import, smoke test uruchomienia, eksport web, artefakt, automatyczny commit katalogu `public/` i konfiguracja `vercel.json` (statyczny hosting).

## Znane ograniczenia

1. Wiele obiektów środowiskowych to modele proceduralne z prostej geometrii, choć z detalami, materiałami i aranżacją sceny. **Nie są końcową oprawą wizualną** — konieczny etap szczegółowego modelowania, UV, tekstur i animacji.
2. Nie przeprowadzono rzeczywistego testu graficznego ani wydajnościowego w przeglądarce na iPhonie/Androidzie/PC.
3. Interakcje są na razie pokazowe, NPC, walkę, zadania i ekwipunek obejmują kolejne etapy.
4. Nie ma jeszcze pomiarów FPS, ograniczenia draw calls wymagają profilowania mobilnego.
5. Wdrożenie Vercel wymaga podłączenia repozytorium w panelu użytkownika albo odświeżenia autoryzacji zespołu w konektorze.

## Odblokowanie publikacji na Vercel

1. Otwórz `https://vercel.com/new` i wybierz właściwy zespół.
2. Zaimportuj `misza3444/fallout` z gałęzi `main`; nadaj integracji GitHub dostęp, jeśli repo nie jest widoczne.
3. Ustaw Framework Preset **Other**, Root Directory **.**, Output Directory **public** (zgodnie z `vercel.json`).
4. Wybierz **Deploy** i sprawdź URL podany przez Vercel.
5. Brak potwierdzonego adresu i brak przeprowadzonego testu przeglądarkowego — do weryfikacji po publikacji.

## Definicja ukończenia etapu 1

- [x] Podstawowy projekt i struktura repozytorium
- [x] Menu i HUD obecne w kodzie
- [x] Sterowanie i ustawienia obecne w kodzie
- [x] Pierwsza scenografia 3D i autorskie materiały obecne w kodzie
- [x] Co najmniej jeden udany test uruchomienia headless oraz eksport HTML5
- [ ] Publikacja działającego adresu przeglądarkowego (Vercel)
- [ ] Ręczna weryfikacja menu, sterowania, zapisu i wyglądu w realnej przeglądarce
- [ ] Dopracowanie i zatwierdzenie oprawy wizualnej pierwszej sceny
- [ ] Test podstawowych funkcji i wydajności na iPhonie

Nie oznaczać tego etapu jako DONE, dopóki wszystkie wymagane kryteria nie zostaną zweryfikowane.

## Zasady współpracy

Oprawa ma być priorytetem od początku, nie tylko na końcu. Nie przyjmować uproszczonych brył jako jakości docelowej. Przy dużym nakładzie pracy poinformować użytkownika, poprosić o zgodę na dalszą pracę nad tym samym zadaniem i nie zmieniać celu bez uzgodnienia.

Pełna roadmapa: [ROADMAP.md](ROADMAP.md), zasady: [DEVELOPMENT_RULES.md](DEVELOPMENT_RULES.md).
