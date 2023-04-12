/*
Si intende verificare, dopo che è stata registrata l'afferenza di una matricola ad un laboratorio, che, per scopi di coerenza con il corrispettivo nAfferenti del laboratorio,
la matricola non sia il responsabile scientifico del laboratorio in questione. Se così fosse, si lascia inalterato in nAfferenti di quel laboratorio, poichè già contato di DEFAULT.
*/

CREATE OR REPLACE FUNCTION azienda.fn_change_nAfferenti_I()
RETURNS TRIGGER
AS $$
BEGIN

    --controlliamo se la matricola appena inserita è responsabile scientifico del laboratorio appena inserito
    IF NEW.Matricola = (SELECT Responsabile_scientifico FROM azienda.LABORATORIO WHERE nome = NEW.nomeLab) THEN
        RAISE NOTICE 'L''afferenza del Responsabile Scientifico % di % è già conteggiata!', NEW.Matricola, NEW.nomeLab;
    ELSE
        --nel caso sia stata inserita una coppia (laboratorio, matricola) dove la matricola non è responsabile scientifico del laboratorio
        --incrementa il numero di afferenti di 1 di quel laboratorio
        UPDATE azienda.LABORATORIO
        SET nAfferenti = nAfferenti + 1
        WHERE nome = NEW.nomeLab;

        RAISE NOTICE 'Incrementato di 1 il numero di afferenti del laboratorio %!', NEW.nomeLab;
    END IF;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tr_change_nAfferenti_I
AFTER INSERT
ON azienda.AFFERIRE
FOR EACH ROW
EXECUTE FUNCTION azienda.fn_change_nAfferenti_I();