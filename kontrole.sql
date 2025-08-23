
--router.pks
CREATE OR REPLACE NONEDITIONABLE PACKAGE router AS
    
    e_iznimka EXCEPTION;
    PRAGMA exception_init ( e_iznimka, -20001 );
    PROCEDURE p_main (
        p_in  IN CLOB,
        p_out OUT CLOB
    );

END router;
/

--router.pkb
CREATE OR REPLACE PACKAGE BODY router AS

    PROCEDURE p_main (
        p_in  IN CLOB,
        p_out OUT CLOB
    ) AS

        l_obj       json_object_t;
        l_str       VARCHAR2(4000);
        l_statement VARCHAR2(120) := 'ALTER SESSION SET NLS_NUMBERIC_CHARACTERS = ' || ''',.''';
        l_procedura VARCHAR2(40);
    BEGIN
        l_obj := json_object_t(p_in);
        l_str := l_obj.to_clob;
        l_procedura := JSON_VALUE(l_str, '$.procedura' RETURNING VARCHAR2);
        CASE l_procedura
        --LOGIN
            WHEN 'p_login' THEN
                dohvati.p_login(l_obj);
            WHEN 'p_test' THEN
                dohvati.p_test(l_obj);
            WHEN 'p_clan_po_prezimenu' THEN
                dohvati.p_clan_po_prezimenu(l_obj);
            WHEN 'p_posudbe_po_clanu' THEN
                dohvati.p_posudbe_po_clanu(l_obj);
            WHEN 'p_dodaj_clana' THEN
                podaci.p_dodaj_clana(l_obj);
            WHEN 'p_posudi_film' THEN
                podaci.p_posudi_film(l_obj);
            WHEN 'p_vrati_film' THEN
                podaci.p_vrati_film(l_obj);
            WHEN 'p_filmovi_po_zanru' THEN
            dohvati.p_filmovi_po_zanru(l_obj);
            WHEN 'p_obrisi_clana' THEN
            podaci.p_obrisi_clana(l_obj);
            WHEN 'p_uredi_clana' THEN
            podaci.p_uredi_clana(l_obj);

            ELSE
                l_obj.put('h_message', 'Nepoznata metoda ' || l_procedura);
                l_obj.put('h_errcode', 997);
        END CASE;

        p_out := l_obj.to_clob;
    EXCEPTION
        WHEN e_iznimka THEN
            p_out := l_obj.to_clob;
        WHEN OTHERS THEN
            DECLARE
                l_error PLS_INTEGER := sqlcode;
                l_msg   VARCHAR2(255) := sqlerrm;
            BEGIN
                CASE l_error
                    WHEN -2292 THEN
                        l_obj.put('h_message', 'Navedeni zapis se ne može obrisati jer postoje veze na druge zapise');
                        l_obj.put('h_errcode', 99);
                    ELSE
                        common.p_errlog('p_main', dbms_utility.format_error_backtrace, sqlcode, sqlerrm, l_str);
                        l_obj.put('h_message', 'Greška u obradi podataka');
                        l_obj.put('h_errcode', 100);
                        ROLLBACK;
                END CASE;
            END;

            p_out := l_obj.to_clob;
    END p_main;

END router;
/

--filter.pks
CREATE OR REPLACE PACKAGE filter AS
    e_iznimka EXCEPTION;
    PRAGMA exception_init ( e_iznimka, -20001 );
    FUNCTION f_check_clan (in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean;
    FUNCTION f_check_film (in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean;
    FUNCTION f_check_posudba(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean;
    

END filter;
/


--filter.pkb
CREATE OR REPLACE PACKAGE BODY filter AS

    e_iznimka EXCEPTION;

  /*-------CLAN---------*/
    FUNCTION f_check_clan(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean AS

        l_obj     JSON_OBJECT_T; 
        l_id      NUMBER;
        l_str     VARCHAR2(1000);
        l_clan clan%rowtype;
        l_search varchar2(100);
        l_page number;
        l_perpage number;
    BEGIN
        l_obj := json_object_t(in_json);
        l_str := in_json.TO_STRING;
        
    SELECT
    JSON_VALUE(l_str, '$.id_clan' ),
        JSON_VALUE(l_str, '$.ime'),
        JSON_VALUE(l_str, '$.prezime' ),
        JSON_VALUE(l_str, '$.kontakt' ),
        JSON_VALUE(l_str, '$.datum_clanstva' )
        
    INTO
    l_clan.id_clan,
    l_clan.ime,
    l_clan.prezime,
    l_clan.kontakt,
    l_clan.datum_clanstva
    
    FROM dual;
            
        IF nvl(
            l_clan.ime,
            ' '
        ) = ' ' THEN
            l_obj.put('h_message', 'Molimo unesite ime člana');
            l_obj.put('h_errcode', 101);
            RAISE e_iznimka;
        END IF;

        IF nvl(
            l_clan.prezime,
            ' '
        ) = ' ' THEN
            l_obj.put('h_message', 'Molimo unesite prezime člana');
            l_obj.put('h_errcode', 102);
            RAISE e_iznimka;
        END IF;

        IF nvl(
            l_clan.kontakt,
            ' '
        ) = ' ' THEN
            l_obj.put('h_message', 'Molimo unesite kontakt (e-mail ili mob) člana');
            l_obj.put('h_errcode', 103);
            RAISE e_iznimka;
        END IF;
        
        out_json := l_obj;
        RETURN FALSE;
        
    EXCEPTION
        WHEN e_iznimka THEN
            out_json := l_obj;
            RETURN TRUE;
        WHEN OTHERS THEN
            common.p_errlog('filter.f_check_clan', dbms_utility.format_error_backtrace, sqlcode, sqlerrm, l_str);
            l_obj.put('h_message', 'Dogodila se greška pri validaciji clana');
            l_obj.put('h_errcode', 199);
            out_json := l_obj;
            RETURN TRUE;
    END f_check_clan;

/*-------FILM---------*/

    FUNCTION f_check_film (in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean AS
        
        l_obj    JSON_OBJECT_T;
        l_film   film%rowtype;
        l_str    VARCHAR2(1000);
        l_count  NUMBER;
        l_search VARCHAR2(100);
        l_page NUMBER;
        l_perpage NUMBER;
        
    BEGIN
        l_obj := json_object_t(in_json);
        l_str := l_obj.TO_STRING;
        
    SELECT
    JSON_VALUE(l_str, '$.id_film' ),
        JSON_VALUE(l_str, '$.naslov'),
        JSON_VALUE(l_str, '$.zanr' ),
        JSON_VALUE(l_str, '$.godina' ),
        JSON_VALUE(l_str, '$.trajanje' )
        
    INTO
    
    l_film.id_film,
    l_film.naslov,
    l_film.zanr,
    l_film.godina,
    l_film.trajanje
    
    FROM dual;
    
        
     IF nvl(
            l_film.naslov,
            ' '
        ) = ' ' THEN
            l_obj.put('h_message', 'Molimo unesite naslov filma');
            l_obj.put('h_errcode', 201);
            RAISE e_iznimka;
        END IF;

        IF nvl(
            l_film.zanr,
            ' '
        ) = ' ' THEN
            l_obj.put('h_message', 'Molimo unesite žanr filma');
            l_obj.put('h_errcode', 202);
            RAISE e_iznimka;
        END IF;

        IF l_film.godina IS NULL
           OR l_film.godina < 1890 THEN
            l_obj.put('h_message', 'Neispravna godina (>=1890)');
            l_obj.put('h_errcode', 203);
            RAISE e_iznimka;
        END IF;

        IF l_film.trajanje IS NULL
           OR l_film.trajanje <= 0 THEN
            l_obj.put('h_message', 'Trajanje filma mora biti > 0');
            l_obj.put('h_errcode', 204);
            RAISE e_iznimka;
        END IF;

        out_json := l_obj;
        RETURN FALSE;
    EXCEPTION
        WHEN e_iznimka THEN
            out_json := l_obj;
            RETURN TRUE;
        WHEN OTHERS THEN
            common.p_errlog('filter.f_check_film', dbms_utility.format_error_backtrace, sqlcode, sqlerrm, l_str);
            l_obj.put('h_message', 'Dogodila se greška pri validaciji filma');
            l_obj.put('h_errcode', 299);
            out_json := l_obj;
            RETURN TRUE;
    END f_check_film;

/*-------POSUDBA---------*/
    FUNCTION f_check_posudba(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean AS
        l_obj    JSON_OBJECT_T;
        l_posudba   posudba%rowtype;
        l_str    VARCHAR2(1000);
        l_count  NUMBER;
        l_search VARCHAR2(100);
        l_page NUMBER;
        l_perpage NUMBER;
        l_dat_pos VARCHAR2(20);
        l_dat_pov VARCHAR2(20);
    BEGIN
        l_obj := JSON_OBJECT_T(in_json);  
        l_str := l_obj.TO_STRING;
        
        SELECT
            JSON_VALUE(l_str, '$.id_posudba' ),
            JSON_VALUE(l_str, '$.dat_posudba'),
            JSON_VALUE(l_str, '$.dat_povrat' ),
            JSON_VALUE(l_str, '$.id_clan' ),
            JSON_VALUE(l_str, '$.id_film' )
        INTO
            l_posudba.id_posudba,
            l_posudba.dat_posudba,
            l_posudba.dat_povrat,
            l_posudba.id_clan,
            l_posudba.id_film
        FROM dual;
        
        -- ISPRAVKA: provjeri id_clan i id_film
        IF l_posudba.id_clan IS NULL THEN
            l_obj.put('h_message', 'Nedostaje id_clan');
            l_obj.put('h_errcode', 301);
            RAISE e_iznimka;
        END IF;

        IF l_posudba.id_film IS NULL THEN
            l_obj.put('h_message', 'Nedostaje id_film');
            l_obj.put('h_errcode', 302);
            RAISE e_iznimka;
        END IF;

        SELECT COUNT(*)
        INTO l_count
        FROM clan
        WHERE id_clan = l_posudba.id_clan;

        IF l_count = 0 THEN
            l_obj.put('h_message', 'Član ne postoji');
            l_obj.put('h_errcode', 303);
            RAISE e_iznimka;
        END IF;

        SELECT COUNT(*)
        INTO l_count
        FROM film
        WHERE id_film = l_posudba.id_film;

        IF l_count = 0 THEN
            l_obj.put('h_message', 'Film ne postoji');
            l_obj.put('h_errcode', 304);
            RAISE e_iznimka;
        END IF;

        SELECT COUNT(*)
        INTO l_count
        FROM posudba
        WHERE id_film = l_posudba.id_film
          AND dat_povrat IS NULL;

        IF l_count > 0 THEN
            l_obj.put('h_message', 'Film je već posuđen');
            l_obj.put('h_errcode', 305);
            RAISE e_iznimka;
        END IF;

        l_dat_pos := JSON_VALUE(l_str, '$.dat_posudba' RETURNING VARCHAR2);
        l_dat_pov := JSON_VALUE(l_str, '$.dat_povrat' RETURNING VARCHAR2);
        
        IF l_dat_pos IS NOT NULL AND l_dat_pov IS NOT NULL THEN
            BEGIN
                IF TO_DATE(l_dat_pov, 'YYYY-MM-DD') < TO_DATE(l_dat_pos, 'YYYY-MM-DD') THEN
                    l_obj.put('h_message', 'Datum povrata ne može biti prije datuma posudbe');
                    l_obj.put('h_errcode', 306);
                    RAISE e_iznimka;
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
            END;
        END IF;

        out_json := l_obj;
        RETURN FALSE;
    EXCEPTION
        WHEN e_iznimka THEN
            out_json := l_obj;
            RETURN TRUE;
        WHEN OTHERS THEN
            common.p_errlog('filter.f_check_posudba', dbms_utility.format_error_backtrace, sqlcode, sqlerrm, l_str);
            l_obj.put('h_message', 'Dogodila se greška pri validaciji posudbe');
            l_obj.put('h_errcode', 399);
            out_json := l_obj;
            RETURN TRUE;
    END f_check_posudba;
END filter;
/