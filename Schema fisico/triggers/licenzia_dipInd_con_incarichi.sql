/* Trigger che rifiuta ogni tentativo di licenziamento o modifica dei requisiti minimi 
di un referente scientifico/responsabile scientifico/responsabile progetto
se prima non si nomina un nuovo referente scientifico/responsabile */

CREATE OR REPLACE FUNCTION azienda.fn_licenzia_dipInd_con_incarichi () 
RETURNS trigger 
AS
$$
DECLARE
    lista_responsabile TEXT := azienda.get_list_CUP_responsabile_progetto(NEW.matricola);
    lista_referente_scientifico TEXT := azienda.get_list_CUP_referente_scientifico(NEW.matricola);
    lista_responsabile_scientifico TEXT := azienda.get_list_responsabile_laboratorio(NEW.matricola);
BEGIN
    
    IF (OLD.Tipo <> NEW.Tipo) OR (NEW.DataFine IS NOT NULL) THEN --Se sto cambiando il tipo o sto licenziando
        IF lista_referente_scientifico <> '' THEN
            RAISE EXCEPTION E'Impossibile licenziare il dipendente (o modificarne il tipo) con matricola % perchè è ancora Referente scientifico in alcuni progetti attivi.\nSostituisci prima il Referente scientifico (è possibile farlo tramite la procedura "azienda.sostituisci_referente_scientifico(azienda.get_list_CUP_referente_scientifico(<vecchiaMatricola>), <nuovaMatricola>)", che sostituirà tutte le vecchie occorrenze del referente scientifico con la nuova matricola) e poi potrai procedere con il licenziamento.\nI progetti in questione sono: %', NEW.Matricola, lista_referente_scientifico;
        END IF;
        IF lista_responsabile_scientifico <> '' THEN
            RAISE EXCEPTION E'Impossibile licenziare il dipendente (o modificarne il tipo) con matricola % perchè è ancora Responsabile scientifico in alcuni laboratori.\nSostituisci prima il Responsabile scientifico (è possibile farlo tramite la procedura "azienda.sostituisci_responsabile_laboratorio(azienda.get_list_responsabile_laboratorio(<vecchiaMatricola>), <nuovaMatricola>)", che sostituirà tutte le vecchie occorrenze del responsabile scientifico con la nuova matricola) e poi potrai procedere con il licenziamento.\nI laboratori in questione sono: %', NEW.Matricola, lista_responsabile_scientifico;
        END IF;
    END IF;

    IF (OLD.Dirigente <> NEW.Dirigente) OR (NEW.DataFine IS NOT NULL) THEN  --Se sto cambiando la dirigenza o sto licenziando
        IF lista_responsabile <> '' THEN
            RAISE EXCEPTION E'Impossibile licenziare il dipendente (o modificarne la dirigenza) con matricola % perchè è ancora Responsabile in alcuni progetti attivi.\nSostituisci prima il Responsabile (è possibile farlo tramite la procedura "azienda.sostituisci_responsabile_progetto(azienda.get_list_CUP_responsabile_progetto(<vecchiaMatricola>), <nuovaMatricola>)", che sostituirà tutte le vecchie occorrenze del responsabile con la nuova matricola) e poi potrai procedere con il licenziamento.\nI progetti in questione sono: %', NEW.Matricola, lista_responsabile;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER c_tr_licenzia_dipInd_con_incarichi
BEFORE UPDATE ON azienda.DIP_INDETERMINATO
FOR EACH ROW
WHEN
    (OLD.dataFine IS DISTINCT FROM NEW.dataFine OR
    OLD.Tipo <> NEW.Tipo OR
    OLD.Dirigente <> NEW.Dirigente)
EXECUTE FUNCTION azienda.fn_licenzia_dipInd_con_incarichi();