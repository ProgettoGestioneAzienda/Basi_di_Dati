--RESPONSABILE (Progetto)
--controlla se un dipendente assegnato come responsabile di un progetto è un dirigente o meno
CREATE OR REPLACE FUNCTION azienda.fn_res_progetto_dirigente()
RETURNS trigger
AS
$$
DECLARE
	dip_ind RECORD;
BEGIN
	SELECT Nome, Cognome, Matricola, Dirigente, DataFine INTO dip_ind
	FROM azienda.DIP_INDETERMINATO
	WHERE Matricola = NEW.Responsabile;
	
	IF dip_ind.Matricola IS NULL THEN
        RAISE EXCEPTION 'La matricola % non esiste', NEW.Responsabile;
    END IF;

	IF dip_ind.Dirigente <> TRUE THEN
		RAISE EXCEPTION 'Il dipendente "% %" con matricola % non è "Dirigente"! Non è stato possibile assegnarlo come responsabile del progetto %', dip_ind.Nome, dip_ind.Cognome, dip_ind.Matricola, NEW.CUP;
	END IF;

	IF NEW.dataFine IS NULL THEN --Il progetto non è finito
		IF dip_ind.DataFine IS NOT NULL THEN
		    RAISE EXCEPTION 'Il dipendente "% %" con matricola % ha una data di licenziamento! Non è possibile assegnare l''incarico di Responsabile al progetto %', dip_ind.Nome, dip_ind.Cognome, dip_ind.Matricola, NEW.CUP;
        END IF;
	
	ELSE --Il progetto è finito o conosciamo la dataFine
		IF dip_ind.DataFine IS NOT NULL AND dip_ind.DataFine < NEW.dataFine THEN --Se il dipendete che vogliamo inserire è stato licenziato, deve essere stato licenziato dopo la dataFine del progetto
			RAISE EXCEPTION 'Il dipendente "% %" con matricola % è stato licenziato prima della fine del progetto! Non è stato possibile assegnarlo come responsabile del progetto %', dip_ind.Nome, dip_ind.Cognome, dip_ind.Matricola, NEW.CUP;
		END IF;

	END IF;

	RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tr_res_progetto_dirigente
BEFORE INSERT OR UPDATE OF Responsabile
ON azienda.PROGETTO
FOR EACH ROW
EXECUTE FUNCTION azienda.fn_res_progetto_dirigente();