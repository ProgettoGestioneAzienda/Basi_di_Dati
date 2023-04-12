-- Trigger che, se inserisco lo scatto a dirigente, verifica che non sia una ripetizione
-- e che gli scatti della vecchia matricola (nel caso dell'update) siano ancora coerenti

CREATE OR REPLACE FUNCTION azienda.fn_verifica_scatto_dirigente_IU() RETURNS trigger AS
$$
DECLARE
    --Prendo tutti gli scatti della nuova matricola, escludendo la tupla appena modificata
    cursore_nuova_matricola CURSOR FOR
        SELECT Tipo, Data
        FROM azienda.scatto_carriera
        WHERE Matricola = NEW.Matricola AND (Tipo = 'Rimosso da dirigente' OR Tipo = 'Promosso a dirigente')
		ORDER BY Data ASC; --Le tuple andranno da quella più lontana a quella più vicina a oggi;


    --Prendo tutti gli scatti della vecchia matricola, escludendo anche quello che verrà modificato (o eliminato)
    cursore_vecchia_matricola CURSOR FOR 
        SELECT Tipo, Data
        FROM azienda.scatto_carriera
        WHERE Matricola = OLD.Matricola AND (Tipo = 'Rimosso da dirigente' OR Tipo = 'Promosso a dirigente')
		ORDER BY Data ASC; --Le tuple andranno da quella più lontana a quella più vicina a oggi;

    scatto_attuale RECORD;
    scatto_precedente RECORD;

    dati_matricola RECORD;
    looped BOOLEAN := FALSE;
BEGIN
    SELECT dataAssunzione, dataFine, Dirigente INTO dati_matricola
    FROM azienda.dip_indeterminato
    WHERE Matricola = NEW.Matricola;


    --Non posso registrare lo scatto di una matricola che non esiste
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Matricola % non esistente', NEW.Matricola;
    END IF;


    --Update su Matricola
    IF OLD.Matricola IS NOT NULL AND NEW.Matricola <> OLD.Matricola THEN
        OPEN cursore_vecchia_matricola;
        FETCH cursore_vecchia_matricola INTO scatto_precedente;

        IF FOUND THEN --Mi è rimasto almeno uno scatto. Verifico che il primo sia "Promosso a dirigente"
            IF scatto_precedente.Tipo <> 'Promosso a dirigente' THEN
                RAISE EXCEPTION 'Cambiando lo scatto di %, il primo scatto risulta essere "Rimosso da dirigente"', OLD.Matricola;
            END IF;

            LOOP
                FETCH cursore_vecchia_matricola INTO scatto_attuale;
                EXIT WHEN NOT FOUND;

                IF scatto_precedente.Tipo = scatto_attuale.Tipo THEN --Verifico la coerenza negli scatti rimanenti
                    RAISE EXCEPTION 'Lo scatto in data % è uguale a quello in data % per la matricola %', scatto_precedente.Data, scatto_attuale.Tipo, OLD.Matricola;
                END IF;

                scatto_precedente = scatto_attuale; --Aggiorno gli scatti da confrontare
            END LOOP;
        END IF;
        CLOSE cursore_vecchia_matricola;
    END IF;


    --Non posso registrare lo scatto di un dipendente fuori servizio
    IF dati_matricola.dataFine IS NULL THEN
        IF NEW.Data < dati_matricola.dataAssunzione THEN
            RAISE EXCEPTION 'La matricola % non può essere dirigente (o essere rimosso da dirigente) prima di essere assunta!', NEW.Matricola;
        END IF;
    ELSE
        IF NEW.Data < dati_matricola.dataAssunzione OR NEW.Data > dati_matricola.dataFine THEN
            RAISE EXCEPTION 'La matricola % non può essere dirigente (o essere rimosso da dirigente) fuori dal suo periodo di servizio!', NEW.Matricola;
        END IF;
    END IF;


    --Verifica la coerenza nell'alternanza degli scatti
    OPEN cursore_nuova_matricola;
    FETCH cursore_nuova_matricola INTO scatto_precedente;

    --Il primo scatto e DEVE essere per forza "Promosso a dirigente"
    IF scatto_precedente.Tipo <> 'Promosso a dirigente' THEN
        RAISE EXCEPTION 'Il dipendente % non può avere come primo scatto "Rimosso da dirigente"!', NEW.Matricola;
    END IF;
    
    LOOP --Verifico che ci siano altri scatti
        FETCH cursore_nuova_matricola INTO scatto_attuale; --Lo scatto successivo sarà più recente di quello già preso
        EXIT WHEN NOT FOUND;

        --Devo verificare che sia verificata l'alternanza tra scatti. Essendo le tuple ordinate asc, scatto_precedente.Data < scatto_attuale.Data
        IF scatto_precedente.Tipo = scatto_attuale.Tipo THEN
            RAISE EXCEPTION 'Lo scatto in data % è uguale a quello in data % per la matricola %', scatto_precedente.Data, scatto_attuale.Data, NEW.Matricola;
        ELSIF scatto_precedente.Data = scatto_attuale.Data THEN
            RAISE EXCEPTION 'Il dipendente % ha due scatti dirigenziali in data %', NEW.Matricola, scatto_precedente.Data;
        END IF;

        scatto_precedente = scatto_attuale; --Aggiorno gli scatti da confrontare
    END LOOP;
    CLOSE cursore_nuova_matricola;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER a_tr_verifica_scatto_dirigente_IU
AFTER INSERT OR UPDATE ON azienda.SCATTO_CARRIERA
FOR EACH ROW
WHEN (NEW.Tipo = 'Rimosso da dirigente' OR NEW.Tipo = 'Promosso a dirigente')
EXECUTE FUNCTION azienda.fn_verifica_scatto_dirigente_IU();