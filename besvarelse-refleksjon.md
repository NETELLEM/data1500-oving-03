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

[Skriv ditt svar her]

---

### Spørsmål 2: Hva er forskjellen mellom en bruker og en rolle i PostgreSQL?

**Ditt svar:**

[Skriv ditt svar her]

---

### Spørsmål 3: Hvorfor er det bedre å bruke roller enn å gi rettigheter direkte til brukere?

**Ditt svar:**

[Skriv ditt svar her]

---

### Spørsmål 4: Hva skjer hvis du gir en bruker `DROP` rettighet? Hvilke sikkerhetsproblemer kan det skape?

**Ditt svar:**

[Skriv ditt svar her]

---

### Spørsmål 5: Hvordan ville du implementert at en student bare kan se sine egne karakterer, ikke andres?

**Ditt svar:**

[Skriv ditt svar her]

---

## Notater og observasjoner

Bruk denne delen til å dokumentere interessante funn, problemer du møtte, eller andre observasjoner:

[Skriv dine notater her]


## Oppgave 4: Brukeradministrasjon og GRANT

1. **Hva er Row-Level Security og hvorfor er det viktig?**
   - Svar her...

2. **Hva er forskjellen mellom RLS og kolonnebegrenset tilgang?**
   - Svar her...

3. **Hvordan ville du implementert at en student bare kan se karakterer for sitt eget program?**
   - Svar her...

4. **Hva er sikkerhetsproblemene ved å bruke views i stedet for RLS?**
   - Svar her...

5. **Hvordan ville du testet at RLS-policyer fungerer korrekt?**
   - Svar her...

---

## Referanser

- PostgreSQL dokumentasjon: https://www.postgresql.org/docs/
- Docker dokumentasjon: https://docs.docker.com/

