-- dohvati.pks
CREATE OR REPLACE NONEDITIONABLE PACKAGE dohvati AS
  -- ulaz/izlaz JSON kroz router

    PROCEDURE p_test (
        l_obj IN OUT json_object_t
    );   
    PROCEDURE p_login (
        l_obj IN OUT json_object_t
    );    
    PROCEDURE p_posudbe_po_clanu (
    l_obj IN OUT json_object_t
);
    PROCEDURE p_clan_po_prezimenu (
        l_obj IN OUT json_object_t
    );
    PROCEDURE p_filmovi_po_zanru (
        l_obj IN OUT json_object_t
    );

END dohvati;
/

--dohvati.pkb
CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY DOHVAT AS

--------------------------p_test-----------------------------------
procedure p_test(l_obj in out JSON_OBJECT_T) AS
  l_str varchar2(4000);  
BEGIN
   l_str := l_obj.TO_STRING;
   common.p_logiraj('cao', 'tu sam');
   l_obj.put('pozdrav', 'Hello World!');
   common.p_logiraj('cao', 'tu sam o5');
END p_test;
  
--------------------------p_login-----------------------------------
procedure p_login(l_obj in out JSON_OBJECT_T) AS
  l_string varchar2(4000);  
  l_username    common.korisnici.email%type;
  l_password    common.korisnici.password%type;
  l_id          common.korisnici.id%type;
  l_record      VARCHAR2(4000);
  l_out         json_array_t := json_array_t('[]');
BEGIN
   l_string := l_obj.TO_STRING; 
   l_username := JSON_VALUE(l_string, '$.username' RETURNING VARCHAR2);
   l_password := JSON_VALUE(l_string, '$.password' RETURNING VARCHAR2);

   IF (l_username IS NULL OR l_password IS NULL) THEN
      l_obj.put('h_message', 'Molimo unesite korisničko ime i zaporku');
      l_obj.put('h_errcode', 101);
      RAISE e_iznimka;
   ELSE   
      SELECT COUNT(1)
      INTO l_id
      FROM common.korisnici
      WHERE email = l_username 
        AND password = l_password;

      IF l_id = 0 THEN
         l_obj.put('h_message', 'Nepoznato korisničko ime ili zaporka');
         l_obj.put('h_errcode', 96);
         RAISE e_iznimka;
      ELSIF l_id > 1 THEN
         l_obj.put('h_message', 'Molimo javite se u Informatiku');
         l_obj.put('h_errcode', 42);
         RAISE e_iznimka;
      END IF;
                            
      SELECT JSON_OBJECT( 
               'ID' VALUE kor.id, 
               'ime' VALUE kor.ime, 
               'prezime' VALUE kor.prezime, 
               'OIB' VALUE kor.oib, 
               'email' VALUE kor.email, 
               'spol' VALUE kor.spol, 
               'ovlasti' VALUE kor.ovlasti)
      INTO l_record
      FROM common.korisnici kor
      WHERE email = l_username 
        AND password = l_password;
    
      l_out.append(json_object_t(l_record));
      l_obj.put('data', l_out);
   END IF; 
EXCEPTION
   WHEN e_iznimka THEN
      RAISE;
   WHEN OTHERS THEN
      common.p_errlog('p_login', dbms_utility.format_error_backtrace, sqlcode, sqlerrm, l_string);
      l_obj.put('h_message', 'Greška u obradi podataka');
      l_obj.put('h_errcode', 91);
      RAISE; 
END p_login;

--------------------------ČLAN PO PREZIMENU-----------------------------------  
procedure p_clan_po_prezimenu(l_obj in out JSON_OBJECT_T) AS
  l_str VARCHAR2(4000);
  l_out JSON_ARRAY_T := JSON_ARRAY_T('[]');
  l_prezime VARCHAR2(200);
BEGIN
   l_str := l_obj.to_string;
   l_prezime := JSON_VALUE(l_str, '$.prezime' RETURNING VARCHAR2);
    
   FOR r IN (
      SELECT id_clan, ime, prezime, kontakt, datum_clanstva
      FROM clan
      WHERE l_prezime IS NULL 
         OR UPPER(prezime) LIKE UPPER(l_prezime) || '%'
      ORDER BY prezime, ime
   )
   LOOP
      l_out.append(
         JSON_OBJECT_T()
         .put('id_clan', r.id_clan)
         .put('ime', r.ime)
         .put('prezime', r.prezime)
         .put('kontakt', r.kontakt)
         .put('datum_clanstva', TO_CHAR(r.datum_clanstva, 'YYYY-MM-DD'))
      );
   END LOOP;
        
   l_obj.put('data', l_out);
   l_obj.put('h_message','OK');
   l_obj.put('h_errcode', 0);
EXCEPTION
   WHEN OTHERS THEN
      common.p_errlog('p_clan_po_prezimenu', dbms_utility.format_error_backtrace, sqlcode, sqlerrm, l_str);
      l_obj.put('h_message', 'Greška u dohvacanju clanova');
      l_obj.put('h_errcode', 501);
      RAISE; 
END p_clan_po_prezimenu;

--------------------------FILMOVI PO ŽANRU-----------------------------------
procedure p_filmovi_po_zanru(l_obj in out JSON_OBJECT_T) AS
  l_str   CLOB;
  l_zanr  VARCHAR2(200);
  l_out   JSON_ARRAY_T := JSON_ARRAY_T();
BEGIN
   l_str := l_obj.to_clob;
   l_zanr := JSON_VALUE(l_str, '$.zanr' RETURNING VARCHAR2); 
    
   FOR r IN (
      SELECT id_film, naslov, godina, trajanje
      FROM film
      WHERE l_zanr IS NULL 
         OR UPPER(zanr) = UPPER(l_zanr)
      ORDER BY godina DESC, naslov
   )
   LOOP
      l_out.append(
         JSON_OBJECT_T()
         .put('id_film', r.id_film)
         .put('naslov', r.naslov)
         .put('godina', r.godina)
         .put('trajanje', r.trajanje)
      );
   END LOOP;
    
   l_obj.put('data', l_out);
   l_obj.put('h_message', 'OK');
   l_obj.put('h_errcode', 0);
EXCEPTION
   WHEN OTHERS THEN 
      common.p_errlog('p_filmovi_po_zanru', dbms_utility.format_error_backtrace, sqlcode, sqlerrm, l_str);
      l_obj.put('h_message', 'Greška pri dohvacanju filmova');
      l_obj.put('h_errcode', 512);
      RAISE; 
END p_filmovi_po_zanru;

END DOHVAT;


--------------------------POSUDBE PO CLANU-----------------------------------

PROCEDURE p_posudbe_po_clanu(l_obj IN OUT JSON_OBJECT_T) AS
  l_str      CLOB;
  l_id_clan  NUMBER;
  l_out      JSON_ARRAY_T := JSON_ARRAY_T();
BEGIN
   l_str := l_obj.to_clob;
   l_id_clan := JSON_VALUE(l_str, '$.id_clan' RETURNING NUMBER);
   
   IF l_id_clan IS NULL THEN
      l_obj.put('h_message', 'Nedostaje ID člana');
      l_obj.put('h_errcode', 513);
      RAISE e_iznimka;
   END IF;
    
   FOR r IN (
      SELECT p.id_posudba, p.dat_posudba, p.dat_povrat,
             f.naslov, f.zanr, f.godina,
             c.ime, c.prezime
      FROM posudba p
      INNER JOIN film f ON p.id_film = f.id_film
      INNER JOIN clan c ON p.id_clan = c.id_clan
      WHERE p.id_clan = l_id_clan
      ORDER BY p.dat_posudba DESC
   )
   LOOP
      l_out.append(
         JSON_OBJECT_T()
         .put('id_posudba', r.id_posudba)
         .put('dat_posudba', TO_CHAR(r.dat_posudba, 'YYYY-MM-DD'))
         .put('dat_povrat', CASE WHEN r.dat_povrat IS NOT NULL 
                               THEN TO_CHAR(r.dat_povrat, 'YYYY-MM-DD') 
                               ELSE NULL END)
         .put('film_naslov', r.naslov)
         .put('film_zanr', r.zanr)
         .put('film_godina', r.godina)
         .put('clan_ime', r.ime)
         .put('clan_prezime', r.prezime)
      );
   END LOOP;
    
   l_obj.put('data', l_out);
   l_obj.put('h_message', 'OK');
   l_obj.put('h_errcode', 0);
EXCEPTION
   WHEN e_iznimka THEN
      RAISE;
   WHEN OTHERS THEN 
      common.p_errlog('p_posudbe_po_clanu', dbms_utility.format_error_backtrace, sqlcode, sqlerrm, l_str);
      l_obj.put('h_message', 'Greška pri dohvacanju posudbi');
      l_obj.put('h_errcode', 514);
      RAISE; 
END p_posudbe_po_clanu;

--podaci.pks
CREATE OR REPLACE 
PACKAGE PODACI AS 

  e_iznimka EXCEPTION;
    PRAGMA exception_init(e_iznimka, -20001);
    
    PROCEDURE p_dodaj_clana (
        l_obj IN OUT json_object_t
    );
    PROCEDURE p_posudi_film (
        l_obj IN OUT json_object_t
    );
    PROCEDURE p_vrati_film (
        l_obj IN OUT json_object_t
    );
    PROCEDURE p_obrisi_clana (
        l_obj IN OUT json_object_t
    );
    PROCEDURE p_uredi_clana (
        l_obj IN OUT json_object_t
    );

END PODACI;

--podaci.pkb
CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY podaci AS

--------------------------DODAJ ČLANA-----------------------------------
PROCEDURE p_dodaj_clana(l_obj IN OUT JSON_OBJECT_T) AS
    l_str        CLOB;
    l_obj_out    JSON_OBJECT_T;
    l_error      BOOLEAN := FALSE;
    l_ime        VARCHAR2(30);
    l_prezime    VARCHAR2(30);
    l_kontakt    VARCHAR2(50);
    l_datum      DATE;
    l_new_id     NUMBER;
BEGIN
    l_str := l_obj.to_clob;
    
    
    l_error := filter.f_check_clan(l_obj, l_obj_out);
    
    IF l_error THEN
        l_obj := l_obj_out;
        RAISE e_iznimka;
    END IF;
    
    -- Dohvaćanje podataka iz JSON-a
    l_ime := JSON_VALUE(l_str, '$.ime' RETURNING VARCHAR2);
    l_prezime := JSON_VALUE(l_str, '$.prezime' RETURNING VARCHAR2);
    l_kontakt := JSON_VALUE(l_str, '$.kontakt' RETURNING VARCHAR2);
    l_datum := NVL(TO_DATE(JSON_VALUE(l_str, '$.datum_clanstva'), 'YYYY-MM-DD'), SYSDATE);
    
    -- Insert novog člana
    INSERT INTO clan (ime, prezime, kontakt, datum_clanstva)
    VALUES (l_ime, l_prezime, l_kontakt, l_datum)
    RETURNING id_clan INTO l_new_id;
    
    COMMIT;
    
    l_obj.put('id_clan', l_new_id);
    l_obj.put('h_message', 'Član je uspješno dodana');
    l_obj.put('h_errcode', 0);
    
EXCEPTION
    WHEN e_iznimka THEN
        ROLLBACK;
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK;
        common.p_errlog('p_dodaj_clana', dbms_utility.format_error_backtrace, sqlcode, sqlerrm, l_str);
        l_obj.put('h_message', 'Greška pri dodavanju člana');
        l_obj.put('h_errcode', 601);
        RAISE;
END p_dodaj_clana;

--------------------------POSUDI FILM-----------------------------------
PROCEDURE p_posudi_film(l_obj IN OUT JSON_OBJECT_T) AS
    l_str        CLOB;
    l_obj_out    JSON_OBJECT_T;
    l_error      BOOLEAN := FALSE;
    l_id_clan    NUMBER;
    l_id_film    NUMBER;
    l_dat_posudba DATE;
    l_new_id     NUMBER;
BEGIN
    l_str := l_obj.to_clob;
    
    -- Poziv filter funkcije za validaciju
    l_error := filter.f_check_posudba(l_obj, l_obj_out);
    
    IF l_error THEN
        l_obj := l_obj_out;
        RAISE e_iznimka;
    END IF;
    
    -- Dohvaćanje podataka iz JSON-a
    l_id_clan := JSON_VALUE(l_str, '$.id_clan' RETURNING NUMBER);
    l_id_film := JSON_VALUE(l_str, '$.id_film' RETURNING NUMBER);
    l_dat_posudba := NVL(TO_DATE(JSON_VALUE(l_str, '$.dat_posudba'), 'YYYY-MM-DD'), SYSDATE);
    
    -- Insert nove posudbe
    INSERT INTO posudba (id_clan, id_film, dat_posudba)
    VALUES (l_id_clan, l_id_film, l_dat_posudba)
    RETURNING id_posudba INTO l_new_id;
    
    COMMIT;
    
    l_obj.put('id_posudba', l_new_id);
    l_obj.put('h_message', 'Film je uspješno posuđen');
    l_obj.put('h_errcode', 0);
    
EXCEPTION
    WHEN e_iznimka THEN
        ROLLBACK;
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK;
        common.p_errlog('p_posudi_film', dbms_utility.format_error_backtrace, sqlcode, sqlerrm, l_str);
        l_obj.put('h_message', 'Greška pri posudbi filma');
        l_obj.put('h_errcode', 602);
        RAISE;
END p_posudi_film;

--------------------------VRATI FILM-----------------------------------
PROCEDURE p_vrati_film(l_obj IN OUT JSON_OBJECT_T) AS
    l_str         CLOB;
    l_id_posudba  NUMBER;
    l_dat_povrat  DATE;
    l_count       NUMBER;
BEGIN
    l_str := l_obj.to_clob;
    
    l_id_posudba := JSON_VALUE(l_str, '$.id_posudba' RETURNING NUMBER);
    l_dat_povrat := NVL(TO_DATE(JSON_VALUE(l_str, '$.dat_povrat'), 'YYYY-MM-DD'), SYSDATE);
    
    -- Provjera postojanja posudbe
    SELECT COUNT(*)
    INTO l_count
    FROM posudba
    WHERE id_posudba = l_id_posudba
      AND dat_povrat IS NULL;
    
    IF l_count = 0 THEN
        l_obj.put('h_message', 'Posudba ne postoji ili je film već vraćen');
        l_obj.put('h_errcode', 603);
        RAISE e_iznimka;
    END IF;
    
    -- Update posudbe s datumom povrata
    UPDATE posudba
    SET dat_povrat = l_dat_povrat
    WHERE id_posudba = l_id_posudba;
    
    COMMIT;
    
    l_obj.put('h_message', 'Film je uspješno vraćen');
    l_obj.put('h_errcode', 0);
    
EXCEPTION
    WHEN e_iznimka THEN
        ROLLBACK;
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK;
        common.p_errlog('p_vrati_film', dbms_utility.format_error_backtrace, sqlcode, sqlerrm, l_str);
        l_obj.put('h_message', 'Greška pri vraćanju filma');
        l_obj.put('h_errcode', 604);
        RAISE;
END p_vrati_film;

--------------------------OBRISI ČLANA-----------------------------------
PROCEDURE p_obrisi_clana(l_obj IN OUT JSON_OBJECT_T) AS
    l_str      CLOB;
    l_id_clan  NUMBER;
    l_count    NUMBER;
BEGIN
    l_str := l_obj.to_clob;
    
    l_id_clan := JSON_VALUE(l_str, '$.id_clan' RETURNING NUMBER);
    
    IF l_id_clan IS NULL THEN
        l_obj.put('h_message', 'Nedostaje ID člana');
        l_obj.put('h_errcode', 605);
        RAISE e_iznimka;
    END IF;
    
    -- Provjera postojanja aktivnih posudbi
    SELECT COUNT(*)
    INTO l_count
    FROM posudba
    WHERE id_clan = l_id_clan
      AND dat_povrat IS NULL;
    
    IF l_count > 0 THEN
        l_obj.put('h_message', 'Nije moguće obrisati člana koji ima aktivne posudbe');
        l_obj.put('h_errcode', 606);
        RAISE e_iznimka;
    END IF;
    
    -- Brisanje člana
    DELETE FROM clan
    WHERE id_clan = l_id_clan;
    
    IF SQL%ROWCOUNT = 0 THEN
        l_obj.put('h_message', 'Član s navedenim ID ne postoji');
        l_obj.put('h_errcode', 607);
        RAISE e_iznimka;
    END IF;
    
    COMMIT;
    
    l_obj.put('h_message', 'Član je uspješno obrisan');
    l_obj.put('h_errcode', 0);
    
EXCEPTION
    WHEN e_iznimka THEN
        ROLLBACK;
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK;
        common.p_errlog('p_obrisi_clana', dbms_utility.format_error_backtrace, sqlcode, sqlerrm, l_str);
        l_obj.put('h_message', 'Greška pri brisanju člana');
        l_obj.put('h_errcode', 608);
        RAISE;
END p_obrisi_clana;

--------------------------UREDI ČLANA-----------------------------------
PROCEDURE p_uredi_clana(l_obj IN OUT JSON_OBJECT_T) AS
    l_str         CLOB;
    l_obj_out     JSON_OBJECT_T;
    l_error       BOOLEAN := FALSE;
    l_id_clan     NUMBER;
    l_ime         VARCHAR2(30);
    l_prezime     VARCHAR2(30);
    l_kontakt     VARCHAR2(50);
    l_count       NUMBER;
BEGIN
    l_str := l_obj.to_clob;
    
    l_id_clan := JSON_VALUE(l_str, '$.id_clan' RETURNING NUMBER);
    
    IF l_id_clan IS NULL THEN
        l_obj.put('h_message', 'Nedostaje ID člana');
        l_obj.put('h_errcode', 609);
        RAISE e_iznimka;
    END IF;
    
    -- Poziv filter funkcije za validaciju
    l_error := filter.f_check_clan(l_obj, l_obj_out);
    
    IF l_error THEN
        l_obj := l_obj_out;
        RAISE e_iznimka;
    END IF;
    
    -- Dohvaćanje podataka iz JSON-a
    l_ime := JSON_VALUE(l_str, '$.ime' RETURNING VARCHAR2);
    l_prezime := JSON_VALUE(l_str, '$.prezime' RETURNING VARCHAR2);
    l_kontakt := JSON_VALUE(l_str, '$.kontakt' RETURNING VARCHAR2);
    
    -- Provjera postojanja člana
    SELECT COUNT(*)
    INTO l_count
    FROM clan
    WHERE id_clan = l_id_clan;
    
    IF l_count = 0 THEN
        l_obj.put('h_message', 'Član s navedenim ID ne postoji');
        l_obj.put('h_errcode', 610);
        RAISE e_iznimka;
    END IF;
    
    -- Update člana
    UPDATE clan
    SET ime = l_ime,
        prezime = l_prezime,
        kontakt = l_kontakt
    WHERE id_clan = l_id_clan;
    
    COMMIT;
    
    l_obj.put('h_message', 'Član je uspješno uređen');
    l_obj.put('h_errcode', 0);
    
EXCEPTION
    WHEN e_iznimka THEN
        ROLLBACK;
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK;
        common.p_errlog('p_uredi_clana', dbms_utility.format_error_backtrace, sqlcode, sqlerrm, l_str);
        l_obj.put('h_message', 'Greška pri uređivanju člana');
        l_obj.put('h_errcode', 611);
        RAISE;
END p_uredi_clana;

END podaci;
/


