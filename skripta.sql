DROP TRIGGER trg_posudba_biub;

DROP TRIGGER trg_film_biub;

DROP TRIGGER trg_clan_biub;

DROP TABLE posudba CASCADE CONSTRAINTS;

DROP TABLE film CASCADE CONSTRAINTS;

DROP TABLE clan CASCADE CONSTRAINTS;

DROP SEQUENCE seq_posudba_id;

DROP SEQUENCE seq_film_id;

DROP SEQUENCE seq_clan_id;

CREATE TABLE clan (
    id_clan        NUMBER PRIMARY KEY,
    ime            VARCHAR2(30) NOT NULL,
    prezime        VARCHAR2(30) NOT NULL,
    kontakt        VARCHAR2(50),
    datum_clanstva DATE DEFAULT sysdate NOT NULL,
    created_at     DATE, /*kad je stvoren*/
    created_by     VARCHAR2(30), /*tko ga je stvorio*/
    updated_at     DATE, /*kad je mijenjan*/
    updated_by     VARCHAR2(30) /*tko ga je mijenjao*/
);

CREATE SEQUENCE seq_clan_id START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE OR REPLACE TRIGGER trg_clan_biub BEFORE
    INSERT OR UPDATE ON clan
    FOR EACH ROW
BEGIN
    IF inserting THEN
        :new.id_clan := seq_clan_id.nextval;
        :new.created_at := sysdate;
        :new.created_by := user;
    END IF;

    IF updating THEN
        :new.updated_at := sysdate;
        :new.updated_by := user;
    END IF;

END;
/

CREATE TABLE film (
    id_film    NUMBER PRIMARY KEY,
    naslov     VARCHAR2(50) NOT NULL,
    zanr       VARCHAR2(30) NOT NULL,
    godina     NUMBER(4) NOT NULL CHECK ( godina >= 1890 ),
    trajanje   NUMBER NOT NULL CHECK ( trajanje > 0 ),
    created_at DATE, /*kad je stvoren*/
    created_by VARCHAR2(30), /*tko ga je stvorio*/
    updated_at DATE, /*kad je mijenjan*/
    updated_by VARCHAR2(30) /*tko ga je mijenjao*/
);

CREATE SEQUENCE seq_film_id START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE OR REPLACE TRIGGER trg_film_biub BEFORE
    INSERT OR UPDATE ON film
    FOR EACH ROW
BEGIN
    IF inserting THEN
        :new.id_film := seq_film_id.nextval;
        :new.created_at := sysdate;
        :new.created_by := user;
    END IF;

    IF updating THEN
        :new.updated_at := sysdate;
        :new.updated_by := user;
    END IF;

END;
/

CREATE TABLE posudba (
    id_posudba  NUMBER PRIMARY KEY,
    dat_posudba DATE NOT NULL,
    dat_povrat  DATE,
    id_clan     NUMBER NOT NULL,
    id_film     NUMBER NOT NULL,
    created_at  DATE, /*kad je stvoren*/
    created_by  VARCHAR2(30), /*tko ga je stvorio*/
    updated_at  DATE, /*kad je mijenjan*/
    updated_by  VARCHAR2(30), /*tko ga je mijenjao*/

    CONSTRAINT fk_posudba_clan FOREIGN KEY ( id_clan )
        REFERENCES clan ( id_clan ),
    CONSTRAINT fk_posudba_film FOREIGN KEY ( id_film )
        REFERENCES film ( id_film )
);

CREATE SEQUENCE seq_posudba_id START WITH 100 INCREMENT BY 1 NOCACHE;

CREATE OR REPLACE TRIGGER trg_posudba_biub BEFORE
    INSERT OR UPDATE ON posudba
    FOR EACH ROW
BEGIN
    IF inserting THEN
        :new.id_posudba := seq_posudba_id.nextval;
        :new.created_at := sysdate;
        :new.created_by := user;
    END IF;

    IF updating THEN
        :new.updated_at := sysdate;
        :new.updated_by := user;
    END IF;

END;
/

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

/*INSERTI*/
INSERT INTO clan (
    ime,
    prezime,
    kontakt,
    datum_clanstva
) VALUES ( 'Imbra',
           'Grabaric',
           'presvetli@gmail.com',
           sysdate );

INSERT INTO film (
    naslov,
    zanr,
    godina,
    trajanje
) VALUES ( 'Mejasi',
           'Komedija',
           1970,
           120 );

INSERT INTO posudba (
    dat_posudba,
    id_clan,
    id_film
) VALUES ( sysdate,
           1,
           1 );

INSERT INTO clan (
    ime,
    prezime,
    kontakt,
    datum_clanstva
) VALUES ( 'Franjo',
           'Ozbolt',
           'cinober@gmail.com',
           sysdate );

INSERT INTO film (
    naslov,
    zanr,
    godina,
    trajanje
) VALUES ( 'Gruntovcani',
           'Komedija',
           1975,
           160 );

INSERT INTO posudba (
    dat_posudba,
    id_clan,
    id_film
) VALUES ( sysdate,
           2,
           2 );

INSERT INTO clan (
    ime,
    prezime,
    kontakt,
    datum_clanstva
) VALUES ( 'Andrija',
           'Katalenic',
           'dudek@gmail.com',
           sysdate );

INSERT INTO film (
    naslov,
    zanr,
    godina,
    trajanje
) VALUES ( 'Dirigenti i Muzikasi',
           'Komedija',
           1991,
           180 );

INSERT INTO posudba (
    dat_posudba,
    id_clan,
    id_film
) VALUES ( sysdate - 10,
           3,
           3 );

INSERT INTO clan (
    ime,
    prezime,
    kontakt,
    datum_clanstva
) VALUES ( 'Luka',
           'Misir',
           'lmisir@vub.hr',
           sysdate - 30 );

INSERT INTO film (
    naslov,
    zanr,
    godina,
    trajanje
) VALUES ( 'Breaking Bad',
           'Drama',
           2008,
           400 );

INSERT INTO posudba (
    dat_posudba,
    id_clan,
    id_film
) VALUES ( sysdate - 30,
           4,
           4 );

INSERT INTO clan (
    ime,
    prezime,
    kontakt,
    datum_clanstva
) VALUES ( 'Marija',
           'Novak',
           'marija.novak@mail.com',
           sysdate - 5 );

INSERT INTO film (
    naslov,
    zanr,
    godina,
    trajanje
) VALUES ( 'Inception',
           'SF',
           2010,
           148 );

INSERT INTO posudba (
    dat_posudba,
    id_clan,
    id_film
) VALUES ( sysdate - 5,
           5,
           5 );

INSERT INTO clan (
    ime,
    prezime,
    kontakt,
    datum_clanstva
) VALUES ( 'Ivan',
           'Horvat',
           'ivan.horvat@mail.com',
           sysdate - 3 );

INSERT INTO film (
    naslov,
    zanr,
    godina,
    trajanje
) VALUES ( 'Matrix',
           'SF',
           1999,
           136 );

INSERT INTO posudba (
    dat_posudba,
    id_clan,
    id_film
) VALUES ( sysdate - 3,
           6,
           6 );

INSERT INTO clan (
    ime,
    prezime,
    kontakt,
    datum_clanstva
) VALUES ( 'Ana',
           'Kovacic',
           'ana.kovacic@mail.com',
           sysdate - 20 );

INSERT INTO film (
    naslov,
    zanr,
    godina,
    trajanje
) VALUES ( 'Titanic',
           'Drama',
           1997,
           195 );

INSERT INTO posudba (
    dat_posudba,
    id_clan,
    id_film
) VALUES ( sysdate - 20,
           7,
           7 );

INSERT INTO clan (
    ime,
    prezime,
    kontakt,
    datum_clanstva
) VALUES ( 'Petar',
           'Zoric',
           'petar.zoric@mail.com',
           sysdate - 15 );

INSERT INTO film (
    naslov,
    zanr,
    godina,
    trajanje
) VALUES ( 'Avengers',
           'Akcija',
           2012,
           143 );

INSERT INTO posudba (
    dat_posudba,
    id_clan,
    id_film
) VALUES ( sysdate - 15,
           8,
           8 );

INSERT INTO clan (
    ime,
    prezime,
    kontakt,
    datum_clanstva
) VALUES ( 'Katarina',
           'Matic',
           'katarina.matic@mail.com',
           sysdate - 40 );

INSERT INTO film (
    naslov,
    zanr,
    godina,
    trajanje
) VALUES ( 'Gladiator',
           'Povijesni',
           2000,
           155 );

INSERT INTO posudba (
    dat_posudba,
    id_clan,
    id_film
) VALUES ( sysdate - 40,
           9,
           9 );

INSERT INTO clan (
    ime,
    prezime,
    kontakt,
    datum_clanstva
) VALUES ( 'Tomislav',
           'Peric',
           'tomislav.peric@mail.com',
           sysdate - 60 );

INSERT INTO film (
    naslov,
    zanr,
    godina,
    trajanje
) VALUES ( 'Joker',
           'Drama',
           2019,
           122 );

INSERT INTO posudba (
    dat_posudba,
    id_clan,
    id_film
) VALUES ( sysdate - 60,
           10,
           10 );

UPDATE clan
SET
    kontakt = '098338333'
WHERE
    id_clan = 5;

UPDATE film
SET
    trajanje = trajanje + 10
WHERE
    id_film = 7;

UPDATE clan
SET
    prezime = 'Glista'
WHERE
    id_clan = 8;

UPDATE posudba
SET
    dat_povrat = sysdate
WHERE
    id_posudba = 101;

UPDATE film
SET
    zanr = 'Triler'
WHERE
    naslov = 'Joker';

DELETE FROM posudba
WHERE
    id_posudba = 109;

DELETE FROM posudba
WHERE
    id_clan = 7;

DELETE FROM clan
WHERE
    id_clan = 7;

DELETE FROM film
WHERE
    godina < 1970;

DELETE FROM posudba
WHERE
    dat_povrat IS NOT NULL;

DELETE FROM clan
WHERE
    prezime = 'Zoric';
    
    