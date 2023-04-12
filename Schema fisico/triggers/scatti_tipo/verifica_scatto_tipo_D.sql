--Trigger che verifica la correttezza degli scatti a Middle e a Senior rispetto alla data di assunzione e al tipo del dipendente

CREATE OR REPLACE FUNCTION azienda.fn_verifica_scatto_tipo_D() RETURNS trigger AS
$$
DECLARE
    dati_matricola RECORD;
    numero_anni_trascorsi INTEGER := 0;
BEGIN
    SELECT Tipo INTO dati_matricola
    FROM azienda.dip_indeterminato
    WHERE Matricola = OLD.Matricola;

    --Non posso eliminare lo scatto a Senior di una matricola Senior
    IF OLD.Tipo = 'Senior' AND dati_matricola.Tipo = 'Senior' THEN
        RAISE EXCEPTION 'La matricola % è "Senior"! Impossibile eliminare lo scatto da "Middle" a "Senior"', OLD.Matricola;
    END IF;

    --Non posso eliminare lo scatto a Middle di una matricola Middle o Senior
    IF OLD.Tipo = 'Middle' AND (dati_matricola.Tipo = 'Middle' OR dati_matricola.Tipo = 'Senior') THEN
        RAISE EXCEPTION 'La matricola % è "%"! Impossibile eliminare lo scatto da "Junior" a "Middle"', OLD.Matricola, dati_matricola.Tipo;
    END IF;

    RETURN OLD;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER b_tr_verifica_scatto_tipo_D
BEFORE DELETE ON azienda.SCATTO_CARRIERA
FOR EACH ROW
WHEN (OLD.Tipo = 'Middle' OR OLD.Tipo = 'Senior')
EXECUTE FUNCTION azienda.fn_verifica_scatto_tipo_D();