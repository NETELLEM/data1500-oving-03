-- 1. Hent alle studenter som ikke har noen emneregistreringer
SELECT s.fornavn, s.etternavn
FROM studenter s
LEFT JOIN emneregistreringer e ON s.student_id = e.student_id
WHERE e.student_id IS NULL;

-- 2. Hent alle emner som ingen studenter er registrert på
SELECT em.emne_kode, em.emne_navn
FROM emner em
LEFT JOIN emneregistreringer e ON em.emne_id = e.emne_id
WHERE e.emne_id IS NULL;

-- 3. Hent studentene med høyeste karakter per emne
-- Vi må koble emneregistrering mot emner for å vise koden, og studenter for å vise navnet
SELECT em.emne_kode, s.fornavn, s.etternavn, e1.karakter
FROM emneregistreringer e1
JOIN emner em ON e1.emne_id = em.emne_id
JOIN studenter s ON e1.student_id = s.student_id
WHERE e1.karakter = (
    -- Sub-spørring: Finn beste karakter (MIN) for akkurat dette emnet
    SELECT MIN(karakter)
    FROM emneregistreringer e2
    WHERE e2.emne_id = e1.emne_id
);

-- 4. Rapport: Student, program og antall emner
-- Vi bruker program_id siden vi vet den finnes i student-tabellen
SELECT s.fornavn, s.etternavn, s.program_id, COUNT(e.emne_id) AS antall_emner
FROM studenter s
LEFT JOIN emneregistreringer e ON s.student_id = e.student_id
GROUP BY s.student_id, s.fornavn, s.etternavn, s.program_id;

-- 5. Studenter registrert på BÅDE DATA1500 og DATA1100
SELECT s.fornavn, s.etternavn
FROM studenter s
JOIN emneregistreringer e ON s.student_id = e.student_id
JOIN emner em ON e.emne_id = em.emne_id
WHERE em.emne_kode IN ('DATA1500', 'DATA1100')
GROUP BY s.student_id, s.fornavn, s.etternavn
HAVING COUNT(DISTINCT em.emne_kode) = 2;
