--Funzione di sostituzione del Responsabile scientifico
CREATE OR REPLACE PROCEDURE azienda.sostituisci_responsabile_laboratorio(listaLaboratori IN TEXT, matricola IN azienda.matricola) AS
$$
DECLARE
    copylistaLaboratori TEXT := listaLaboratori;
    lab azienda.laboratorio.nome%TYPE;
    separatoreIndex INT;
BEGIN
    IF listaLaboratori = '' THEN
        RAISE EXCEPTION 'Non ci sono laboratori in input';
    END IF;

    separatoreIndex := STRPOS(listaLaboratori, ', '); --Se è 0 vuol dire che non c'è nessun ', ' ma almeno una parola -> C'è un solo laboratorio in listaLaboratori
    
    WHILE separatoreIndex <> 0
    LOOP
        lab := SUBSTR(listaLaboratori, 1, separatoreIndex-1); --Isolo il laboratorio
        listaLaboratori := SUBSTR(listaLaboratori, separatoreIndex+2, LENGTH(listaLaboratori)); --Cancello il laboratorio e il ', ' dalla lista dei laboratori

        UPDATE azienda.laboratorio
        SET Responsabile_Scientifico = matricola
        WHERE nome = lab;

        separatoreIndex := STRPOS(listaLaboratori, ', '); --Controllo l'esistenza (e ricalcolo la posizione) del prossimo ', '
    END LOOP;

    UPDATE azienda.laboratorio
    SET Responsabile_Scientifico = matricola
    WHERE nome = listaLaboratori;

    RAISE NOTICE 'Ho sostituito il Responsabile Scientifico dei laboratori: % con la matricola "%"', copylistaLaboratori, matricola;
END;
$$
LANGUAGE plpgsql;