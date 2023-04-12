--Trigger che modifica all'inserimento il tipo dello scatto nel formato corretto (esempio: jUniOR -> Junior)
--SCATTO CARRIERA
CREATE OR REPLACE FUNCTION azienda.fn_nice_looking_domain_sc() 
RETURNS trigger 
AS
$$
BEGIN
	NEW.tipo = CONCAT(UPPER(SUBSTR(NEW.tipo, 1, 1)), LOWER(SUBSTR(NEW.Tipo, 2, LENGTH(NEW.Tipo))));
	RETURN NEW;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER a_tr_nice_looking_domain_sc
BEFORE INSERT OR UPDATE OF tipo ON azienda.SCATTO_CARRIERA
FOR EACH ROW
EXECUTE FUNCTION azienda.fn_nice_looking_domain_sc();