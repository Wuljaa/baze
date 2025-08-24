DROP TRIGGER trg_posudba_biub;

DROP TRIGGER trg_film_biub;

DROP TRIGGER trg_clan_biub;

DROP TABLE posudba CASCADE CONSTRAINTS;

DROP TABLE film CASCADE CONSTRAINTS;

DROP TABLE clan CASCADE CONSTRAINTS;

DROP SEQUENCE seq_posudba_id;

DROP SEQUENCE seq_film_id;

DROP SEQUENCE seq_clan_id;   --brise sve da mozes normalno startat--

CREATE TABLE clan (
    id_clan        NUMBER PRIMARY KEY,  --"tablica clan koja ima id_clan, koja prima broj i primary key"--
    ime            VARCHAR2(30) NOT NULL,
    prezime        VARCHAR2(30) NOT NULL,
    kontakt        VARCHAR2(50),
    datum_clanstva DATE DEFAULT sysdate NOT NULL,
    created_at     DATE, /*kad je stvoren*/   --audit polja--
    created_by     VARCHAR2(30), /*tko ga je stvorio*/
    updated_at     DATE, /*kad je mijenjan*/
    updated_by     VARCHAR2(30) /*tko ga je mijenjao*/
);

CREATE SEQUENCE seq_clan_id START WITH 1 INCREMENT BY 1 NOCACHE; --stvaramo sekvencu i inkrementiramo za 1--

CREATE OR REPLACE TRIGGER trg_clan_biub BEFORE --stvaramo before insert and update trigger za tablicu clan--
    INSERT OR UPDATE ON clan --prije unosenja ili updatanja tablice clan za svaki red..--
    FOR EACH ROW
BEGIN
    IF inserting THEN
        :new.id_clan := seq_clan_id.nextval; --da ne pisemo svaki put na pocetak seq_clan_id.nextval, nek da ga automatski uzme--
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



