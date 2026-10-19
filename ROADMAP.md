# ROADMAP — STREFA ZERO (RPG 3D)

> Dokument planistyczny. Aktualizacja: 2026-10-19. **Żaden etap implementacji nie jest jeszcze ukończony.**
>
> Statusy: ✅ DONE / 🟡 ACTIVE / ⬜ PENDING. Aktualny etap: **1 z 10**.

## Cel produktu

Zbudować samodzielną, rozwijalną grę RPG 3D w oryginalnym świecie postapokaliptycznym — z otwartą eksploracją, interaktywnymi lokacjami, FPS/TPP, taktyczną walką, ekwipunkiem, rozwojem postaci, zadaniami, NPC, frakcjami, reputacją oraz trwałymi konsekwencjami decyzji.

Świat fabularny (propozycja, niezatwierdzone ostatecznie): rok 2189, ponad 100 lat po globalnej wojnie. Start w podziemnym kompleksie; pobliska osada, bandyci i stara instalacja oczyszczania wody. **STREFA ZERO** to nazwa robocza.

## Decyzje i założenia

- **Technologia robocza:** Godot 4 / GDScript, Blender (eksport GLB), dane w Resources i/lub JSON, GitHub do kontroli zmian.
- **Platforma potwierdzona:** przeglądarka HTML5 / WebGL 2, z uwzględnieniem smartfonów i dotyku. Renderer Compatibility. Windows nie jest platformą priorytetową.
- **Kamera:** FPP/TPP.
- **Tryb:** singleplayer.
- **Świat:** sektory, selektywne wczytywanie i trwały stan świata.
- **Wymóg jakości:** grywalny świat i naturalne interakcje, a nie wyłącznie makieta lub liniowa seria poleceń.
- **Zasada postępu:** etap uznajemy za DONE wyłącznie po rzeczywistym ukończeniu i weryfikacji kryteriów. Po każdym etapie ma istnieć działająca wersja gry (build na wybraną platformę).
- **Stan na dzień zapisu:** fundament, menu, FPP i pierwsza scena są zaimplementowane; eksport web oraz publikacja GitHub Pages potwierdzone. Aktualne wyniki i ograniczenia: [PROGRESS.md](PROGRESS.md). Odbiór wizualny i mobilny nadal otwarty.

## Najbliższy blok — domknięcie etapu 1

- Ujednolicić plan z potwierdzoną platformą web i istniejącą publikacją (wykonane 2026-10-19).
- Uszczelnić zapis/odczyt i komunikaty o błędach oraz reset dotykowego sterowania przy pauzie.
- Zweryfikować menu, ustawienia po restarcie, zapis/wczytanie i ruch w przeglądarce z WebGL2.
- Odebrać wizualnie pierwszą lokację: stacja, nowe dystrybutory, wrak i materiały; następnie poprawić pozostałe placeholdery otoczenia.
- Sprawdzić sterowanie dotykowe i FPS na fizycznym iPhonie. Emulacja rozmiaru ekranu nie zastępuje tego testu.

Oprawa jest priorytetem już w etapie 1; etap 9 oznacza końcowe dopracowanie, a nie początek pracy nad grafiką. Etapy 2–10 pozostają nieukończone.

## Etapy implementacji

### 🟡 1. Fundament projektu i architektura — ACTIVE

**Zakres:**
- platforma web potwierdzona; doprecyzowanie wymagań sprzętowych na podstawie pomiarów na docelowych urządzeniach;
- utworzenie projektu Godot i uporządkowanych katalogów (np. scenes, scripts, assets, data, ui);
- Game Manager i komunikacja między modułami przez zdarzenia/sygnały;
- menu główne, ustawienia, ekran ładowania, zarządzanie scenami;
- podstawowy zapis/odczyt ustawień i danych gry;
- sterowanie klawiaturą/myszą i podstawy gamepada.

**Kryterium ukończenia:** projekt uruchamia się w Godot; menu działa; ustawienia można zmienić i odczytać po restarcie; sceny poprawnie się przełączają; przygotowano i sprawdzono grywalny build **0.1**.

### ⬜ 2. Postać i sterowanie 3D — PENDING

**Zakres:** kontroler FPP/TPP, płynne przełączanie widoku, ruch, sprint, kucanie, skok, fizyka, kolizje, animacje, interakcje i podnoszenie przedmiotów.

**Kryterium ukończenia:** gracz może naturalnie eksplorować scenę, przełączać widok i manipulować interaktywnymi obiektami bez błędów kolizji i kamery; działający build etapu.

### ⬜ 3. Pierwszy świat 3D — PENDING

**Zakres:** pustkowie, teren i wysokości, drogi, ruiny, punkty orientacyjne, światło, mgła, cykl dnia/nocy, pogoda, bazowy system sektorów/streamingu.

**Kryterium ukończenia:** istnieje spójna, eksplorowalna mapa 3D; sektory ładują się stabilnie; oprawa ma zamierzony klimat; build **0.2**.

### ⬜ 4. Walka i przeciwnicy — PENDING

**Zakres:** broń palna/biała, celowanie, amunicja, przeładowywanie, odrzut, HP i obrażenia, reakcje na trafienie, bazowe AI (patrol, wykrywanie, pościg, walka, osłony), łupy.

**Kryterium ukończenia:** gracz może zdobyć broń, stoczyć walkę z przeciwnikiem, pokonać go i zebrać wyposażenie; zachowania AI i zapis stanu nie blokują gry; build **0.3**.

### ⬜ 5. Ekwipunek i rozwój postaci — PENDING

**Zakres:** przedmioty i kontenery, kategorie, wyposażenie broni/zbroi, obciążenie, statystyki, poziomy, doświadczenie, perki/umiejętności, zdrowie, leczenie i promieniowanie.

**Kryterium ukończenia:** postać zbiera, przekłada, zakłada i wykorzystuje przedmioty; rozwój ma wpływ na statystyki; wyposażenie oraz progres przetrwają zapis i odczyt; działający build etapu.

### ⬜ 6. NPC, dialogi i zadania — PENDING

**Zakres:** NPC z harmonogramami, rozmowy rozgałęzione, testy umiejętności, dziennik zadań, flagi świata, konsekwencje wyborów, możliwość wielu rozwiązań.

**Kryterium ukończenia:** co najmniej jedno pełne zadanie możliwe do ukończenia rozmową, walką lub eksploracją, bez sprzecznych stanów po ponownym wczytaniu; build **0.4** i grywalny **Vertical Slice 0.5**.

### ⬜ 7. Frakcje i żyjący świat — PENDING

**Zakres:** reputacja, relacje między frakcjami, reakcje społeczności, patrole, handel, dynamiczne zdarzenia, konsekwencje działań gracza.

**Kryterium ukończenia:** przynajmniej dwie frakcje reagują odmiennie na reputację i decyzje; stan świata jest spójny po zapisie; build **0.6**.

### ⬜ 8. Rozbudowa otwartego świata — PENDING

**Zakres:** połączone sektory, kolejne lokacje, wnętrza, podziemia, sekrety, szybka podróż, eksploracja wertykalna, crafting, survival i wydarzenia.

**Kryterium ukończenia:** świat jest logicznie połączony, lokacje można odkrywać i odwiedzać ponownie, a zawartość sektorów i zadania zachowują trwały stan; build **0.7**, następnie **0.8** dla rozszerzonego survivalu/craftingu.

### ⬜ 9. Grafika, animacje i atmosfera — PENDING

**Zakres:** modele 3D i materiały PBR, animacje postaci, efekty walki, dopracowane światło/pogoda, audio przestrzenne, muzyka, interfejs i balans rozgrywki.

**Kryterium ukończenia:** reprezentatywne lokacje i mechaniki mają spójny, docelowy styl, a najważniejsze animacje/efekty i audio są zintegrowane; build **0.9**.

### ⬜ 10. Optymalizacja, testy i wydanie — PENDING

**Zakres:** LOD, culling, streaming, optymalizacja AI i zasobów, poprawki błędów, testy wszystkich pętli rozgrywki, testy zapisów, konfiguracja grafiki, pakowanie gry.

**Kryterium ukończenia:** podstawowe scenariusze end-to-end przechodzą testy, zapisy i odczyty są stabilne, gra uruchamia się jako samodzielny build docelowej platformy; wydanie **1.0**.

## Kamienie milowe

| Wersja | Wynik |
| --- | --- |
| 0.1 | Fundament, menu, zapis, sterowanie |
| 0.2 | Pierwszy dopracowany teren 3D |
| 0.3 | Walka, przeciwnicy, loot |
| 0.4 | NPC, ekwipunek, dialogi, zadania |
| 0.5 | Grywalny Vertical Slice |
| 0.6 | Frakcje, reputacja, rozwój RPG |
| 0.7 | Rozszerzony świat i podziemia |
| 0.8 | Survival, crafting, zdarzenia |
| 0.9 | Oprawa, animacje, balans |
| 1.0 | Kompletna, przetestowana wersja gry |

## Plan grywalnego Vertical Slice (cel 0.5)

**Założony, nie wykonany zakres:** 30–60 minut rozgrywki na terenie około 0,5 km², 3 główne lokacje, 8–12 NPC, 4 typy przeciwników, 4–6 zadań i 4 rodzaje broni. Te liczby są *celami produkcyjnymi*, nie liczbami już zrealizowanych elementów.

Proponowana pętla: wyjście z podziemnego schronu → odkrycie osady → poznanie konfliktu o wodę → eksploracja ruin → wybór sposobu rozwiązania konfliktu → zauważalna zmiana stanu świata.

## Architektura docelowa

```text
Game Manager
├── World / Streaming / Time / Weather
├── Character / Camera / Stats
├── Combat / Damage / AI
├── NPC / Dialogue / Reputation
├── Quests / World Flags
├── Inventory / Items / Crafting
└── UI / Audio
       ↓
Events / Persistent Data / Save System
```

Logikę scen, dane zawartości i zapis gry trzymamy rozdzielnie. Zachowania NPC, stany zadań i konsekwencje fabularne muszą korzystać ze wspólnego, trwałego modelu stanu świata.

## Zasady odbioru i aktualizacji planu

1. Nie rozpoczynaj następnego etapu, zanim bieżący nie jest ukończony i zweryfikowany.
2. Każdy etap powinien zostawić uruchamialną wersję wraz z krótką notatką zmian i ograniczeń.
3. Nie oznaczaj testów jako zaliczonych bez faktycznego uruchomienia; dokumentuj rzeczywiste wyniki.
4. Wraz z zakończeniem etapu aktualizuj jego status, wersję wydania i rzeczywisty stan projektu.
5. Nie utożsamiaj wygenerowanych assetów ani projektów koncepcyjnych z ukończoną mechaniką gry.
6. Zakres może ewoluować, ale zmiany nie mogą kasować ukończonych etapów ani już podjętych decyzji.
