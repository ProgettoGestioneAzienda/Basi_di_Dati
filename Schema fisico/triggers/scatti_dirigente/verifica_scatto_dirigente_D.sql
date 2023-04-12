-- Trigger che, se rimuovo lo scatto a dirigente, verifica che non si sia creata una ripetizione

CREATE OR REPLACE FUNCTION azienda.fn_verifica_scatto_dirigente_D() RETURNS trigger AS
$$
DECLARE
    --Prendo tutti gli scatti della vecchia matricola
    cursore_vecchia_matricola CURSOR FOR 
        SELECT Tipo, Data
        FROM azienda.scatto_carriera
        WHERE Matricola = OLD.Matricola AND (Tipo = 'Rimosso da dirigente' OR Tipo = 'Promosso a dirigente')
        ORDER BY Data ASC; --Le tuple andranno da quella più lontana a quella più vicina a oggi;

    scatto_attuale RECORD;
    scatto_precedente RECORD;
BEGIN
    --Verifico che ci sia ancora coerenza tra gli scatti della vecchia matricola
    OPEN cursore_vecchia_matricola;
    FETCH cursore_vecchia_matricola INTO scatto_precedente;

    IF FOUND THEN
        IF scatto_precedente.Tipo <> 'Promosso a dirigente' THEN
            RAISE EXCEPTION 'Eliminando lo scatto di %, il primo scatto risulta essere "Rimosso da dirigente"', OLD.Matricola;
        END IF;

        LOOP
            FETCH cursore_vecchia_matricola INTO scatto_attuale;
            EXIT WHEN NOT FOUND;

            IF scatto_precedente.Tipo = scatto_attuale.Tipo THEN --Verifico la coerenza negli scatti rimanenti
                RAISE EXCEPTION 'Lo scatto in data % è uguale a quello in data % per la matricola %', scatto_precedente.Data, scatto_attuale.Data, OLD.Matricola;
            END IF;

            scatto_precedente = scatto_attuale; --Aggiorno gli scatti da confrontare
        END LOOP;
    END IF;
    CLOSE cursore_vecchia_matricola;

    RETURN OLD;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER a_tr_verifica_scatto_dirigente_D
AFTER DELETE ON azienda.SCATTO_CARRIERA
FOR EACH ROW
WHEN (OLD.Tipo = 'Rimosso da dirigente' OR OLD.Tipo = 'Promosso a dirigente')
EXECUTE FUNCTION azienda.fn_verifica_scatto_dirigente_D();