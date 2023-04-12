--Funzione che cambia il tipo di una matricola in base alla differenza tra la data di assunzione e la data fine (o la data attuale)

CREATE OR REPLACE FUNCTION azienda.aggiorna_tipo(
    mat IN azienda.dip_indeterminato.matricola%TYPE,
    tipo_mat IN azienda.dip_indeterminato.tipo%TYPE,
    dataAssunzione_mat IN azienda.dip_indeterminato.dataAssunzione%TYPE,
    dataFine_mat IN azienda.dip_indeterminato.dataFine%TYPE
) RETURNS azienda.dip_indeterminato.tipo%TYPE AS
$$
DECLARE
    check_existance azienda.dip_indeterminato.matricola%TYPE;
    --E' la differenza di anni tra la data di assunzione e quella di licenziamento o, in sua assenza, quella attuale
    numero_anni_trascorsi INTEGER := DATE_PART('year', AGE(COALESCE(dataFine_mat, CURRENT_DATE), dataAssunzione_mat));
BEGIN
    SELECT Matricola INTO check_existance
    FROM azienda.dip_indeterminato
    WHERE Matricola = mat AND Tipo = tipo_mat AND dataAssunzione = dataAssunzione_mat AND dataFine IS NOT DISTINCT FROM dataFine_mat;

    IF NOT FOUND THEN
        IF tipo_mat IS NULL OR dataAssunzione_mat IS NULL THEN
            RAISE EXCEPTION 'Matricola % non esistente!', mat;
        ELSE
            RAISE EXCEPTION 'Matricola % di tipo % e assunto in data % non esistente!', mat, tipo_mat, dataAssunzione_mat;
        END IF;
    END IF;


    --Il numero_anni_trascorsi non può mai essere negativo perchè c'è il vincolo che dataAssunzione <= dataFine
    IF numero_anni_trascorsi < 3 THEN
        IF tipo_mat = 'Middle' OR tipo_mat = 'Senior' THEN --La matricola può solo essere Junior
            RAISE NOTICE 'La matricola % è di tipo "%" anche se non ha trascorso 3 anni in azienda! Cambio il tipo in "Junior"', mat, tipo_mat;
        END IF;
        
        tipo_mat = 'Junior';

    ELSIF 3 <= numero_anni_trascorsi AND numero_anni_trascorsi < 7 THEN --La matricola può solo essere Middle
        IF tipo_mat = 'Junior' THEN
            RAISE NOTICE 'La matricola % è di tipo "Junior" ma ha trascorso più di 3 anni in azienda! Cambio il tipo in "Middle"', mat;
        ELSIF tipo_mat = 'Senior' THEN
            RAISE NOTICE 'La matricola % è di tipo "Senior" anche se non ha trascorso 7 anni in azienda! Cambio il tipo in "Middle"', mat;
        END IF;
        
        tipo_mat = 'Middle';

    ELSIF numero_anni_trascorsi >= 7 THEN --La matricola può solo essere Senior
        IF tipo_mat <> 'Senior' THEN
            RAISE NOTICE 'La matricola % è di tipo "%" ma ha trascorso più di 7 anni in azienda! Cambio il tipo in "Senior"', mat, tipo_mat;    
        END IF;

        tipo_mat = 'Senior';

    END IF;

    RETURN tipo_mat;
END;
$$
LANGUAGE plpgsql;