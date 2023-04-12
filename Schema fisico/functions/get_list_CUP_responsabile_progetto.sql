--Funzione che recupera la lista dei CUP di cui la matricola è responsabile
CREATE OR REPLACE FUNCTION azienda.get_list_CUP_responsabile_progetto(matricola IN azienda.matricola) 
RETURNS TEXT 
AS
$$
DECLARE
    progettiCoinvolti CURSOR FOR
        SELECT CUP
        FROM azienda.progetto
        WHERE Responsabile = matricola AND (dataFine IS NULL OR dataFine >= current_date);
    
    cup_progetto azienda.CUP;

    lista_responsabile TEXT := '';
BEGIN
    OPEN progettiCoinvolti;
    LOOP
        FETCH progettiCoinvolti INTO cup_progetto;
        EXIT WHEN NOT FOUND;

        lista_responsabile = CONCAT (lista_responsabile, cup_progetto || ', ');
        
    END LOOP;
    CLOSE progettiCoinvolti;

    IF lista_responsabile <> '' THEN
        lista_responsabile = SUBSTR(lista_responsabile, 1, LENGTH(lista_responsabile)-2);
    END IF;

    RETURN lista_responsabile;
END;
$$
LANGUAGE plpgsql;