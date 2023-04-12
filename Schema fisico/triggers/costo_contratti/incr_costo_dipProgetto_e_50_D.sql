--Trigger che calcola il costo dei contratti così che non superi il budget (si deve adattare ad un eventuale update del costo dei contratti)
--DELETE
CREATE OR REPLACE FUNCTION azienda.fn_incr_costo_dipProgetto_e_50_D() 
RETURNS TRIGGER 
AS
$$
DECLARE
	dati_progetto record;
BEGIN
	SELECT Budget, costoContrattiProgetto INTO dati_progetto
	FROM azienda.PROGETTO
	WHERE CUP = OLD.CUP;

	dati_progetto.costoContrattiProgetto = dati_progetto.costoContrattiProgetto - OLD.Costo;

	UPDATE azienda.PROGETTO AS PR
	SET costoContrattiProgetto = dati_progetto.costoContrattiProgetto
	WHERE PR.CUP = OLD.CUP;

	RETURN OLD;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tr_incr_costo_dipProgetto_e_50_D
AFTER DELETE ON azienda.DIP_PROGETTO
FOR EACH ROW
EXECUTE FUNCTION azienda.fn_incr_costo_dipProgetto_e_50_D();