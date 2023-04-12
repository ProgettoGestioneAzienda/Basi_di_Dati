--RESPONSABILE SCIENTIFICO
--controlla se un dipendente assegnato come responsabile scientifico di un progetto è senior o meno
CREATE OR REPLACE FUNCTION azienda.fn_res_scientifico_senior()
RETURNS trigger
AS
$$
DECLARE
	dip_ind RECORD;
BEGIN
	SELECT Nome, Cognome, Matricola, Tipo, DataFine INTO dip_ind
	FROM azienda.DIP_INDETERMINATO
	WHERE Matricola = NEW.Responsabile_Scientifico;
	
	IF dip_ind.Matricola IS NULL THEN
        RAISE EXCEPTION 'La matricola % non esiste', NEW.Responsabile_Scientifico;
    END IF;

	IF dip_ind.Tipo <> 'Senior' THEN
		RAISE EXCEPTION 'Il dipendente "% %" con matricola % non è di tipo "Senior"! Non può essere nominato Responsabile scientifico per il laboratorio %', dip_ind.Nome, dip_ind.Cognome, dip_ind.Matricola, NEW.Nome;
	END IF;
	
	IF dip_ind.DataFine IS NOT NULL THEN
		RAISE EXCEPTION 'Il dipendente "% %" con matricola % ha una data di licenziamento! Non è possibile assegnare l''incarico di Responsabile Scientifico del laboratorio %!', dip_ind.Nome, dip_ind.Cognome, dip_ind.Matricola, NEW.Nome;
	END IF;

	RETURN NEW;

END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tr_res_scientifico_senior
BEFORE INSERT OR UPDATE 
OF Responsabile_Scientifico ON azienda.LABORATORIO
FOR EACH ROW
EXECUTE FUNCTION azienda.fn_res_scientifico_senior();