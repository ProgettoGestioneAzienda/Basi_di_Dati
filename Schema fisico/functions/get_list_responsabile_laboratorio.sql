--Funzione che recupera la lista dei laboratori di cui la matricola è responsabile scientifico
CREATE OR REPLACE FUNCTION azienda.get_list_responsabile_laboratorio(matricola IN azienda.matricola) 
RETURNS TEXT 
AS
$$
DECLARE
    laboratoriCoinvolti CURSOR FOR
        SELECT Nome
        FROM azienda.laboratorio
        WHERE Responsabile_Scientifico = matricola;
    
    lab azienda.laboratorio.nome%TYPE;

    lista_responsabile_scientifico TEXT := '';
BEGIN
    OPEN laboratoriCoinvolti;
    LOOP
        FETCH laboratoriCoinvolti INTO lab;
        EXIT WHEN NOT FOUND;

        lista_responsabile_scientifico = CONCAT (lista_responsabile_scientifico, lab || ', ');
   
    END LOOP;
    CLOSE laboratoriCoinvolti;

    IF lista_responsabile_scientifico <> '' THEN
        lista_responsabile_scientifico = SUBSTR(lista_responsabile_scientifico, 1, LENGTH(lista_responsabile_scientifico)-2);
    END IF;

    RETURN lista_responsabile_scientifico;
END;
$$
LANGUAGE plpgsql;
