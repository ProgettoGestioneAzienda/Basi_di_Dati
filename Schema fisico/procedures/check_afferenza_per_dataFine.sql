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