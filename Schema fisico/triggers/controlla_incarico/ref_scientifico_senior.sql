--REFERENTE SCIENTIFICO
--controlla se un dipendente assegnato come referente di un laboratorio è senior o meno
CREATE OR REPLACE FUNCTION azienda.fn_ref_scientifico_senior()
RETURNS TRIGGER
AS
$$
DECLARE
	dip_ind RECORD;
BEGIN
	SELECT Nome, Cognome, Matricola, Tipo, DataFine	INTO dip_ind
	FROM azienda.DIP_INDETERMINATO
	WHERE Matricola = NEW.Referente_Scientifico;
	
	IF dip_ind.Matricola IS NULL THEN

        RAISE EXCEPTION 'La matricola % non esiste', NEW.Referente_Scientifico;
    END IF;

	IF dip_ind.Tipo <> 'Senior' THEN

		RAISE EXCEPTION 'Il dipendente "% %" con matricola % non è di tipo "Senior"! Non è stato possibile assegnarlo come referente scientifico del progetto %', dip_ind.Nome, dip_ind.Cognome, dip_ind.Matricola, NEW.CUP;
	END IF;

	IF NEW.dataFine IS NULL THEN --Il progetto non è finito
		IF dip_ind.DataFine IS NOT NULL THEN
		    RAISE EXCEPTION 'Il dipendente "% %" con matricola % ha una data di licenziamento! Non è possibile assegnare l''incarico di Referente Scientifico al progetto %', dip_ind.Nome, dip_ind.Cognome, dip_ind.Matricola, NEW.CUP;
        END IF;

	ELSE --Il progetto è finito o conosciamo la dataFine
		IF dip_ind.DataFine IS NOT NULL AND dip_ind.DataFine < NEW.dataFine THEN --Se il dipendete che vogliamo inserire è stato licenziato, deve essere stato licenziato dopo la dataFine del progetto
			RAISE EXCEPTION 'Il dipendente "% %" con matricola % è stato licenziato prima della fine del progetto! Non è stato possibile assegnarlo come referente scientifico del progetto %', dip_ind.Nome, dip_ind.Cognome, dip_ind.Matricola, NEW.CUP;
		END IF;

	END IF;

	RETURN NEW;
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE TRIGGER tr_ref_scientifico_senior
BEFORE INSERT OR UPDATE OF Referente_Scientifico 
ON azienda.PROGETTO
FOR EACH ROW
EXECUTE FUNCTION azienda.fn_ref_scientifico_senior();