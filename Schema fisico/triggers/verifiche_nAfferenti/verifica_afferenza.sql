/*
Il trigger intende verificare che una matricola esista, che il laboratorio esista, che la matricola sia attiva
e che non si stia andando ad aggiungere un'afferenza di un dipendente in dirittura di licenziamento
*/

CREATE OR REPLACE FUNCTION azienda.fn_verifica_afferenza()
RETURNS TRIGGER
AS $$
BEGIN
    --Si verifica che la matricola ed il laboratorio specificati esistano effettivamente
    --(questo viene fatto solo per personalizzare il messaggio di errore, dal punto di vista concettuale viene già verificato dal vincolo di integrità referenziale)
    IF NOT EXISTS (SELECT * FROM azienda.DIP_INDETERMINATO WHERE Matricola = NEW.Matricola) THEN
        RAISE EXCEPTION 'La matricola % non esiste!', NEW.Matricola;
    END IF;

    IF NOT EXISTS (SELECT * FROM azienda.LABORATORIO WHERE nome = NEW.nomeLab) THEN
        RAISE EXCEPTION 'Il laboratorio % non esiste!', NEW.nomeLab;
    END IF;

    --Si verifica che il dipendente a tempo indeterminato non presenti una dataFine, ovvero che sia ancora attivo nell'azienda
    IF (SELECT dataFine
        FROM azienda.DIP_INDETERMINATO
        WHERE Matricola = NEW.Matricola) IS NOT NULL THEN

        RAISE EXCEPTION 'La matricola % ha una data di licenziamento! Non è possibile assegnare la nuova afferenza al laboratorio %.', NEW.Matricola, NEW.nomeLab;
    END IF;

    RETURN NEW;
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE TRIGGER tr_verifica_afferenza
BEFORE INSERT ON azienda.AFFERIRE
FOR EACH ROW
EXECUTE FUNCTION azienda.fn_verifica_afferenza();