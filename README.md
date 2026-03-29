# SafeSpender

Isiklik eelarve rakendus Flutter'is. Mõte on lihtne: sa sead oma kuusissetuleku, püsikulud ja puhvri, ning ülejäänud raha jaotub kategooriate vahel laiali. Sealt edasi logid kulutusi ja saad enne ostu kontrollida, kas see on turvaline.

Kasutajaliides on eesti keeles.

---

## Funktsioonid

- **Seadistus** — sissetulek, püsikulud, puhver ja kategooriad protsendijaotusega
- **Avaleht** — kuu kokkuvõte, kategooriate progress, nutikas nõuanne
- **Kulud** — kulu lisamine kategooria järgi
- **Kategooria ülevaade** — päevane kulutussoovitus vastavalt sellele, mitu päeva kuust alles on
- **Ostu hindamine** — sisesta summa ja kategooria, rakendus ütleb kas TURVALINE / PIIRI PEAL / EI SOOVITA
- **Seaded** — nimi ja valuuta

---

## Kuidas see töötab

```
jaotussumma = sissetulek − püsikulud − puhver
kategooria plaan = jaotussumma × (protsent / 100)
kategooria alles = plaan − kulutatud
```

Ostu hindamisel vaadatakse, kui palju kategoorias alles on ja kui palju kuu üldine varu pärast ostu järele jääb.

---

## Arhitektuur

Projekt on jagatud funktsioonide kaupa (`features/`), igal funktsioonil kolm kihti:

- **domain** — puhas Dart, äriloogika, mudelid. Ei tea Flutter'ist ega andmebaasist midagi.
- **data** — repositooriumid, SQLite päringud, HTTP.
- **presentation** — ekraanid, Riverpod notifier'id. Arvutusi siin ei tehta.

Olekuhaldus: Riverpod. Navigatsioon: GoRouter. Andmebaas: SQLite (sqflite).

---

## Käivitamine

```bash
flutter pub get
flutter run
```

Esimesel käivitusel avaneb seadistusekraan. Pärast seadistuse salvestamist on põhirakendus kasutatav.

Andmed salvestatakse lokaalselt SQLite andmebaasi — pilve ei lähe midagi.

---

## Testid

```bash
flutter test
```

Testid katavad kõik olulised domeeniteenused (`SetupBudgetCalculator`, `PurchaseRiskEvaluator`, `HomeSummaryCalculator`, `BudgetMoodEvaluator`, `BudgetRebalancingService`) ja mõned ekraani renderdamise juhtumid.

---

## Piirangud

- Korraga üks eelarveprofiil
- Kulu ajalugu pole UI-s nähtav (ainult jooksev kuu)
- Autentimine puudub — lokaalne tööriist

---

## Tulevikuideed (potential olemas trust)

Praegu lisatakse kulud käsitsi. Loogiline järgmine samm oleks see automatiseerida:

- **Tšeki skannimine** — kaamera + OCR, mis loeb pabertšekilt summa ja kauba nimed välja ning pakub automaatselt kategooria ja summa ette
- **Poe API integratsioon** — suurematel kauplusekettidel (nt Rimi, Prisma) on olemas digitaalsed ostutšekid. Nende API kaudu saaks ostuajaloo otse rakendusse tõmmata ilma käsitsi sisestamiseta
- **Panga andmevoog** — Eestis toetab PSD2 direktiiv open banking API-sid. Teoreetiliselt saaks pangakonto tehingud automaatselt kategooriatesse sorteerida

Need kolm asja koos tähendaksid, et kasutaja ei peaks üldse käsitsi midagi sisestama, kulud jookseksid sisse automaatselt.
