--Trigger che impedisce qualsiasi modifica manuale a "Dirigente" in dip_indetetrminato

CREATE OR REPLACE FUNCTION azienda.fn_blocco_modifica_dirigente() RETURNS trigger AS
$$
BEGIN
    IF OLD.Matricola IS NULL THEN --L'unico caso in cui può essere NULL è l'inserimento
        IF (NEW.Dirigente <> FALSE) THEN
            RAISE NOTICE E'Non puoi inserire manualmente lo stato dirigenziale del dipendete %. E'' necessario inserire l''apposito scatto in "azienda.scatto_carriera"', NEW.Matricola;
            NEW.Dirigente = FALSE;
        END IF;
    ELSE --Se non è l'inserimento, allora è un update
        IF (NEW.Dirigente <> OLD.Dirigente) THEN 
            RAISE NOTICE E'Non puoi inserire manualmente lo stato dirigenziale del dipendete %. E'' necessario inserire l''apposito scatto in "azienda.scatto_carriera"', NEW.Matricola;
            NEW.Dirigente = OLD.Dirigente;
        END IF;
    END IF;

    RETURN NEW;

END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tr_blocco_modifica_dirigente
BEFORE INSERT OR UPDATE OF Dirigente ON azienda.DIP_INDETERMINATO
FOR EACH ROW
WHEN (pg_trigger_depth() < 1)
EXECUTE FUNCTION azienda.fn_blocco_modifica_dirigente();