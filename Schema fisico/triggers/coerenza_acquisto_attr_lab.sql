/*
----------------------------------------------------------------------------------------------------
                                    tr_coerenza_acquisto_attr_lab

Si verifica che, prima di un inserimento di un'attrezzatura, oppure prima di un aggiornamento del laboratorio o del CUP per una data attrezzatura,
il nuovo laboratorio inserito lavori effettivamente per il nuovo progetto riportato
*/
CREATE OR REPLACE FUNCTION azienda.fn_coerenza_acquisto_attr_lab()
RETURNS TRIGGER
AS $$
DECLARE
    corrispondenze RECORD;
BEGIN

    --Si verifica che il laboratorio ed il progetto specificati esistano effettivamente
    --(questo viene fatto solo per personalizzare il messaggio di errore, dal punto di vista concettuale viene già verificato dal vincolo di integrità referenziale)
    IF NOT EXISTS (SELECT *
                   FROM azienda.LABORATORIO
                   WHERE nome = NEW.nomeLab) THEN
        RAISE EXCEPTION 'Il laboratorio % non esiste!', NEW.nomeLab;
    END IF;

    IF NOT EXISTS (SELECT *
                   FROM azienda.PROGETTO
                   WHERE CUP = NEW.CUP) THEN
        RAISE EXCEPTION 'Il progetto % non esiste!', NEW.CUP;
    END IF;

    IF NOT EXISTS (SELECT *
                   FROM azienda.LAVORARE
                   WHERE CUP = NEW.CUP AND nomeLab = NEW.nomeLab) THEN

        RAISE EXCEPTION 'Il laboratorio % non lavora per il progetto %, % non registrato come attrezzatura!', NEW.nomeLab, NEW.CUP, NEW.Descrizione;
    END IF;

    RETURN NEW;

END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE TRIGGER tr_coerenza_acquisto_attr_lab
BEFORE INSERT OR UPDATE OF nomeLab, CUP
ON azienda.ATTREZZATURA
FOR EACH ROW
EXECUTE FUNCTION azienda.fn_coerenza_acquisto_attr_lab();