--Trigger che verifica che non vi siano contratti già aperti per la persona con lo stesso codice fiscale
--nel caso venisse riassunto un dipendente
CREATE OR REPLACE FUNCTION azienda.fn_assunzione_coerente()
RETURNS Trigger
AS
$$
DECLARE
	cursore CURSOR FOR
		SELECT DI.Matricola, DI.codFiscale, DI.dataAssunzione, DI.dataFine
		FROM azienda.DIP_INDETERMINATO DI
		WHERE DI.codFiscale = NEW.codFiscale AND DI.matricola <> NEW.Matricola
		ORDER BY DI.dataAssunzione ASC;
		
	dip_ind RECORD;

	lista_contratti TEXT := ''; --Lista dei contratti che danno errore
BEGIN
	OPEN cursore;
	LOOP
		FETCH cursore INTO dip_ind;
		EXIT WHEN NOT FOUND;

		IF (((dip_ind.dataFine IS NULL) AND (dip_ind.Matricola <> NEW.Matricola)) OR --Non posso avere un contratto se ce n'è un altro aperto
		(dip_ind.dataAssunzione <= NEW.dataAssunzione AND NEW.dataAssunzione < dip_ind.dataFine) OR --Non posso avere un'assunzione nel bel mezzo di un altro contratto
		(dip_ind.dataAssunzione < NEW.dataFine AND NEW.dataFine <= dip_ind.dataFine) OR --Non posso essere licenziato nel bel mezzo di un altro contratto
		NEW.dataAssunzione < dip_ind.dataAssunzione AND NEW.dataFine > dip_ind.dataFine) THEN --Non posso avere un contratto che contiene un altro contratto
			lista_contratti := CONCAT(lista_contratti, dip_ind.Matricola || ', ');
		END IF;

	END LOOP;
	CLOSE cursore;

	IF lista_contratti <> '' THEN
		lista_contratti := SUBSTR(lista_contratti, 1, LENGTH(lista_contratti)-2);
		RAISE EXCEPTION 'Non è stato possibile stipulare il contratto con matricola % per %. La persona ha ancora un contratto in corso o vi è un conflitto tra la data di assunzione (o di fine) e i seguenti contratti: %', NEW.Matricola, NEW.codFiscale, lista_contratti;
	END IF;
	
	RETURN NEW;
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE TRIGGER c_tr_assunzione_coerente
BEFORE INSERT OR UPDATE OF codFiscale, dataAssunzione, dataFine
ON azienda.DIP_INDETERMINATO
FOR EACH ROW
EXECUTE FUNCTION azienda.fn_assunzione_coerente();