--Trigger che calcola il costo delle attrezzature così che non superi il budget (si deve adattare ad un eventuale update del costo delle attrezzature)
--UPDATE
CREATE OR REPLACE FUNCTION azienda.fn_incr_costo_attrezzature_e_50_U() 
RETURNS TRIGGER 
AS
$$
DECLARE
	dati_progetto record;
	half_budget azienda.EURO := 0;
BEGIN
	SELECT Budget, costoAttrezzature INTO dati_progetto
	FROM azienda.PROGETTO
	WHERE CUP = NEW.CUP;

	dati_progetto.CostoAttrezzature = dati_progetto.CostoAttrezzature + NEW.Costo;
	IF OLD.CUP = NEW.CUP THEN --Se l'attrezzatura è sempre dello stesso progetto, devo aggiornare il valore totale
		dati_progetto.CostoAttrezzature = dati_progetto.CostoAttrezzature - OLD.Costo;
	END IF;

	half_budget := (0.5 * dati_progetto.Budget)-0.005;

	IF half_budget >= dati_progetto.CostoAttrezzature THEN

		--Aggiorno il costo delle attrezzature per il progetto
		UPDATE azienda.PROGETTO AS PR
		SET costoAttrezzature = dati_progetto.CostoAttrezzature
		WHERE PR.CUP = NEW.CUP;

		IF OLD.CUP <> NEW.CUP THEN --Se ho cambiato il CUP vuol dire che il costo dell'attrezzatura non contribuisce più al costo totale del progetto precedente
			UPDATE azienda.PROGETTO AS PR
			SET costoAttrezzature = costoAttrezzature - OLD.Costo
			WHERE PR.CUP = OLD.CUP;
		END IF;

	ELSE
		RAISE EXCEPTION 'Il costo totale delle attrezzature, ovvero €%, sfora il 50%% del budget (€%)! L''attrezzatura "%" non è stata acquistata per il progetto %', dati_progetto.CostoAttrezzature, half_budget, NEW.Descrizione, NEW.CUP;
	END IF;

	RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tr_incr_costo_attrezzature_e_50_U
BEFORE UPDATE ON azienda.ATTREZZATURA
FOR EACH ROW
EXECUTE FUNCTION azienda.fn_incr_costo_attrezzature_e_50_U();