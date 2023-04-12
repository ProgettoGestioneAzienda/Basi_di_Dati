
/*
Si verifica che, all'aggiunta di un laboratorio con un responsabile scientifico (ogni laboratorio ha almeno un afferente, ovvero il responsabile scientifico stesso),
venga registrata l'afferenza del responsabile scientifico a quel laboratorio in automatico in azienda.AFFERIRE
*/

CREATE OR REPLACE FUNCTION azienda.fn_aggiungi_lab_res_scient_I()
RETURNS TRIGGER
AS $$
BEGIN 
    INSERT INTO azienda.AFFERIRE(Matricola, nomeLab)
    VALUES (NEW.Responsabile_scientifico, NEW.nome);

    RETURN NEW;
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE TRIGGER tr_z_aggiungi_lab_res_scient_I
AFTER INSERT
ON azienda.LABORATORIO
FOR EACH ROW
EXECUTE FUNCTION azienda.fn_aggiungi_lab_res_scient_I();