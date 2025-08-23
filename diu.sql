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