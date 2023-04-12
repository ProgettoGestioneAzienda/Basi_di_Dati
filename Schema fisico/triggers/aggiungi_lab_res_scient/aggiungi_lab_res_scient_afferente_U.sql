/*
Prima della modifica di un responsabile scientifico in azienda.LABORATORIO per un dato laboratorio, si verifica che il nuovo responsabile scientifico sia un afferente al laboratorio
dato o meno.
Se non è un afferente, il controllo entra nell'IF e viene rimpiazzata, in azienda.AFFERIRE, la vecchia tupla del responsabile scientifico con quella nuova.
Se è un afferente, i'IF viene ignorato e il controllo passa al trigger aggiungi_lab_res_scient_afferente_U.
Nel primo caso, verrà rimossa l'afferenza dell'OLD.Responsabile scientifico, quindi quando il controllo passerà al trigger aggiungi_lab_res_scient_afferente_U, il suo corpo verrà ignorato
in quanto non troverà in azienda.AFFERIRE l'afferenza del vecchio responsabile scientifico.
*/

CREATE OR REPLACE FUNCTION azienda.fn_aggiungi_lab_res_scient_afferente_U()
RETURNS TRIGGER
AS $$
BEGIN

    --se il nuovo responsabile scientifico è già un afferente del laboratorio
    --bisogna eliminare la vecchia afferenza del vecchio responsabile scientifico
    IF EXISTS (SELECT *
               FROM azienda.AFFERIRE
               WHERE Matricola = OLD.Responsabile_scientifico AND
               nomeLab = OLD.nome) THEN

    --se la nuova matricola Resp_scient è già un afferente al lab,
    --elimino direttamente quella del vecchio resp, altrimenti faccio l'update
    DELETE FROM azienda.AFFERIRE
    WHERE nomeLab = OLD.nome AND Matricola = OLD.Responsabile_scientifico;

    RAISE NOTICE 'L''afferenza del vecchio responsabile scientifico % è stata sostituita con l''afferenza del nuovo responsabile scientifico % per il laboratorio %
Non è stata conservata l''afferenza del vecchio responsabile scientifico %, che ora non afferirà più al laboratorio %'
                      , OLD.Responsabile_Scientifico, NEW.Responsabile_Scientifico, NEW.nome, OLD.Responsabile_Scientifico, NEW.nome;

    END IF;

    RETURN NEW;
END;
$$
LANGUAGE PLPGSQL;
CREATE OR REPLACE TRIGGER tr_z_aggiungi_lab_res_scient_afferente_U
AFTER UPDATE OF Responsabile_Scientifico
ON azienda.LABORATORIO
FOR EACH ROW
WHEN (OLD.nome <> NEW.nome OR OLD.Responsabile_scientifico <> NEW.Responsabile_scientifico)
EXECUTE FUNCTION azienda.fn_aggiungi_lab_res_scient_afferente_U();