--Trigger che calcola il costo dei contratti così che non superi il budget (si deve adattare ad un eventuale update del costo dei contratti)
--INSERIMENTO
CREATE OR REPLACE FUNCTION azienda.fn_incr_costo_dipProgetto_e_50_I() 
RETURNS TRIGGER 
AS
$$
DECLARE
	dati_progetto record;
	half_budget azienda.EURO := 0;
BEGIN
	SELECT Budget, costoContrattiProgetto INTO dati_progetto
	FROM azienda.PROGETTO
	WHERE CUP = NEW.CUP;

	dati_progetto.costoContrattiProgetto = dati_progetto.costoContrattiProgetto + NEW.Costo;

	half_budget := (0.5 * dati_progetto.Budget)-0.005;

	IF half_budget >= dati_progetto.costoContrattiProgetto THEN

		UPDATE azienda.PROGETTO AS PR
		SET costoContrattiProgetto = dati_progetto.costoContrattiProgetto
		WHERE PR.CUP = NEW.CUP;

	ELSE
		RAISE EXCEPTION 'Il costo totale dei contratti a progetto, ovvero €%, sfora il 50%% del budget (€%)! Il contratto % è stato annullato per il progetto %', dati_progetto.costoContrattiProgetto, half_budget, NEW.Matricola, NEW.CUP;
	END IF;
	
	RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tr_incr_costo_dipProgetto_e_50_I
BEFORE INSERT ON azienda.DIP_PROGETTO
FOR EACH ROW
EXECUTE FUNCTION azienda.fn_incr_costo_dipProgetto_e_50_I();