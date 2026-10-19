# STREFA ZERO — zasady realizacji

## Potwierdzone decyzje (2026-10-18)
- Silnik: Godot 4, GDScript.
- Platforma główna: przeglądarka, z uwzględnieniem ekranów dotykowych i smartfonów.
- Oprawa wizualna jest priorytetem od pierwszego etapu. Nie akceptujemy prostych brył jako docelowych assetów. Tymczasowe placeholdery muszą być wyraźnie oznaczone i zastąpione przed odbiorem reprezentatywnej lokacji.
- Jeśli dany element wymaga dużego nakładu pracy, asystent informuje użytkownika i prosi o zgodę na dalszą pracę nad tym samym elementem; nie obniża po cichu jakości.
- Każdy etap ma kończyć się działającym, zweryfikowanym buildem; nie deklarować wykonanych testów bez ich uruchomienia.
- Aktualny etap: 1, fundament projektu i pierwsza prezentacyjna scena 3D.

## Architektura web-first
- Renderer Compatibility dla eksportu web; efekty i materiały projektowane pod ograniczenia WebGL.
- Responsywny interfejs, wejście klawiatura/mysz i przyszłe sterowanie dotykowe.
- Sceny i zasoby o rozsądnym rozmiarze, ograniczanie draw calls, tekstur i kosztów oświetlenia.
- Wczesny test eksportu HTML5, nie dopiero na końcu projektu.

## Kryteria odbioru etapu 1 (aktualizacja)
1. Projekt Godot 4 otwiera się poprawnie.
2. Działa menu główne, ustawienia i przejście do sceny.
3. Pierwsza scena prezentuje świadomie zaprojektowany styl postapokaliptyczny (oświetlenie, materiały, kompozycja), a nie wyłącznie szare bryły.
4. Możliwe jest poruszanie się i oglądanie otoczenia.
5. Eksport web uruchamia się w przeglądarce; wynik testu udokumentowany.
6. Wszystkie źródła oraz instrukcja uruchomienia są zapisane w repozytorium.

Status: etap w trakcie. Build i publikacja web potwierdzone (run `39242202575`). Odbiór wizualny, interakcji i wydajności na urządzeniach pozostaje otwarty. Przeglądarka testowa 2026-10-19 zgłosiła brak WebGL2; nie jest to zaliczony test rozgrywki.
