--Trigger che calcola il costo dei contratti così che non superi il budget (si deve adattare ad un eventuale update del costo dei contratti)
--UPDATE
CREATE OR REPLACE FUNCTION azienda.fn_incr_costo_dipProgetto_e_50_U() 
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
	IF OLD.CUP = NEW.CUP THEN --Se il contratto è sempre dello stesso progetto, devo aggiornare il valore totale
		dati_progetto.costoContrattiProgetto = dati_progetto.costoContrattiProgetto - OLD.Costo;
	END IF;

	half_budget := (0.5 * dati_progetto.Budget)-0.005;

	IF half_budget >= dati_progetto.costoContrattiProgetto THEN

		--Aggiorno il costo dei contratti per il progetto
		UPDATE azienda.PROGETTO AS PR
		SET costoContrattiProgetto = dati_progetto.costoContrattiProgetto
		WHERE PR.CUP = NEW.CUP;

		IF OLD.CUP <> NEW.CUP THEN --Se ho cambiato il CUP vuol dire che il costo del contratto non contribuisce più al costo totale del progetto precedente
			UPDATE azienda.PROGETTO AS PR
			SET costoContrattiProgetto = costoContrattiProgetto - OLD.Costo
			WHERE PR.CUP = OLD.CUP;
		END IF;
		
	ELSE
		RAISE EXCEPTION 'Il costo totale dei contratti a progetto, ovvero €%, sfora il 50%% del budget (€%)! Il contratto % è stato annullato per il progetto %', dati_progetto.costoContrattiProgetto, half_budget, NEW.Matricola, NEW.CUP;
	END IF;

	RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tr_incr_costo_dipProgetto_e_50_U
BEFORE UPDATE ON azienda.DIP_PROGETTO
FOR EACH ROW
EXECUTE FUNCTION azienda.fn_incr_costo_dipProgetto_e_50_U();