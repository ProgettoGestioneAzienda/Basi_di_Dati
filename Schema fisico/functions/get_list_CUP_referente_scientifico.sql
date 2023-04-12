--Funzione che recupera la lista dei CUP di cui la matricola è referente scientifico
CREATE OR REPLACE FUNCTION azienda.get_list_CUP_referente_scientifico(matricola IN azienda.matricola) 
RETURNS TEXT 
AS
$$
DECLARE
    progettiCoinvolti CURSOR FOR
        SELECT CUP
        FROM azienda.progetto
        WHERE Referente_Scientifico = matricola AND (dataFine IS NULL OR dataFine >= current_date);
    
    cup_progetto azienda.CUP;

    lista_referente_scientifico TEXT := '';
BEGIN
    OPEN progettiCoinvolti;
    LOOP
        FETCH progettiCoinvolti INTO cup_progetto;
        EXIT WHEN NOT FOUND;

        lista_referente_scientifico = CONCAT (lista_referente_scientifico, cup_progetto || ', ');
   
    END LOOP;
    CLOSE progettiCoinvolti;

    IF lista_referente_scientifico <> '' THEN
        lista_referente_scientifico = SUBSTR(lista_referente_scientifico, 1, LENGTH(lista_referente_scientifico)-2);
    END IF;

    RETURN lista_referente_scientifico;
END;
$$
LANGUAGE plpgsql;