--Trigger che verifica la correttezza degli scatti a Middle e a Senior rispetto alla data di assunzione e al tipo del dipendente

CREATE OR REPLACE FUNCTION azienda.fn_verifica_scatto_tipo_IU() RETURNS trigger AS
$$
DECLARE
    dati_matricola RECORD;
BEGIN
    SELECT Tipo, dataAssunzione INTO dati_matricola
    FROM azienda.dip_indeterminato
    WHERE Matricola = NEW.Matricola;

    --Non posso registrare lo scatto di una matricola che non esiste
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Matricola % non esistente', NEW.Matricola;
    END IF;

    --Non posso registrare lo scatto a Middle di una matricola Junior
    IF NEW.Tipo = 'Middle' AND dati_matricola.Tipo = 'Junior' THEN
        RAISE EXCEPTION 'La matricola % è "Junior"! Impossibile registrare lo scatto da "Junior" a "Middle"', NEW.Matricola;
    END IF;

    --Non posso registrare lo scatto a Middle con una data sbagliata
    IF NEW.Tipo = 'Middle' AND NEW.Data <> CAST(dati_matricola.dataAssunzione + interval '3 years' AS DATE) THEN
        RAISE EXCEPTION 'Per la matricola %, lo scatto da "Junior" a "Middle" deve essere in data %!', NEW.Matricola, CAST(dati_matricola.dataAssunzione + interval '3 years' AS DATE);
    END IF;

    --Non posso registrare lo scatto a Senior di una matricola Middle o Junior
    IF NEW.Tipo = 'Senior' AND (dati_matricola.Tipo = 'Middle' OR dati_matricola.Tipo = 'Junior') THEN
        RAISE EXCEPTION 'La matricola % è "Middle"! Impossibile registrare lo scatto da "Middle" a "Senior"', NEW.Matricola;
    END IF;

    --Non posso registrare lo scatto a Senior con una data sbagliata
    IF NEW.Tipo = 'Senior' AND NEW.Data <> CAST(dati_matricola.dataAssunzione + interval '7 years' AS DATE) THEN
        RAISE EXCEPTION 'Per la matricola %, lo scatto da "Middle" a "Senior" deve essere in data %!', NEW.Matricola, CAST(dati_matricola.dataAssunzione + interval '7 years' AS DATE);
    END IF;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER b_tr_verifica_scatto_tipo_IU
BEFORE INSERT OR UPDATE ON azienda.SCATTO_CARRIERA
FOR EACH ROW
WHEN (NEW.Tipo = 'Middle' OR NEW.Tipo = 'Senior')
EXECUTE FUNCTION azienda.fn_verifica_scatto_tipo_IU();

/* 
All'interno del trigger, non è necessario controllare che la data dello scatto sia compresa tra la data di assunzione e la data di fine del dipendente. 
Questo perché, nel contesto specifico in cui il trigger viene utilizzato, la data esatta in cui avverrà lo scatto è già nota e verrà inserita nel database in modo accurato.
Inoltre, è possibile garantire che la matricola sia del tipo corretto grazie al controllo effettuato in fase di inserimento del dipendente. 
Analogamente, è già stata verificata la correttezza della data dello scatto grazie ad un altro trigger (verifica_tipo).
*/