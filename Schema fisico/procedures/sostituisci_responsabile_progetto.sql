--Funzione di sostituzione del Responsabile
CREATE OR REPLACE PROCEDURE azienda.sostituisci_responsabile_progetto(listaCUP IN TEXT, matricola IN azienda.matricola) 
AS
$$
DECLARE
    copyListaCUP TEXT := listaCUP;
    singleCUP azienda.CUP;
    separatoreIndex INT;
BEGIN
    IF listaCUP = '' THEN
        RAISE EXCEPTION 'Non ci sono CUP in input';
    END IF;

    separatoreIndex := STRPOS(listaCUP, ', '); --Se è 0 vuol dire che non c'è nessun ', ' ma almeno una parola -> C'è un solo CUP in listaCUP
    
    WHILE separatoreIndex <> 0
    LOOP
        singleCUP := SUBSTR(listaCUP, 1, separatoreIndex-1); --Isolo il CUP
        listaCUP := SUBSTR(listaCUP, separatoreIndex+2, LENGTH(listaCUP)); --Cancello il CUP e il ', ' dalla lista dei CUP

        UPDATE azienda.progetto
        SET Responsabile = matricola
        WHERE CUP = singleCUP;

        separatoreIndex := STRPOS(listaCUP, ', '); --Controllo l'esistenza (e ricalcolo la posizione) del prossimo ', '
    END LOOP;

    UPDATE azienda.progetto
    SET Responsabile = matricola
    WHERE CUP = listaCUP;

    RAISE NOTICE 'Ho sostituito il Responsabile dei progetti: % con la matricola "%"', copyListaCUP, matricola;
END;
$$
LANGUAGE plpgsql;