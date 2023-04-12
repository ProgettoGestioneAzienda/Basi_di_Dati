/*
Si intende rendere coerente il campo nAfferenti per eventuali modifiche delle afferenze in cui questi ultimi sono coinvolti.
Disponiamo di 3 casi da analizzare:
Per una tupla (Matricola, nomeLab)
1) Nel caso venga aggiornata solo la matricola, il laboratorio non perde alcuna afferenza, pertanto nAfferenti rimane invariato
2) Nel caso venga aggiornato solo il laboratorio, il vecchio laboratorio perde una afferenza, mentre il nuovo la guadagna
3) Nel caso vengano aggiornati entrambi, il vecchio laboratorio perderà una afferenza, mentre il nuovo laboratorio ne guadagna una.
*/

CREATE OR REPLACE FUNCTION azienda.fn_change_nAfferenti_U()
RETURNS TRIGGER
AS $$
BEGIN
    --si controlla la condizione per coprire il caso di update su azienda.LABORATORIO
    --altrimenti il decremento non andrà mai a buon fine siccome non esiste più il vecchio laboratorio, già modificato
    --viene fatto per non far azionare il conteggio con l'update del nome di laboratorio in CASCADE
    IF EXISTS (SELECT *
               FROM azienda.LABORATORIO
               WHERE nome = OLD.nomeLab) THEN

        --nel caso sia stata modificata una tupla (laboratorio, matricola) dove la matricola non è responsabile scientifico del laboratorio
        --si decrementa il numero di afferenti di 1 del vecchio laboratorio e si incrementa invece il numero di afferenti di 1 del nuovo laboratorio.
        UPDATE azienda.LABORATORIO
        SET nAfferenti = nAfferenti - 1
        WHERE nome = OLD.nomeLab;

        RAISE NOTICE 'Decrementato di 1 il numero di afferenti del vecchio laboratorio %!', OLD.nomeLab;

        UPDATE azienda.LABORATORIO
        SET nAfferenti = nAfferenti + 1
        WHERE nome = NEW.nomeLab;

        RAISE NOTICE 'Incrementato di 1 il numero di afferenti del nuovo laboratorio %!', NEW.nomeLab;
    END IF;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tr_change_nAfferenti_U
AFTER UPDATE
ON azienda.AFFERIRE
FOR EACH ROW
WHEN (NEW.nomeLab <> OLD.nomeLab)
EXECUTE FUNCTION azienda.fn_change_nAfferenti_U();