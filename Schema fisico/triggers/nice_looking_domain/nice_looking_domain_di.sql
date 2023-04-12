--Trigger che modifica all'inserimento il tipo nel formato corretto (esempio: jUniOR -> Junior)
--TIPO DIPENDENTE
CREATE OR REPLACE FUNCTION azienda.fn_nice_looking_domain_di() 
RETURNS trigger 
AS
$$
BEGIN
	NEW.tipo = CONCAT(UPPER(SUBSTR(NEW.tipo, 1, 1)), LOWER(SUBSTR(NEW.Tipo, 2, LENGTH(NEW.Tipo))));
	RETURN NEW;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER a_tr_nice_looking_domain_di
BEFORE INSERT OR UPDATE OF tipo ON azienda.DIP_INDETERMINATO
FOR EACH ROW
EXECUTE FUNCTION azienda.fn_nice_looking_domain_di();