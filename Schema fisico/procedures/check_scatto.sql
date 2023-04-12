--Funzione che, data in input matricola, tipo matricola e data assunzione, registra gli scatti della matricola nelle date opportune

CREATE OR REPLACE PROCEDURE azienda.check_scatto(
    mat IN azienda.dip_indeterminato.matricola%TYPE,
    tipo_mat IN azienda.dip_indeterminato.tipo%TYPE,
    dataAssunzione_mat IN azienda.dip_indeterminato.dataAssunzione%TYPE) AS
$$
DECLARE
    check_existance azienda.dip_indeterminato.matricola%TYPE;

    cursore CURSOR (test_tipo TEXT) FOR
        SELECT Data
        FROM azienda.SCATTO_CARRIERA
        WHERE Matricola = mat AND tipo = test_tipo;
    data_scatto azienda.scatto_carriera.data%TYPE;

    scattiPresenti TEXT := 'Scatti già registrati:';
    scattiAggiunti TEXT := 'Nuovi scatti registrati:';
BEGIN

    SELECT Matricola INTO check_existance
    FROM azienda.dip_indeterminato
    WHERE Matricola = mat AND UPPER(Tipo) = UPPER(tipo_mat) AND dataAssunzione = dataAssunzione_mat;

    IF NOT FOUND THEN
        IF tipo_mat IS NULL OR dataAssunzione_mat IS NULL THEN
            RAISE EXCEPTION 'Matricola % non esistente!', mat;
        ELSE
            RAISE EXCEPTION 'Matricola % di tipo % e assunto in data % non esistente!', mat, tipo_mat, dataAssunzione_mat;
        END IF;
    END IF;

    --Cambia il tipo della matricola in un formato accettato dalla funzione
    IF UPPER(tipo_mat) = 'JUNIOR' THEN tipo_mat = 'Junior';
    ELSIF UPPER(tipo_mat) = 'MIDDLE' THEN tipo_mat = 'Middle';
    ELSIF UPPER(tipo_mat) = 'SENIOR' THEN tipo_mat = 'Senior';
    ELSE RAISE EXCEPTION 'Tipo non accettato!';
    END IF;
 
    IF tipo_mat = 'Junior' THEN
        RAISE NOTICE 'La matricola % è di tipo Junior! Nessuno scatto registrato', mat;

    ELSE --Il tipo sarà o Middle o Senior. Controllo che lo scatto "Middle" non presenti errori
        OPEN cursore('Middle');
        FETCH cursore INTO data_scatto; 

        IF NOT FOUND THEN --Se non c'è nessuno scatto, lo registro
            scattiAggiunti := CONCAT (scattiAggiunti, ' "Junior" a "Middle"');
            
            INSERT INTO azienda.SCATTO_CARRIERA(Matricola, Tipo, Data) VALUES
            (mat, 'Middle', dataAssunzione_mat + interval '3 years');
        
        ELSE --Vuol dire che lo scatto è già stato registrato
            scattiPresenti := CONCAT (scattiPresenti, ' "Junior" a "Middle"');

        END IF;
        CLOSE cursore;


        --Ripeto lo stesso ragionamento per gli scatti "Senior"
        IF tipo_mat = 'Senior' THEN
            OPEN cursore('Senior');
            FETCH cursore INTO data_scatto; 

            IF NOT FOUND THEN --Se non c'è nessuno scatto, lo registro
                IF scattiAggiunti <> 'Nuovi scatti registrati:' THEN
                    scattiAggiunti := CONCAT (scattiAggiunti, ' e');
                END IF;
                scattiAggiunti := CONCAT (scattiAggiunti, ' "Middle" a "Senior"');
                
                INSERT INTO azienda.SCATTO_CARRIERA(Matricola, Tipo, Data) VALUES
                (mat, 'Senior', dataAssunzione_mat + interval '7 years');
            
            ELSE --Vuol dire che lo scatto è già stato registrato
                IF scattiPresenti <> 'Scatti già registrati:' THEN
                    scattiPresenti := CONCAT (scattiPresenti, ' e');
                END IF;
                scattiPresenti := CONCAT (scattiPresenti, ' "Middle" a "Senior"');

            END IF;
            CLOSE cursore;
        
        END IF;

        IF scattiPresenti = 'Scatti già registrati:' THEN
            scattiPresenti := CONCAT(scattiPresenti, ' Nessuno');
        END IF;
        IF scattiAggiunti = 'Nuovi scatti registrati:' THEN
            scattiAggiunti := CONCAT(scattiAggiunti, ' Nessuno');
        END IF;

        RAISE NOTICE E'Matricola %, tipo %:\n%\n%', mat, tipo_mat, scattiPresenti, scattiAggiunti;

    END IF;
END;
$$
LANGUAGE plpgsql;