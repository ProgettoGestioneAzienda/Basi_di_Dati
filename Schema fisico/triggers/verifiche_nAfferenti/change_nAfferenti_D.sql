/*
Si intende verificare che, ogni qual volta viene effettuata una rimozione di una afferenza per un determinato laboratorio, il numero di afferenti
del laboratorio venga decrementato.
*/

CREATE OR REPLACE FUNCTION azienda.fn_change_nAfferenti_D()
RETURNS TRIGGER
AS $$
BEGIN

    UPDATE azienda.LABORATORIO
    SET nAfferenti = nAfferenti - 1
    WHERE nome = OLD.nomeLab;

    RAISE NOTICE 'Decrementato il numero di afferenti del laboratorio %!', OLD.nomeLab;

    RETURN OLD;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tr_change_nAfferenti_D
AFTER DELETE
ON azienda.AFFERIRE
FOR EACH ROW
EXECUTE FUNCTION azienda.fn_change_nAfferenti_D();