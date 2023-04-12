/*
Prima della modifica di un responsabile scientifico in azienda.LABORATORIO per un dato laboratorio, viene verificato se il nuovo responsabile scientifico è un afferente al laboratorio o meno. 
Se non lo è, la vecchia tupla del responsabile scientifico viene sostituita con quella nuova in azienda.AFFERIRE. 
Se invece il nuovo responsabile scientifico è un afferente, il controllo passa al trigger aggiungi_lab_res_scient_afferente_U. 
Nel primo caso, verrà rimossa l'afferenza dell'OLD.Responsabile scientifico, quindi quando il controllo passerà al trigger aggiungi_lab_res_scient_afferente_U, 
il suo corpo verrà ignorato in quanto non troverà in azienda.AFFERIRE l'afferenza del vecchio responsabile scientifico.
*/

CREATE OR REPLACE FUNCTION azienda.fn_aggiungi_lab_res_scient_non_afferente_U()
RETURNS TRIGGER
AS $$
BEGIN

    --se il nuovo responsabile scientifico non è già un afferente al laboratorio, allora bisogna sostituirlo con il responsabile
    --se viene ignorato l'if significa che il nuovo responsabile scientifico è già un afferente del laboratorio
    IF NOT EXISTS (SELECT *
                    FROM azienda.AFFERIRE
                    WHERE Matricola = NEW.Responsabile_scientifico AND
                    nomeLab = OLD.nome) THEN

        --se non viene specificata anche la condizione nomeLab = OLD.nome, verrebbero sostituite tutte le afferenze (anche quelle semplici)
        --del vecchio responsabile scientifico, facendo risultare quest'ultimo come NON afferente ad alcun laboratorio
        UPDATE azienda.AFFERIRE
        SET Matricola = NEW.Responsabile_Scientifico
        WHERE Matricola = OLD.Responsabile_Scientifico AND nomeLab = OLD.nome;

    RAISE NOTICE 'L''afferenza del vecchio responsabile scientifico % è stata sostituita con l''afferenza del nuovo responsabile scientifico % per il laboratorio %
Non è stata conservata l''afferenza del vecchio responsabile scientifico %, che ora non afferirà più al laboratorio %'
                      , OLD.Responsabile_Scientifico, NEW.Responsabile_Scientifico, NEW.nome, OLD.Responsabile_Scientifico, NEW.nome;

    END IF;

    RETURN NEW;
END;
$$
LANGUAGE PLPGSQL;
CREATE OR REPLACE TRIGGER tr_z_aggiungi_lab_res_scient_non_afferente_U
BEFORE UPDATE OF Responsabile_Scientifico
ON azienda.LABORATORIO
FOR EACH ROW
WHEN (OLD.nome <> NEW.nome OR OLD.Responsabile_scientifico <> NEW.Responsabile_scientifico)
EXECUTE FUNCTION azienda.fn_aggiungi_lab_res_scient_non_afferente_U();