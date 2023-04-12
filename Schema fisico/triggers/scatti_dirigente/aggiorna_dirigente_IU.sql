--Trigger che aggiorna lo stato dirigenziale di un dipendente sulla base dello scatto più recente

CREATE OR REPLACE FUNCTION azienda.fn_aggiorna_dirigente_IU() RETURNS TRIGGER AS $$
DECLARE
    tipo_matricola azienda.scatto_carriera.tipo%TYPE;
    dirigente_matricola azienda.dip_indeterminato.Dirigente%TYPE;
BEGIN
    --Aggiorno la dirigenza della vecchia matricola
    IF OLD.Matricola IS NOT NULL AND NEW.Matricola <> OLD.Matricola THEN --Update su Matricola

        SELECT Dirigente INTO dirigente_matricola --Prendo l'attuale stato dirigenziale della vecchia matricola
        FROM azienda.dip_indeterminato
        WHERE Matricola = OLD.Matricola;

        SELECT Tipo INTO tipo_matricola --Prendo l'ultimo scatto dirigenziale della vecchia matricola
        FROM azienda.scatto_carriera
        WHERE Matricola = OLD.Matricola AND 
              (Tipo = 'Promosso a dirigente' OR Tipo = 'Rimosso da dirigente')
        ORDER BY Data DESC
        LIMIT 1;

        IF NOT FOUND THEN --Non ho più lo scatto a dirigente per la vecchia matricola, quindi deve tornare a DEFAULT, cioè FALSE
            UPDATE azienda.dip_indetermianto
            SET Dirigente = FALSE
            WHERE Matricola = OLD.Matricola;
        ELSE --Verifico che ci sia coerenza, altrimenti aggiorno
            IF tipo_matricola = 'Promosso a dirigente' THEN
                IF dirigente_matricola = FALSE THEN
                    UPDATE azienda.dip_indeterminato
                    SET Dirigente = TRUE
                    WHERE matricola = OLD.Matricola;
                END IF;
            ELSE
                IF dirigente_matricola = TRUE THEN
                    UPDATE azienda.dip_indeterminato
                    SET Dirigente = FALSE
                    WHERE matricola = OLD.Matricola;
                END IF;
            END IF;
        END IF;
    END IF;



    --Devo verificare che l'attuale stato dirigenziale della nuova matricola è aggiornato, altrimenti aggiorna
    SELECT Tipo INTO tipo_matricola --Prendo l'ultimo scatto dirigenziale della nuova matricola
    FROM azienda.scatto_carriera
    WHERE Matricola = NEW.Matricola AND 
            (Tipo = 'Promosso a dirigente' OR Tipo = 'Rimosso da dirigente')
    ORDER BY Data DESC
    LIMIT 1;

    SELECT Dirigente INTO dirigente_matricola --Prendo l'attuale stato dirigenziale della nuova matricola
    FROM azienda.dip_indeterminato
    WHERE Matricola = NEW.Matricola;

    --Verifico che ci sia coerenza, altrimenti aggiorno
    IF tipo_matricola = 'Promosso a dirigente' THEN
        IF dirigente_matricola = FALSE THEN
            UPDATE azienda.dip_indeterminato
            SET Dirigente = TRUE
            WHERE matricola = NEW.Matricola;
        END IF;
    ELSE
        IF dirigente_matricola = TRUE THEN
            UPDATE azienda.dip_indeterminato
            SET Dirigente = FALSE
            WHERE matricola = NEW.Matricola;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql; 
 
CREATE OR REPLACE TRIGGER b_tr_aggiorna_dirigente_IU
AFTER INSERT OR UPDATE ON azienda.SCATTO_CARRIERA
FOR EACH ROW 
WHEN (NEW.Tipo IN ('Promosso a dirigente', 'Rimosso da dirigente')) 
EXECUTE FUNCTION azienda.fn_aggiorna_dirigente_IU();