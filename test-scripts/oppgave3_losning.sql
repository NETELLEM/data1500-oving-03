-- --------------------------------------------------------
-- NULLSTILLING (For å kunne kjøre scriptet flere ganger)
-- --------------------------------------------------------
-- Vi fjerner rollene hvis de finnes fra før for å starte på nytt
DROP ROLE IF EXISTS program_ansvarlig;
DROP ROLE IF EXISTS student_self_view;
DROP ROLE IF EXISTS backup_bruker;
-- Vi sletter viewet hvis det finnes (bruker CASCADE for å fjerne avhengigheter)
DROP VIEW IF EXISTS student_view CASCADE;


-- --------------------------------------------------------
-- 1. Rolle: program_ansvarlig
-- Skal kunne lese (SELECT) og endre (UPDATE) programmer, men ikke slette.
-- --------------------------------------------------------
CREATE USER program_ansvarlig WITH PASSWORD 'ansvarlig123';

-- Må ha lov til å koble til databasen
GRANT CONNECT ON DATABASE data1500_db TO program_ansvarlig;

-- Gir spesifikke rettigheter på tabellen 'programmer'
GRANT SELECT, UPDATE ON programmer TO program_ansvarlig;
-- Merk: Vi gir IKKE DELETE eller INSERT her.


-- --------------------------------------------------------
-- 2. Rolle: student_self_view (og Viewet)
-- Skal bare kunne se sine egne data.
-- --------------------------------------------------------

-- Først lager vi et VIEW som filtrerer dataene.
-- Logikk: Vis rader hvor eposten i tabellen matcher brukernavnet som er logget inn.
-- (Dette forutsetter at brukernavnet i Postgres er det samme som eposten,
-- eller at vi bruker 'current_user' som placeholder).
CREATE OR REPLACE VIEW student_view AS
SELECT * FROM studenter
WHERE epost = current_user OR current_user = 'foreleser_role' OR current_user = 'admin';
-- Merk: Jeg la til 'foreleser_role' i WHERE-klausulen så viewet ikke blir tomt for dem i neste steg.

-- Så lager vi rollen
CREATE USER student_self_view WITH PASSWORD 'student123';
GRANT CONNECT ON DATABASE data1500_db TO student_self_view;

-- Gi rollen tilgang KUN til viewet, ikke til hovedtabellen 'studenter'
GRANT SELECT ON student_view TO student_self_view;


-- --------------------------------------------------------
-- 3. Gi foreleser_role tilgang til student_view
-- --------------------------------------------------------
-- Foreleser finnes fra før (fra oppgave 2/tidligere scripts), så vi bruker GRANT direkte.
GRANT SELECT ON student_view TO foreleser_role;


-- --------------------------------------------------------
-- 4. Rolle: backup_bruker
-- Skal ha SELECT-rettighet på ALLE tabeller (for backup).
-- --------------------------------------------------------
CREATE USER backup_bruker WITH PASSWORD 'backup123';
GRANT CONNECT ON DATABASE data1500_db TO backup_bruker;

-- Gir lesetilgang til alle tabeller i 'public' schema
GRANT SELECT ON ALL TABLES IN SCHEMA public TO backup_bruker;
-- Det er også lurt å gi tilgang til sekvenser (for ID-generering) ved backup
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO backup_bruker;


-- --------------------------------------------------------
-- 5. Lag en rapport over rettigheter
-- Vi henter data fra systemkatalogen for å bevise at rettighetene er satt.
-- --------------------------------------------------------
SELECT 
    grantee AS rolle_navn, 
    table_name AS tabell_eller_view, 
    privilege_type AS rettighet
FROM information_schema.role_table_grants
WHERE grantee IN ('program_ansvarlig', 'student_self_view', 'backup_bruker', 'foreleser_role')
ORDER BY grantee, table_name;
