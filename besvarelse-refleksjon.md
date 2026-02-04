# Besvarelse av refleksjonsspørsmål - DATA1500 Oppgavesett 1.3

Skriv dine svar på refleksjonsspørsmålene fra hver oppgave her.

---

## Oppgave 1: Docker-oppsett og PostgreSQL-tilkobling

### Spørsmål 1: Hva er fordelen med å bruke Docker i stedet for å installere PostgreSQL direkte på maskinen?

**Ditt svar:**

Docker er et program som holder til seg slev, mens PostgreSQL sprer seg til adnre filler så når du sletter den fins det forsat deller av den på pc din. vi spiller ogås versjon konfilkter siden i PostgreSQ L må det være samme versjon. Docker er universal så du kan jobbe med folk som er på Linux mac eller/og windows uten at det skejer "men det funker på min PC". interface på Docker er universlal og enklere 

---

### Spørsmål 2: Hva betyr "persistent volum" i docker-compose.yml? Hvorfor er det viktig?

**Ditt svar:**

Uten et "persistent volume" mister du all dataen din hver gang du slår av eller starter containeren på nytt. dette skjer siden den er på ram så når den avlsuttes den blir ikke lagret Persistent Volume løser dette problemet med å være en bro (eller en navlestreng) mellom den midlertidige containeren og den faste harddisken på din Mac.

---

### Spørsmål 3: Hva skjer når du kjører `docker-compose down`? Mister du dataene?

**Ditt svar:**

Nei, du mister ikke data. docker-compose down sletter kun selve containeren (programmet som kjører). Dataene dine ligger trygt i en mappe på din Mac (takket være volumes). Neste gang du kjører up, henter Docker dataene fra den mappen igjen. (Unntak: Hvis du kjører docker-compose down -v, slettes alt.)

---

### Spørsmål 4: Forklar hva som skjer når du kjører `docker-compose up -d` første gang vs. andre gang.

**Ditt svar:**

Første gang (Tungt arbeid):

   Laster ned: Docker må hente hele PostgreSQL-programmet ("imaget") fra internett. Dette tar tid.

   Bygger: Den oppretter nettverk og gjør klar lagringsplassen (volumene).

   Starter: Den starter containeren.

Andre gang (Lynraskt):

   Sjekker: Docker ser etter om containeren allerede finnes.

   Hvis den kjører: Gjør ingenting (svarer "Up to date").

   Hvis den er stoppet: Starter den bare opp igjen umiddelbart (uten å laste ned noe).

Kort sagt: Første gang er installasjon, andre gang er bare å skru på.

---

### Spørsmål 5: Hvordan ville du delt docker-compose.yml-filen med en annen student? Hvilke sikkerhetshensyn må du ta?

**Ditt svar:**

Jeg ville delt docker-compose.yml-filen, men uten å inkludere passord eller sensitive data direkte i filen.

---

## Oppgave 2: SQL-spørringer og databaseskjema

### Spørsmål 1: Hva er forskjellen mellom INNER JOIN og LEFT JOIN? Når bruker du hver av dem?

**Ditt svar:**

Forskjellen: INNER JOIN henter kun ut rader der det er match i begge tabellene. Data som ikke har en kobling, blir filtrert bort. LEFT JOIN henter ut alle rader fra den venstre tabellen (den du nevner først), pluss matchende rader fra den høyre. Hvis det ikke finnes noen match i høyre tabell, fylles feltene der med NULL. Jeg bruker INNER JOIN når jeg kun vil se data som henger sammen (f.eks. for å finne studenter som faktisk har meldt seg opp i et fag). Jeg bruker LEFT JOIN når jeg vil finne "hull" i dataene eller ha en komplett oversikt (f.eks. oppgaven vi nettopp gjorde der vi fant studenter som ikke hadde noen emneregistreringer).

---

### Spørsmål 2: Hvorfor bruker vi fremmednøkler? Hva skjer hvis du prøver å slette et program som har studenter?

**Ditt svar:**

Hvorfor: Vi bruker fremmednøkler (Foreign Keys) for å sikre dataintegritet. Det garanterer at en kobling mellom to tabeller er gyldig. Man kan for eksempel ikke registrere en student på en program_id som ikke finnes i program-tabellen.

Hva skjer ved sletting: Hvis jeg prøver å slette et studieprogram som har studenter koblet til seg, vil databasen stoppe meg og gi en feilmelding (Constraint Violation). Dette er en sikkerhetsmekanisme for å hindre at studentene blir liggende igjen som "foreldreløse" data som peker på noe som ikke lenger eksisterer. (For å slette må man enten slette studentene først, eller ha konfigurert ON DELETE CASCADE).

---

### Spørsmål 3: Forklar hva `GROUP BY` gjør og hvorfor det er nødvendig når du bruker aggregatfunksjoner.

**Ditt svar:**

Hva den gjør: GROUP BY samler rader som har samme verdi i bestemte kolonner til én enkelt rad. Tenk på det som å sortere data i "bøtter" før man teller dem.

Hvorfor nødvendig: Når vi bruker aggregatfunksjoner (som COUNT, SUM, MAX), må databasen vite på hvilket nivå den skal regne. Vi kan ikke be om å få se både navnet på hver enkelt student og totalt antall studenter i én operasjon, uten å gruppere dem. Hvis vi skal telle antall emner per student, må vi gruppere på studenten slik at COUNT vet at den skal starte tellingen på nytt for hver unike student.

---

### Spørsmål 4: Hva er en indeks og hvorfor er den viktig for ytelse?

**Ditt svar:**

En indeks i en database fungerer akkurat som stikkordsregisteret (indeksen) bak i en lærebok.

Hvorfor viktig: Uten en indeks må databasen skanne gjennom hver eneste rad i hele tabellen for å finne det den leter etter (Sequential Scan), noe som går tregt hvis tabellen er stor. Med en indeks kan databasen slå opp direkte på riktig sted, noe som gjør SELECT-spørringer og filtrering (WHERE) ekstremt mye raskere. (Ulempen er at det tar litt lenger tid å lagre nye data, siden indeksen også må oppdateres).

---

### Spørsmål 5: Hvordan ville du optimalisert en spørring som er veldig treg?

**Ditt svar:**

For å optimalisere en treg spørring ville jeg gjort følgende:

Analysere med EXPLAIN: Jeg ville brukt kommandoen EXPLAIN (eller EXPLAIN ANALYZE i PostgreSQL) foran spørringen for å se hvilken del som tar tid.

Opprette indekser: Hvis analysen viser at den skanner hele tabeller, ville jeg lagt til indekser på kolonnene jeg ofte søker i eller kobler sammen (JOIN).

Velge kun nødvendige data: I stedet for å skrive SELECT *, ville jeg kun hentet de spesifikke kolonnene jeg trenger.

Filtrere tidlig: Sørge for at WHERE-klausulen min snevrer inn datamengden så tidlig som mulig.

---

## Oppgave 3: Brukeradministrasjon og GRANT

### Spørsmål 1: Hva er prinsippet om minste rettighet? Hvorfor er det viktig?

**Ditt svar:**

prinsippet om minst rettighet er en bruker, et program eller en prosess skal kun ha tilgang til de dataene og funksjonene som er absolutt nødvendige for å få gjort jobben sin. Hverken mer eller mindre. . dette er viktig siden man hvil ikek at alle kan gjøre alt men heller beste gruppe folk har speseile roller 

---

### Spørsmål 2: Hva er forskjellen mellom en bruker og en rolle i PostgreSQL?

**Ditt svar:**

Teknisk sett er det ingen forskjell. I PostgreSQL er alt en Rolle (Role). For PostgreSQL er en "User" bare en "Rolle som tilfeldigvis har nøkkelkortet til inngangsdøra". Du kan når som helst ta en rolle og gi den LOGIN-rettighet, og vips, så er det en bruker.

---

### Spørsmål 3: Hvorfor er det bedre å bruke roller enn å gi rettigheter direkte til brukere?

**Ditt svar:**

siden da man må gå bruker og bruker og om man er en skole så må man gi vær lærer indivuelt rolle. men med roller kan man gi alle lærerne på en gang og om man skal bytte på noe så må du på alle lærene isteded for bare bytte på rollen 

---

### Spørsmål 4: Hva skjer hvis du gir en bruker `DROP` rettighet? Hvilke sikkerhetsproblemer kan det skape?

**Ditt svar:**

Å gi en bruker DROP-rettighet er i praksis det samme som å gi dem en slette-knapp for selve infrastrukturen i databasen. Det er en av de farligste rettighetene man kan dele ut. siden den sakper en stor sikkerhetsproblemer siden da kan noen ta rollen og slette flere brukere som kan lede til Total Dataødeleggelse

---

### Spørsmål 5: Hvordan ville du implementert at en student bare kan se sine egne karakterer, ikke andres?

**Ditt svar:**

For å sikre at en student kun får se sine egne karakterer, ville jeg implementert dette så nær dataene som mulig for å sikre dataintegriteten. Jeg ville vurdert to metoder i PostgreSQL:

1. Row-Level Security (RLS) – Den mest robuste metoden: Dette er den foretrukne løsningen i moderne PostgreSQL. Jeg ville aktivert RLS på tabellen emneregistreringer.

   Hvordan: Jeg oppretter en sikkerhetspolicy (CREATE POLICY) som sjekker om den innloggede brukeren matcher studenten i raden.

   Logikk: USING (student_brukernavn = current_user).

   Fordel: Databasen håndhever regelen automatisk uansett hvilken spørring som kjøres. Selv SELECT * FROM emneregistreringer vil kun returnere studentens egne rader.

2. Bruk av Views (Alternativ metode): Hvis RLS ikke er tilgjengelig, ville jeg opprettet et View som fungerer som et filter.

   Hvordan: CREATE VIEW mine_karakterer AS SELECT * FROM emneregistreringer WHERE student_id = (SELECT id FROM studenter WHERE brukernavn = current_user);

   Tilgang: Jeg gir studenten tilgang (GRANT SELECT) kun til dette viewet, og ikke til selve hovedtabellen.

---

## Notater og observasjoner
OPPGAVE 3 DEL 2
Bruk denne delen til å dokumentere interessante funn, problemer du møtte, eller andre observasjoner:
```sql
data1500_db=> docker-compose exec postgres psql -U foreleser_role -d data1500_db 
data1500_db-> foreleser_pass
data1500_db-> -- Skal fungere (SELECT)
data1500_db-> SELECT * FROM studenter;
ERROR:  syntax error at or near "docker"
LINE 1: docker-compose exec postgres psql -U foreleser_role -d data1...
        ^
data1500_db=> 
data1500_db=> -- Skal fungere (INSERT)
data1500_db=> INSERT INTO studenter (fornavn, etternavn, epost, program_id) 
data1500_db-> VALUES ('Test', 'Bruker', 'test@example.com', 1);
INSERT 0 1
data1500_db=> 
data1500_db=> -- Skal IKKE fungere (DELETE)
data1500_db=> DELETE FROM studenter WHERE student_id = 1;
ERROR:  permission denied for table studenter
data1500_db=> 
```

Jeg forsøkte å utføre SELECT, INSERT og DELETE med brukeren foreleser_role.

SELECT: Fungerte som forventet (fikk lest data).

INSERT: Kommandoen INSERT INTO studenter... ga resultatet INSERT 0 1. Dette bekrefter at foreleseren har skrivetilgang og kan opprette nye studenter.

DELETE: Kommandoen DELETE FROM studenter... ga feilmeldingen ERROR: permission denied for table studenter. Dette bekrefter at foreleser-rollen fungerer etter prinsippet om minste rettighet; brukeren har ikke slettetilgang, noe som hindrer utilsiktet tap av data.

OPPGAVE 3 DEL 3
```sql
data1500_db=> SELECT * FROM studenter;
 student_id | fornavn | etternavn |              epost               | program_id |         opprettet          
------------+---------+-----------+----------------------------------+------------+----------------------------
          1 | Ola     | Nordmann  | ola.nordmann@student.oslomet.no  |          1 | 2026-01-22 10:20:56.462972
          2 | Kari    | Normann   | kari.normann@student.oslomet.no  |          1 | 2026-01-22 10:20:56.462972
          3 | Per     | Larsen    | per.larsen@student.oslomet.no    |          2 | 2026-01-22 10:20:56.462972
          4 | Anna    | Johansen  | anna.johansen@student.oslomet.no |          3 | 2026-01-22 10:20:56.462972
          5 | Test    | Bruker    | test@example.com                 |          1 | 2026-02-04 13:14:36.402025
(5 rows)

data1500_db=> 
data1500_db=> -- Skal IKKE fungere (INSERT)
data1500_db=> INSERT INTO studenter (fornavn, etternavn, epost, program_id) 
data1500_db-> VALUES ('Test', 'Bruker', 'test@example.com', 1);
ERROR:  permission denied for table studenter
data1500_db=> 
data1500_db=> -- Skal IKKE fungere (UPDATE)
data1500_db=> UPDATE studenter SET fornavn = 'Ola' WHERE student_id = 1;
ERROR:  permission denied for table studenter
```
Jeg koblet til databasen med brukeren student_role for å verifisere tilgangsnivået.

Lesetilgang (SELECT): Kommandoen kjørte vellykket og returnerte listen over studenter. Dette bekrefter at rollen har leserettigheter.

Skrivetilgang (INSERT): Kommandoen ble avvist av databasen med feilmeldingen ERROR: permission denied for table studenter.

Endringstilgang (UPDATE): Kommandoen ble også avvist med permission denied.

Konklusjon: Testen bekrefter at student_role er korrekt begrenset til kun å lese data. Studenten har ingen mulighet til å endre eller slette informasjon i databasen, noe som oppfyller kravet om begrenset tilgang.

## Oppgave 4: Brukeradministrasjon og GRANT

1. **Hva er Row-Level Security og hvorfor er det viktig?**
   - Row-Level Security (RLS) er en sikkerhetsmekanisme i databasen som filtrerer hvilke rader en bruker har lov til å se eller endre i en tabell. I stedet for at tilgang enten er "alt eller ingenting", sjekkes hver enkelt rad mot et regelsett (Policy) når en spørring kjøres.

Det er viktig fordi:

Dataminimering (GDPR): Det sikrer at brukere kun ser dataene de absolutt trenger.

Sikkerhet i dybden: Selv om applikasjonen (nettsiden) glemmer å filtrere dataene i SQL-spørringen (f.eks. WHERE student_id = ...), vil databasen automatisk skjule radene som brukeren ikke skal se. Det fungerer som et siste sikkerhetsnett.

2. **Hva er forskjellen mellom RLS og kolonnebegrenset tilgang?**
   - Forskjellen ligger i hvilken "retning" man kutter tilgangen i tabellen:

RLS (Horisontal filtrering): Begrenser hvilke rader (oppføringer) man ser.

Eksempel: En student ser kun sine egne rader, men ser alle feltene i de radene.

Kolonnebegrenset tilgang (Vertikal filtrering): Begrenser hvilke felter (kolonner) man ser.

Eksempel: En student kan se navnet til medstudenter, men personnummer-kolonnen er skjult eller nullstilt.

3. **Hvordan ville du implementert at en student bare kan se karakterer for sitt eget program?**
   - For å løse dette må RLS-policyen sjekke en kobling mellom tabellene. Policyen må verifisere at program_id til den innloggede studenten matcher program_id til studenten som eier karakteren.

4. **Hva er sikkerhetsproblemene ved å bruke views i stedet for RLS?**
   - Hovedproblemet med Views er at sikkerheten ikke er knyttet til selve dataene, men til "vinduet" man ser gjennom.

5. **Hvordan ville du testet at RLS-policyer fungerer korrekt?**
   - Testing av RLS krever at man simulerer de ulike brukerrollene. Jeg ville utført to typer tester:

Positiv testing: Logg inn som en student (f.eks. "Student A") og verifiser at du får opp dine egne karakterer (SELECT count(*) ... skal være > 0).

Negativ testing (Viktigst): Logg inn som "Student A" og prøv eksplisitt å hente karakterene til "Student B" ved å bruke WHERE student_id = [Student B sin ID]. Resultatet skal være 0 rader eller "Permission denied".

Sjekk admin: Verifiser at en admin-bruker eller foreleser fortsatt ser alle dataene, slik at systemet ikke har låst ute de som skal ha full tilgang.

---

## Referanser

- PostgreSQL dokumentasjon: https://www.postgresql.org/docs/
- Docker dokumentasjon: https://docs.docker.com/

