SET SERVEROUTPUT ON;
-- oarecum inutila
CREATE OR REPLACE FUNCTION get_distanta_la_patrat(p_x IN coordonate_univers.x%TYPE, p_y IN coordonate_univers.y%TYPE, p_z IN coordonate_univers.z%TYPE)
RETURN NUMBER DETERMINISTIC AS
    v_rezultat NUMBER(10);
BEGIN 
    v_rezultat := (p_x - 5000) * (p_x - 5000) + (p_y - 5000) * (p_y - 5000) + (p_z - 5000) * (p_z - 5000);
    RETURN v_rezultat;
END get_distanta_la_patrat;
/

CREATE OR REPLACE FUNCTION genereaza_distanta_doua_puncte(p_x IN coordonate_univers.x%TYPE, p_y IN coordonate_univers.y%TYPE, p_z IN coordonate_univers.z%TYPE, 
                                              p_x2 NUMBER, p_y2 NUMBER, p_z2 NUMBER)
RETURN NUMBER DETERMINISTIC AS
    v_rezultat NUMBER(10);
BEGIN 
    v_rezultat := (p_x - p_x2) * (p_x - p_x2) + (p_y - p_y2) * (p_y - p_y2) + (p_z - p_z2) * (p_z - p_z2);
    RETURN v_rezultat;
END genereaza_distanta_doua_puncte;
/

  
  CREATE TYPE punct AS OBJECT
( x NUMBER(5),
  y NUMBER(5),
  z NUMBER(5));

CREATE TYPE puncte AS TABLE OF punct;

CREATE OR REPLACE FUNCTION genereaza_capete
RETURN puncte AS
    v_locatii_generate NUMBER(3) := 0;
    v_x puncte_alese.x%TYPE;
    v_y puncte_alese.y%TYPE;
    v_z puncte_alese.z%TYPE;
    v_distanta NUMBER(11);
    v_aux NUMBER(1);
    rezultat puncte;
    CURSOR exista_planeta(p_x puncte_alese.x%TYPE, p_y puncte_alese.y%TYPE, p_z puncte_alese.z%TYPE) IS
        SELECT '1' FROM puncte_alese WHERE x = p_x AND y = p_y AND z = p_z;
BEGIN
    rezultat := puncte();
    WHILE (v_locatii_generate < 100) 
      LOOP 
        v_x := FLOOR(DBMS_RANDOM.VALUE(0,10001));
        v_y := FLOOR(DBMS_RANDOM.VALUE(0,10001));
        v_z := FLOOR(DBMS_RANDOM.VALUE(0,10001));
        OPEN exista_planeta(v_x, v_y, v_z);
        FETCH exista_planeta INTO v_aux;
        IF (exista_planeta%NOTFOUND)
        -- nu exista deja
          THEN
            v_distanta := get_distanta_la_patrat(v_x, v_y, v_z);
            IF (v_distanta <= 25000000)
              THEN
                v_locatii_generate := v_locatii_generate + 1;
                rezultat.extend;
                rezultat(rezultat.COUNT) := punct(v_x, v_y, v_z);
            END IF;
        END IF;
        CLOSE exista_planeta;
    END LOOP;
    RETURN rezultat;
END;
/

CREATE OR REPLACE FUNCTION genereaza_scor(p_x NUMBER, p_y NUMBER, p_z NUMBER) 
  RETURN NUMBER AS 
  v_scor NUMBER(10) := 0;
  v_distanta NUMBER(10);
  CURSOR ia_tot IS
      SELECT SUM(decode(prieten, 0, -1, 1, 1)) FROM coordonate_univers WHERE x BETWEEN p_x - 120 AND p_x + 120 AND y BETWEEN p_y - 120 AND p_y + 120 
          AND z BETWEEN p_z - 120 AND p_z + 120 AND genereaza_distanta_doua_puncte(x,y,z, p_x, p_y, p_z) <= 14400 ;
BEGIN
    OPEN ia_tot;
    FETCH ia_tot INTO v_scor;
    CLOSE ia_tot;
    IF (v_scor < 0)
      THEN
        v_scor := -1;
      ELSE
        IF (v_scor > 0)
          THEN
            v_scor := 1;
        END IF;
    END IF;
    RETURN v_scor;
END genereaza_scor;
/

CREATE OR REPLACE PROCEDURE ia_decizie AS
    v_puncte_alese puncte;
    v_linie punct;
    v_decizie NUMBER(4) := 0;
    v_rele NUMBER(2) := 0;
    v_bune number(2) := 0;
BEGIN
    v_puncte_alese := genereaza_capete();
    FOR ind in 1..v_puncte_alese.COUNT
      LOOP
        v_linie := v_puncte_alese(ind);
        v_decizie := v_decizie + genereaza_scor(v_linie.x, v_linie.y, v_linie.z);
    END LOOP;
    IF (v_decizie > 0) 
      THEN
        DBMS_OUTPUT.PUT_LINE('Intra in gaura.');
      ELSE
        DBMS_OUTPUT.PUT_LINE('Nu intra in gaura.');
    END IF;
END;
/

BEGIN
    ia_decizie();
END;

