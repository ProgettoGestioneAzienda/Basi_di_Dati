--Funzione che recupera la lista dei CUP di cui la matricola è referente scientifico
CREATE OR REPLACE FUNCTION azienda.get_list_CUP_referente_scientifico(matricola IN azienda.matricola) 
RETURNS TEXT 
AS
$$
DECLARE
    progettiCoinvolti CURSOR FOR
        SELECT CUP
        FROM azienda.progetto
        WHERE Referente_Scientifico = matricola AND (dataFine IS NULL OR dataFine >= current_date);
    
    cup_progetto azienda.CUP;

    lista_referente_scientifico TEXT := '';
BEGIN
    OPEN progettiCoinvolti;
    LOOP
        FETCH progettiCoinvolti INTO cup_progetto;
        EXIT WHEN NOT FOUND;

        lista_referente_scientifico = CONCAT (lista_referente_scientifico, cup_progetto || ', ');
   
    END LOOP;
    CLOSE progettiCoinvolti;

    IF lista_referente_scientifico <> '' THEN
        lista_referente_scientifico = SUBSTR(lista_referente_scientifico, 1, LENGTH(lista_referente_scientifico)-2);
    END IF;

    RETURN lista_referente_scientifico;
END;
$$
LANGUAGE plpgsql;

---------------------------------------------------------------------------------------------------------------------------------

--Funzione di sostituzione del Referente scientifico
CREATE OR REPLACE PROCEDURE azienda.sostituisci_referente_scientifico(listaCUP IN TEXT, matricola IN azienda.matricola) 
AS
$$
DECLARE
    copyListaCUP TEXT := listaCUP;
    singleCUP azienda.CUP;
    separatoreIndex INT;
BEGIN
    IF listaCUP = '' THEN
        RAISE EXCEPTION 'Non ci sono CUP in input';
    END IF;

    separatoreIndex := STRPOS(listaCUP, ', '); --Se è 0 vuol dire che non c'è nessun ', ' ma almeno una parola -> C'è un solo CUP in listaCUP
    
    WHILE separatoreIndex <> 0
    LOOP
        singleCUP := SUBSTR(listaCUP, 1, separatoreIndex-1); --Isolo il CUP
        listaCUP := SUBSTR(listaCUP, separatoreIndex+2, LENGTH(listaCUP)); --Cancello il CUP e il ', ' dalla lista dei CUP

        UPDATE azienda.progetto
        SET Referente_Scientifico = matricola
        WHERE CUP = singleCUP;

        separatoreIndex := STRPOS(listaCUP, ', '); --Controllo l'esistenza (e ricalcolo la posizione) del prossimo ', '
    END LOOP;

    UPDATE azienda.progetto
    SET Referente_Scientifico = matricola
    WHERE CUP = listaCUP;

    RAISE NOTICE 'Ho sostituito il Referente scientifico dei progetti: % con la matricola "%"', copyListaCUP, matricola;
END;
$$
LANGUAGE plpgsql;

---------------------------------------------------------------------------------------------------------------------------------

--Funzione che recupera la lista dei CUP di cui la matricola è responsabile
CREATE OR REPLACE FUNCTION azienda.get_list_CUP_responsabile_progetto(matricola IN azienda.matricola) 
RETURNS TEXT 
AS
$$
DECLARE
    progettiCoinvolti CURSOR FOR
        SELECT CUP
        FROM azienda.progetto
        WHERE Responsabile = matricola AND (dataFine IS NULL OR dataFine >= current_date);
    
    cup_progetto azienda.CUP;

    lista_responsabile TEXT := '';
BEGIN
    OPEN progettiCoinvolti;
    LOOP
        FETCH progettiCoinvolti INTO cup_progetto;
        EXIT WHEN NOT FOUND;

        lista_responsabile = CONCAT (lista_responsabile, cup_progetto || ', ');
        
    END LOOP;
    CLOSE progettiCoinvolti;

    IF lista_responsabile <> '' THEN
        lista_responsabile = SUBSTR(lista_responsabile, 1, LENGTH(lista_responsabile)-2);
    END IF;

    RETURN lista_responsabile;
END;
$$
LANGUAGE plpgsql;

---------------------------------------------------------------------------------------------------------------------------------

--Funzione di sostituzione del Responsabile
CREATE OR REPLACE PROCEDURE azienda.sostituisci_responsabile_progetto(listaCUP IN TEXT, matricola IN azienda.matricola) 
AS
$$
DECLARE
    copyListaCUP TEXT := listaCUP;
    singleCUP azienda.CUP;
    separatoreIndex INT;
BEGIN
    IF listaCUP = '' THEN
        RAISE EXCEPTION 'Non ci sono CUP in input';
    END IF;

    separatoreIndex := STRPOS(listaCUP, ', '); --Se è 0 vuol dire che non c'è nessun ', ' ma almeno una parola -> C'è un solo CUP in listaCUP
    
    WHILE separatoreIndex <> 0
    LOOP
        singleCUP := SUBSTR(listaCUP, 1, separatoreIndex-1); --Isolo il CUP
        listaCUP := SUBSTR(listaCUP, separatoreIndex+2, LENGTH(listaCUP)); --Cancello il CUP e il ', ' dalla lista dei CUP

        UPDATE azienda.progetto
        SET Responsabile = matricola
        WHERE CUP = singleCUP;

        separatoreIndex := STRPOS(listaCUP, ', '); --Controllo l'esistenza (e ricalcolo la posizione) del prossimo ', '
    END LOOP;

    UPDATE azienda.progetto
    SET Responsabile = matricola
    WHERE CUP = listaCUP;

    RAISE NOTICE 'Ho sostituito il Responsabile dei progetti: % con la matricola "%"', copyListaCUP, matricola;
END;
$$
LANGUAGE plpgsql;

---------------------------------------------------------------------------------------------------------------------------------

--Funzione che recupera la lista dei laboratori di cui la matricola è responsabile scientifico
CREATE OR REPLACE FUNCTION azienda.get_list_responsabile_laboratorio(matricola IN azienda.matricola) 
RETURNS TEXT 
AS
$$
DECLARE
    laboratoriCoinvolti CURSOR FOR
        SELECT Nome
        FROM azienda.laboratorio
        WHERE Responsabile_Scientifico = matricola;
    
    lab azienda.laboratorio.nome%TYPE;

    lista_responsabile_scientifico TEXT := '';
BEGIN
    OPEN laboratoriCoinvolti;
    LOOP
        FETCH laboratoriCoinvolti INTO lab;
        EXIT WHEN NOT FOUND;

        lista_responsabile_scientifico = CONCAT (lista_responsabile_scientifico, lab || ', ');
   
    END LOOP;
    CLOSE laboratoriCoinvolti;

    IF lista_responsabile_scientifico <> '' THEN
        lista_responsabile_scientifico = SUBSTR(lista_responsabile_scientifico, 1, LENGTH(lista_responsabile_scientifico)-2);
    END IF;

    RETURN lista_responsabile_scientifico;
END;
$$
LANGUAGE plpgsql;

---------------------------------------------------------------------------------------------------------------------------------

--Funzione di sostituzione del Responsabile scientifico
CREATE OR REPLACE PROCEDURE azienda.sostituisci_responsabile_laboratorio(listaLaboratori IN TEXT, matricola IN azienda.matricola) AS
$$
DECLARE
    copylistaLaboratori TEXT := listaLaboratori;
    lab azienda.laboratorio.nome%TYPE;
    separatoreIndex INT;
BEGIN
    IF listaLaboratori = '' THEN
        RAISE EXCEPTION 'Non ci sono laboratori in input';
    END IF;

    separatoreIndex := STRPOS(listaLaboratori, ', '); --Se è 0 vuol dire che non c'è nessun ', ' ma almeno una parola -> C'è un solo laboratorio in listaLaboratori
    
    WHILE separatoreIndex <> 0
    LOOP
        lab := SUBSTR(listaLaboratori, 1, separatoreIndex-1); --Isolo il laboratorio
        listaLaboratori := SUBSTR(listaLaboratori, separatoreIndex+2, LENGTH(listaLaboratori)); --Cancello il laboratorio e il ', ' dalla lista dei laboratori

        UPDATE azienda.laboratorio
        SET Responsabile_Scientifico = matricola
        WHERE nome = lab;

        separatoreIndex := STRPOS(listaLaboratori, ', '); --Controllo l'esistenza (e ricalcolo la posizione) del prossimo ', '
    END LOOP;

    UPDATE azienda.laboratorio
    SET Responsabile_Scientifico = matricola
    WHERE nome = listaLaboratori;

    RAISE NOTICE 'Ho sostituito il Responsabile Scientifico dei laboratori: % con la matricola "%"', copylistaLaboratori, matricola;
END;
$$
LANGUAGE plpgsql;

---------------------------------------------------------------------------------------------------------------------------------

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

---------------------------------------------------------------------------------------------------------------------------------

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

---------------------------------------------------------------------------------------------------------------------------------

/* Funzione che, data in input una lista di matricole, controlla che il "Tipo" del dipendente sia
aggiornato e, nel caso non lo sia, lo aggiorna 

Si suppone che la funzione venga chiamata periodicamente con una lista di dipendenti per cui si vuole verficare
se, con il trascorrere del tempo, hanno effettivamente effettuato uno scatto di carriera
*/

CREATE OR REPLACE PROCEDURE azienda.aggiorna_tipo_listaDipendenti(listaMatricole IN TEXT) AS
$$
DECLARE
    copyListaMatricole TEXT := listaMatricole;
    dati_matricola RECORD;
    tipo_effettivo azienda.dip_indeterminato.tipo%TYPE;
    mat azienda.dip_indeterminato.matricola%TYPE;
    separatoreIndex INT;
BEGIN
    IF listaMatricole = '' THEN
        RAISE EXCEPTION 'Non ci sono matricole in input';
    END IF;

    separatoreIndex := STRPOS(listaMatricole, ', '); --Se è 0 vuol dire che non c'è nessun ', ' ma almeno una parola -> C'è una sola matricola in listaMatricole
    
    WHILE separatoreIndex <> 0
    LOOP
        mat := SUBSTR(listaMatricole, 1, separatoreIndex-1); --Isolo la matricola
        listaMatricole := SUBSTR(listaMatricole, separatoreIndex+2, LENGTH(listaMatricole)); --Cancello la matricola e il ', ' dalla lista delle matricole

        SELECT tipo, dataAssunzione, dataFine INTO dati_matricola
        FROM azienda.DIP_INDETERMINATO
        WHERE Matricola = mat;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'La matricola % non esiste', mat;
        END IF;

        tipo_effettivo = azienda.aggiorna_tipo(mat, dati_matricola.tipo, dati_matricola.dataAssunzione, dati_matricola.dataFine);
        IF tipo_effettivo <> dati_matricola.tipo THEN
            UPDATE azienda.DIP_INDETERMINATO
            SET Tipo = tipo_effettivo
            WHERE Matricola = mat;
        END IF;


        separatoreIndex := STRPOS(listaMatricole, ', '); --Controllo l'esistenza (e ricalcolo la posizione) del prossimo ', '
    END LOOP;


    SELECT tipo, dataAssunzione, dataFine INTO dati_matricola
    FROM azienda.DIP_INDETERMINATO
    WHERE Matricola = listaMatricole;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'La matricola % non esiste', listaMatricole;
    END IF;

    tipo_effettivo = azienda.aggiorna_tipo(listaMatricole, dati_matricola.tipo, dati_matricola.dataAssunzione, dati_matricola.dataFine);
    IF tipo_effettivo <> dati_matricola.tipo THEN
        UPDATE azienda.DIP_INDETERMINATO
        SET Tipo = tipo_effettivo
        WHERE Matricola = listaMatricole;
    END IF;


    RAISE NOTICE 'Ho aggiornato, dove possibile, l''anzianità per le matricole: %', copyListaMatricole;
END;
$$
LANGUAGE plpgsql;

---------------------------------------------------------------------------------------------------------------------------------

--Funzione che, inserita una matricola in input, ritorna i nomi di tutti i laboratori a cui afferisce quella matricola
CREATE OR REPLACE FUNCTION azienda.get_list_lab_afferenza_matricola(dip_matricola IN azienda.Matricola)
RETURNS text
AS $$
DECLARE
    var RECORD;
    lista_nomiLab text := '';
BEGIN

    FOR var IN
        SELECT nomeLab
        FROM azienda.AFFERIRE
        WHERE Matricola = dip_matricola
    LOOP --Se entro nel loop, c'è almeno un laboratorio a cui la matricola afferisce

		IF LENGTH(lista_nomiLab) = 0 THEN --Se è il primo ciclo di loop, la lista è vuota e scrivo il laboratorio nella lista
			lista_nomiLab := var.nomeLab;
		ELSE --Se faccio altri loop, ho LENGTH(lista_nomiLab) > 0 perchè ho già scritto almeno un laboratorio
        	lista_nomiLab := CONCAT(lista_nomiLab, ', ', var.nomeLab); --Aggiungo i successivi laboratori alla lista
		END IF;
        
    END LOOP;

    RETURN lista_nomiLab;
END;
$$
LANGUAGE PLPGSQL;

---------------------------------------------------------------------------------------------------------------------------------

/* Procedura che, per ogni dipendente a tempo indeterminato non più attivo rispetto alla data attuale (cioè se ha dataFine antecedente alla data in cui
viene effettuato il controllo), elimina la propria afferenza a tutti i laboratori

Si supponga che questa procedura venga chiamata periodicamente per attuare il controllo su tutti i dipendenti a tempo indeterminato */

CREATE OR REPLACE PROCEDURE azienda.check_afferenza_per_dataFine()
AS $$
DECLARE
    lista_laboratori_afferiti text;
    var RECORD;
BEGIN
    --Prendo tutti i dipendenti a tempo indeterminato la cui dataFine è precedente rispetto alla data in cui viene invocata la procedura
    --Ovvero i dipendenti che hanno effettivamente smesso di lavorare per l'azienda
    FOR var IN 
        SELECT DI.Matricola
        FROM azienda.DIP_INDETERMINATO AS DI
        WHERE DI.dataFine <= DATE(NOW() AND EXISTS
                                        (SELECT *
                                        FROM azienda.AFFERIRE AS A
                                        WHERE A.matricola = DI.Matricola))
    LOOP
        --La funzione get_list_lab_afferenza_matricola(<matricola>) recupera tutti i laboratori a cui la matricola specificata in input afferisce
        lista_laboratori_afferiti := azienda.get_list_lab_afferenza_matricola(var.Matricola);

        --Se la lista dei laboratori è vuota, ovvero la matricola non afferisce ad alcun laboratorio, non c'è nessuna afferenza da eliminare nella tabella
        IF lista_laboratori_afferiti = '' THEN
            RAISE NOTICE E'Il dipendente a tempo indeterminato % non afferisce ad alcun laboratorio.\nPertanto non è possibile rimuovere alcuna afferenza per quest''ultimo!', var.Matricola;
            
        ELSE--Altrimenti elimina tutte le afferenze della matricola e notifica quali sono i laboratori in questione
            DELETE FROM azienda.AFFERIRE
            WHERE Matricola = var.Matricola;

            RAISE NOTICE E'Sono state eliminate le afferenze ai laboratori "%" del dipendente a tempo indeterminato "%"', lista_laboratori_afferiti, var.Matricola;
		END IF;
    END LOOP;

END;
$$
LANGUAGE PLPGSQL;