/*
La funzione viene eseguita dopo l'aggiornamento della data di fine di un dipendente e controlla se la data è antecedente alla data corrente. 
In tal caso, la funzione elimina tutte le afferenze correlate al dipendente nella tabella "AFFERIRE" e restituisce un messaggio di avviso. 
Altrimenti, la funzione restituisce un messaggio di avviso informando che le afferenze ai laboratori saranno mantenute.
*/

CREATE OR REPLACE FUNCTION azienda.fn_delete_dipInd_afferenze()
RETURNS TRIGGER
AS $$
BEGIN
    --se viene impostata una datafine per il dipendente precedente al momento in cui viene innescato il trigger, vengono eliminate le afferenze,
    --altrimenti verranno mantenute le afferenze sino la data specificata.

    IF NEW.dataFine <= DATE(NOW()) THEN
    --eliminazione di tutte le tuple correlate all'impiegato in AFFERIRE
        DELETE FROM azienda.AFFERIRE
        WHERE Matricola = OLD.Matricola;

        RAISE NOTICE 'Eliminate tutte le afferenze della matricola % non più attiva!', OLD.Matricola;
    ELSE
        RAISE NOTICE 'Siccome la dataFine inserita % è successiva rispetto la data corrente %, verranno mantenute tutte le afferenze ai laboratori.', NEW.dataFine, DATE(NOW());
    END IF;

    RETURN NEW;
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE TRIGGER tr_delete_dipInd_afferenze
AFTER UPDATE OF dataFine
ON azienda.DIP_INDETERMINATO
FOR EACH ROW
WHEN (OLD.dataFine IS DISTINCT FROM NEW.DataFine AND NEW.dataFine IS NOT NULL)
EXECUTE FUNCTION azienda.fn_delete_dipInd_afferenze();