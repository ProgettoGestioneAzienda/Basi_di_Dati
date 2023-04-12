--verifica che ad un progetto non lavorino più di tre laboratori
--Il trigger utilizza una query per contare il numero di laboratori che lavorano a un progetto specifico. 
--Se il numero di laboratori che lavorano a un progetto supera o è uguale a tre, viene generato un messaggio di errore.

CREATE OR REPLACE FUNCTION azienda.fn_controllo_laboratori_progetto()
RETURNS trigger
AS
$$
DECLARE
	lavora_su RECORD;
	cup_exists RECORD;
	laboratorio_exists RECORD;
	numLabOnProg INTEGER := 0;
BEGIN
	SELECT * INTO cup_exists
	FROM azienda.PROGETTO 
	WHERE CUP = NEW.CUP;

	IF NOT FOUND THEN
		RAISE EXCEPTION 'Il progetto con CUP % non esiste', NEW.CUP;
	END IF;

	SELECT * INTO laboratorio_exists
	FROM azienda.LABORATORIO
	WHERE nome = NEW.nomeLab;

	IF NOT FOUND THEN
        RAISE EXCEPTION 'Il laboratorio % non esiste', NEW.nomeLab;
	END IF;

	SELECT * INTO lavora_su
	FROM azienda.LAVORARE
	WHERE CUP = NEW.CUP AND nomeLab = NEW.nomeLab;

	IF FOUND THEN
		RAISE EXCEPTION 'Il laboratorio % lavora già sul progetto con CUP %', NEW.nomeLab, NEW.CUP;
    END IF;

	SELECT COUNT(*) INTO numLabOnProg
	FROM azienda.LAVORARE
	WHERE CUP = NEW.CUP AND
		  nomeLab NOT IN
			(SELECT nomeLab
			 FROM azienda.LAVORARE
			 WHERE CUP = OLD.CUP AND nomeLab = OLD.nomeLab);

    --Se ci sono già 3 laboratori, non possono esserne aggiunti altri
	IF numLabOnProg >= 3 THEN

		RAISE EXCEPTION 'Non è possibile assegnare più di 3 laboratori ad un progetto! Il laboratorio % non può essere aggiunto al progetto %', NEW.nomeLab, NEW.CUP;
		--nel caso la condizione di controllo non venga soddisfatta, 
		--l'exception impedirà l'esecuzione del trigger.
	END IF;

	RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tr_controllo_laboratori_progetto
BEFORE INSERT OR UPDATE ON azienda.LAVORARE
FOR EACH ROW
EXECUTE FUNCTION azienda.fn_controllo_laboratori_progetto();