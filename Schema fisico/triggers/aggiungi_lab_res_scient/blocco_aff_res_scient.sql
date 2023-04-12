/*
Si bloccano tutte le modifiche dirette ad azienda.AFFERIRE sia del nome di un laboratorio (altrimenti inconsistente con azienda.LABORATORIO) sia della matricola, per impedire
una eventuale rimozione di un responsabile scientifico
*/

CREATE OR REPLACE FUNCTION azienda.fn_blocco_aff_res_scient()
RETURNS TRIGGER
AS $$
BEGIN
    IF EXISTS (SELECT *
               FROM azienda.LABORATORIO
               WHERE Responsabile_scientifico = OLD.Matricola AND
                     nome = OLD.nomeLab) THEN
            
        RAISE EXCEPTION 'Non è possibile eliminare direttamente l''afferenza del responsabile scientifico % del laboratorio %!',OLD.Matricola, OLD.nomeLab;
    END IF;

    RETURN OLD;
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE TRIGGER tr_blocco_aff_lab_res_scient
BEFORE DELETE OR UPDATE OF Matricola, nomeLab
ON azienda.AFFERIRE
FOR EACH ROW
WHEN (pg_trigger_depth() < 1)
EXECUTE FUNCTION azienda.fn_blocco_aff_res_scient();