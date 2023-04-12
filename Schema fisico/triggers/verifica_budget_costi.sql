--Trigger che impedisce la modifica del Budget tale da rendere illegale l'attuale costoAttrezzature o costoContrattiProgetto
CREATE OR REPLACE FUNCTION azienda.fn_verifica_budget_costi() RETURNS trigger AS
$$
DECLARE
    half_budget azienda.EURO := (0.5 * NEW.Budget)-0.005;
BEGIN
    IF ((half_budget < NEW.CostoAttrezzature) OR (half_budget < NEW.costoContrattiProgetto)) THEN
        RAISE EXCEPTION 'Non è stato possibile modificare il Budget da % a % perchè attualmente per il progetto % vi è una spesa in attrezzature o contratti a progetto superiore a % (il 50%% di %)! Modifica rifiutata.', OLD.Budget, NEW.Budget, NEW.CUP, half_budget, NEW.Budget;
    END IF;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tr_verifica_budget_costi
BEFORE UPDATE OF Budget ON azienda.PROGETTO
FOR EACH ROW
EXECUTE FUNCTION azienda.fn_verifica_budget_costi();