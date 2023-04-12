-- Automatismo dell'inserimento dello scatto di carriera di un dipendente indeterminato
-- Ogni qual volta avviene uno scatto di carriera e quindi si modifica la relazione dip. a tempo indeterminato
-- si innesca un trigger che riporta nella relazione SCATTO_CARRIERA il relativo scatto al TIPO aggiornato

CREATE OR REPLACE FUNCTION azienda.fn_aggiorna_scatti_tipo() 
RETURNS trigger 
AS
$$
BEGIN
    IF OLD.Matricola IS NULL THEN --E' l'inserimento
        CALL azienda.check_scatto(NEW.Matricola, NEW.Tipo, NEW.dataAssunzione);
    ELSE --E' l'update
        --Serie di IF aggiunti nel caso, a seguito di modifiche alla dataAssunzione o dataFine, il dipendente risulti essere di tipo minore a quello precedente
        IF NEW.Tipo = 'Junior' AND (OLD.Tipo = 'Middle' OR OLD.Tipo = 'Senior') THEN --Sto passando da Middle o Senior a Junior
            DELETE FROM azienda.SCATTO_CARRIERA
            WHERE Matricola = NEW.Matricola AND (Tipo = 'Middle' OR Tipo = 'Senior'); --Elimino gli scatti superflui

        ELSIF NEW.Tipo = 'Middle' AND (OLD.Tipo = 'Senior') THEN --Sto passando da Senior a Junior
            DELETE FROM azienda.SCATTO_CARRIERA
            WHERE Matricola = NEW.Matricola AND Tipo = 'Senior'; --Elimino gli scatti superflui
        END IF;

        CALL azienda.check_scatto(NEW.Matricola, NEW.Tipo, NEW.dataAssunzione); --Se scatto in avanti aggiungo gli scatti mancanti
    END IF;
    
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER b_tr_aggiorna_scatti_tipo
AFTER INSERT OR UPDATE ON azienda.DIP_INDETERMINATO
FOR EACH ROW
EXECUTE FUNCTION azienda.fn_aggiorna_scatti_tipo();