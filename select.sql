SELECT * FROM
    clan; /*svi clanovi*/

SELECT
    ime,
    prezime
FROM
    clan; /*selectam imena i prezimena*/

SELECT
    naslov,
    godina
FROM
    film
WHERE
    godina > 2000; /*svi filmovi posle 2000*/

SELECT
    id_posudba,
    id_clan,
    id_film,
    dat_posudba
FROM
    posudba
WHERE
    dat_povrat IS NULL; /*Sve sto nije vraceno*/

SELECT
    COUNT(*) AS broj_clanova
FROM
    clan; /*broj clanova*/

/*Ko je posudil koji film?*/
SELECT
    c.ime,
    c.prezime,
    f.naslov,
    p.dat_posudba
FROM
    posudba p
    INNER JOIN clan c ON p.id_clan = c.id_clan
    INNER JOIN film f ON p.id_film = f.id_film;

/*Svi clanovi i njihovi filmovi*/
SELECT
    c.ime,
    c.prezime,
    f.naslov
FROM
    clan  c
    LEFT JOIN posudba p ON c.id_clan = p.id_clan
    LEFT JOIN film    f ON p.id_film = f.id_film;

/*Svi filmovi i njihovi članovi*/
SELECT
    f.naslov,
    c.ime,
    c.prezime
FROM
    film    f
    RIGHT JOIN posudba p ON f.id_film = p.id_film
    RIGHT JOIN clan c ON p.id_clan = c.id_clan;

/*Kolko je put svaki clan posudil film?*/
SELECT
    c.ime,
    c.prezime,
    COUNT(p.id_posudba) AS broj_posudbi
FROM
    clan    c
    LEFT JOIN posudba p ON c.id_clan = p.id_clan
GROUP BY
    c.ime,
    c.prezime;

/*Najposudivaniji filmovi*/
SELECT
    f.naslov,
    COUNT(p.id_posudba) AS broj_posudbi
FROM
    film    f
    LEFT JOIN posudba p ON f.id_film = p.id_film
GROUP BY
    f.naslov
ORDER BY
    broj_posudbi DESC;