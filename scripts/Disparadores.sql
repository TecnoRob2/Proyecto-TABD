CREATE OR REPLACE TRIGGER trg_solapamiento_reservas
BEFORE INSERT OR UPDATE ON Reservas
FOR EACH ROW
DECLARE
    v_solapamientos NUMBER;
    -- Permite consultar la tabla Reservas sin el error de tabla mutante
    PRAGMA AUTONOMOUS_TRANSACTION; 
BEGIN
    SELECT COUNT(*)
    INTO v_solapamientos
    FROM Reservas
    WHERE Zona = :NEW.Zona
      -- Ignorar la propia reserva si estamos haciendo un UPDATE
      AND Id_r != NVL(:NEW.Id_r, -1) 
      -- Lógica estándar para detectar solapamiento de intervalos de fechas
      AND :NEW.F_ini < F_fin 
      AND :NEW.F_fin > F_ini;

    IF v_solapamientos > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Error: La zona ya está reservada durante esas fechas.');
    END IF;
END;


CREATE OR REPLACE TRIGGER trg_fechas_logicas
BEFORE INSERT OR UPDATE ON Reservas
FOR EACH ROW
BEGIN
    -- Comprueba que la fecha de inicio no sea anterior a hoy (ignorando la hora)
    IF :NEW.F_ini < TRUNC(SYSDATE) THEN
        RAISE_APPLICATION_ERROR(-20002, 'Error: La fecha de inicio no puede ser en el pasado.');
    END IF;

    -- Comprueba que la fecha de fin sea posterior a la de inicio
    IF :NEW.F_fin <= :NEW.F_ini THEN
        RAISE_APPLICATION_ERROR(-20003, 'Error: La fecha de fin debe ser estrictamente posterior a la fecha de inicio.');
    END IF;
END;

-- Triggers que permiten que las zonas no puedan ser de otro tipo excepto el declarado en el esquema general de Zonas
CREATE OR REPLACE TRIGGER trg_integridad_piscina
BEFORE INSERT OR UPDATE ON Piscina
FOR EACH ROW
DECLARE
    v_tipo_padre Zonas.Tipo%TYPE;
BEGIN

    SELECT Tipo INTO v_tipo_padre   --tipo registrado en la tabla padre Zonas
    FROM Zonas
    WHERE Id_zona = :NEW.Id_zona;

    -- Validación del subtipo
    IF UPPER(v_tipo_padre) != 'PISCINA' THEN
        RAISE_APPLICATION_ERROR(-20004, 'Error de integridad: El Id_zona insertado no está clasificado como PISCINA en la tabla general de Zonas.');
    END IF;

EXCEPTION
    -- Por seguridad, si por algún motivo la FK falla o se revisa antes
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20005, 'Error: La zona padre no existe.');
END;

CREATE OR REPLACE TRIGGER trg_integridad_BBQ
BEFORE INSERT OR UPDATE ON BBQ
FOR EACH ROW
DECLARE
    v_tipo_padre Zonas.Tipo%TYPE;
BEGIN

    SELECT Tipo INTO v_tipo_padre
    FROM Zonas
    WHERE Id_zona = :NEW.Id_zona;


    IF UPPER(v_tipo_padre) != 'BBQ' THEN
        RAISE_APPLICATION_ERROR(-20004, 'Error de integridad: El Id_zona insertado no está clasificado como BBQ en la tabla general de Zonas.');
    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20005, 'Error: La zona padre no existe.');
END;

CREATE OR REPLACE TRIGGER trg_integridad_premium
BEFORE INSERT OR UPDATE ON Premium
FOR EACH ROW
DECLARE
    v_tipo_padre Zonas.Tipo%TYPE;
BEGIN

    SELECT Tipo INTO v_tipo_padre
    FROM Zonas
    WHERE Id_zona = :NEW.Id_zona;


    IF UPPER(v_tipo_padre) != 'PREMIUM' THEN
        RAISE_APPLICATION_ERROR(-20004, 'Error de integridad: El Id_zona insertado no está clasificado como PREMIUM en la tabla general de Zonas.');
    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20005, 'Error: La zona padre no existe.');
END;
/