/*
Si verifica che, prima di un inserimento di un dipendente a progetto, oppure prima di un aggiornamento della data di scadenza contratto di un dipendente a progetto,
quest'ultima, in base al progetto vincolato al contratto, sia compresa tra la data di inzio del progetto e la data di fine di quest'ultimo 
*/

CREATE OR REPLACE FUNCTION azienda.fn_verifica_dipProg()
RETURNS TRIGGER
AS $$
DECLARE
    dati_progetto RECORD;
BEGIN
    SELECT dataInizio, dataFine
    INTO dati_progetto
    FROM azienda.PROGETTO
    WHERE CUP = NEW.CUP;

    IF NEW.Scadenza < dati_progetto.dataInizio OR NEW.Scadenza > dati_progetto.dataFine THEN
        RAISE EXCEPTION 'La data di scadenza del dipendente a progetto % non è compresa tra %(inizio progetto) e %(fine progetto)!', NEW.Matricola, dati_progetto.dataInizio, dati_progetto.dataFine;
    END IF;

    RETURN NEW; 
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE TRIGGER tr_verifica_dipProg
BEFORE INSERT OR UPDATE OF Scadenza
ON azienda.DIP_PROGETTO
FOR EACH ROW
EXECUTE FUNCTION azienda.fn_verifica_dipProg();