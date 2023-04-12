--Trigger che impedisce qualsiasi modifica manuale a "costoAttrezzature" e "costoContrattiProgetto".
CREATE OR REPLACE FUNCTION azienda.fn_blocco_modifiche_costi() RETURNS trigger AS
$$
DECLARE
    half_budget azienda.EURO := (0.5 * NEW.Budget)-0.005;
BEGIN
    IF OLD.CostoAttrezzature IS NULL THEN --L'unico caso in cui può essere NULL è l'inserimento
        IF (NEW.costoAttrezzature <> 0 OR NEW.costoContrattiProgetto <> 0) THEN
            RAISE NOTICE E'Non puoi inserire manualmente il costo totale delle attrezzature o il costo totale dei contratti a progetto di %!\nBisogna comprare le attrezzature o i contratti relativi a questo progetto.\nL''inserimento a questi campi è stato ignorato', NEW.CUP;
            NEW.costoAttrezzature = 0;
            NEW.costoContrattiProgetto = 0;
        END IF;
    ELSE --Se non è l'inserimento, allora è un update
        IF (NEW.CostoAttrezzature <> OLD.costoAttrezzature OR NEW.costoContrattiProgetto <> OLD.costoContrattiProgetto) THEN 
            RAISE NOTICE E'Non puoi modificare manualmente il costo totale delle attrezzature o il costo totale dei contratti a progetto di %!\nBisogna modificare gli acquisti delle attrezzature o dei contratti relativi a questo progetto.\nLe modifiche di questi campi sono state ignorate', NEW.CUP;
            NEW.costoAttrezzature = OLD.costoAttrezzature;
            NEW.costoContrattiProgetto = OLD.costoContrattiProgetto;
        END IF;
    END IF;

    RETURN NEW;

END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tr_blocco_modifiche_costi
BEFORE INSERT OR UPDATE OF costoAttrezzature, costoContrattiProgetto ON azienda.PROGETTO
FOR EACH ROW
WHEN (pg_trigger_depth() < 1)
EXECUTE FUNCTION azienda.fn_blocco_modifiche_costi();