/*
Si vuole impedire la modifica diretta del campo "nAfferenti" nella tabella "azienda.LABORATORIO".
Per farlo, è stato creato un trigger che si attiva prima dell'aggiornamento del campo "nAfferenti". 
In questo modo, se si cerca di modificare direttamente il campo "nAfferenti", il trigger viene attivato automaticamente, evitando così la modifica diretta del campo.
La funzione "pg_trigger_depth()" viene utilizzata per controllare se il trigger è stato attivato. 
Se la funzione restituisce un valore maggiore di 0, significa che il trigger è stato attivato e quindi la modifica è stata effettuata in modo corretto. 
In caso contrario, se la funzione restituisce 0, significa che la modifica è stata effettuata direttamente sulla tabella senza attivare il trigger, e quindi la modifica viene impedita.
*/

CREATE OR REPLACE FUNCTION azienda.fn_blocco_nAfferenti()
RETURNS TRIGGER
AS $$
BEGIN

    IF OLD.nome IS NULL THEN --Inserimento
        IF NEW.nAfferenti <> 1 THEN
            RAISE NOTICE 'Non è possibile inserire direttamente il numero di afferenti al laboratorio %!', NEW.nome;
            NEW.nAfferenti = 1;
        END IF;
    ELSE --Update
        IF NEW.nAfferenti <> OLD.nAfferenti THEN
            RAISE NOTICE 'Non è possibile modificare direttamente il numero di afferenti al laboratorio %!', NEW.nome;
            NEW.nAfferenti = OLD.nAfferenti;
        END IF;

    END IF;

    RETURN NEW;
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE TRIGGER tr_blocco_nAfferenti
BEFORE INSERT OR UPDATE OF nAfferenti
ON azienda.LABORATORIO
FOR EACH ROW
WHEN (pg_trigger_depth() < 1)
EXECUTE FUNCTION azienda.fn_blocco_nAfferenti();