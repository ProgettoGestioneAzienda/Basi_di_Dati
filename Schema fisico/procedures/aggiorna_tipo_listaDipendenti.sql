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