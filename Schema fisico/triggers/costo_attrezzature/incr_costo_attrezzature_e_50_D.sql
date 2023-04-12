--Trigger che calcola il costo delle attrezzature così che non superi il budget (si deve adattare ad un eventuale update del costo delle attrezzature)
--DELETE
CREATE OR REPLACE FUNCTION azienda.fn_incr_costo_attrezzature_e_50_D() 
RETURNS TRIGGER 
AS
$$
DECLARE
	dati_progetto record;
BEGIN
	SELECT Budget, costoAttrezzature INTO dati_progetto
	FROM azienda.PROGETTO
	WHERE CUP = OLD.CUP;

	dati_progetto.CostoAttrezzature = dati_progetto.CostoAttrezzature - OLD.Costo;

	UPDATE azienda.PROGETTO AS PR
	SET costoAttrezzature = dati_progetto.CostoAttrezzature
	WHERE PR.CUP = OLD.CUP;

	RETURN OLD;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tr_incr_costo_attrezzature_e_50_D
AFTER DELETE ON azienda.ATTREZZATURA
FOR EACH ROW
EXECUTE FUNCTION azienda.fn_incr_costo_attrezzature_e_50_D();