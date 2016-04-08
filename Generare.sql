SET SERVEROUTPUT ON;

DROP TABLE coordonate_univers;

CREATE TABLE coordonate_univers (
        x NUMBER(5),
        y NUMBER(5),
        z NUMBER(5),
        prieten NUMBER(1),
        constraint PK_D primary key (x, y, z)
        )
  STORAGE (INITIAL 95 M);
  /
  
  
CREATE OR REPLACE PROCEDURE genereaza_distanta(p_x IN coordonate_univers.x%TYPE, p_y IN coordonate_univers.y%TYPE, p_z IN coordonate_univers.z%TYPE, 
                                              p_rezultat OUT NUMBER ) AS
BEGIN
    p_rezultat := (p_x - 5000) * (p_x - 5000) + (p_y - 5000) * (p_y - 5000) + (p_z - 5000) * (p_z - 5000);
END;
/

CREATE OR REPLACE PROCEDURE genereaza_planete AS
    v_planete_create NUMBER(10) := 0;
    v_x coordonate_univers.x%TYPE;
    v_y coordonate_univers.y%TYPE;
    v_z coordonate_univers.z%TYPE;
    v_distanta NUMBER(11);
    v_aux NUMBER(1);
    v_prieten coordonate_univers.prieten%TYPE;
    CURSOR exista_planeta(p_x coordonate_univers.x%TYPE, p_y coordonate_univers.y%TYPE, p_z coordonate_univers.z%TYPE) IS
        SELECT '1' FROM coordonate_univers WHERE x = p_x AND y = p_y AND z = p_z;
BEGIN
    WHILE (v_planete_create < 10000000) 
      LOOP 
        v_x := FLOOR(DBMS_RANDOM.VALUE(0,10001));
        v_y := FLOOR(DBMS_RANDOM.VALUE(0,10001));
        v_z := FLOOR(DBMS_RANDOM.VALUE(0,10001));
        OPEN exista_planeta(v_x, v_y, v_z);
        FETCH exista_planeta INTO v_aux;
        IF (exista_planeta%NOTFOUND)
        -- nu exista deja
          THEN
            genereaza_distanta(v_x, v_y, v_z, v_distanta);
            v_planete_create := v_planete_create + 1;
            v_prieten := TRUNC(DBMS_RANDOM.VALUE(0, 2));
            INSERT INTO coordonate_univers VALUES(v_x, v_y, v_z, v_prieten);
            COMMIT;
        END IF;
        CLOSE exista_planeta;
    END LOOP;

END genereaza_planete;
/


BEGIN
    genereaza_planete();
END;
/

