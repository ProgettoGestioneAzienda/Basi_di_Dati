--Trigger che da' errore se il tipo di una matricola non corrisponde a quello che dovrebbe essere
--in base alla differenza tra la data di assunzione e la data fine (o la data attuale)

CREATE OR REPLACE FUNCTION azienda.fn_verifica_tipo_dipInd() RETURNS trigger AS
$$
DECLARE
    --E' la differenza di anni tra la data di assunzione e quella di licenziamento o, in sua assenza, quella attuale
    numero_anni_trascorsi INTEGER := DATE_PART('year', AGE(COALESCE(NEW.dataFine, CURRENT_DATE), NEW.dataAssunzione));
BEGIN
    --Il numero_anni_trascorsi non può mai essere negativo perchè c'è il vincolo che dataAssunzione <= dataFine
    IF numero_anni_trascorsi < 3 THEN
        IF NEW.Tipo = 'Middle' OR NEW.Tipo = 'Senior' THEN --La matricola può solo essere Junior
            RAISE EXCEPTION 'La matricola % è di tipo "%" anche se non ha trascorso 3 anni in azienda!', NEW.matricola, NEW.Tipo;
        END IF;

    ELSIF 3 <= numero_anni_trascorsi AND numero_anni_trascorsi < 7 THEN --La matricola può solo essere Middle
        IF NEW.Tipo = 'Junior' THEN
            RAISE EXCEPTION 'La matricola % è di tipo "Junior" ma ha trascorso più di 3 anni in azienda!', NEW.matricola;
        ELSIF NEW.Tipo = 'Senior' THEN
            RAISE EXCEPTION 'La matricola % è di tipo "Senior" anche se non ha trascorso 7 anni in azienda!', NEW.matricola;
        END IF;

    ELSIF numero_anni_trascorsi >= 7 THEN --La matricola può solo essere Senior
        IF NEW.Tipo <> 'Senior' THEN
            RAISE EXCEPTION 'La matricola % è di tipo "%" ma ha trascorso più di 7 anni in azienda!', NEW.matricola, NEW.Tipo;    
        END IF;

    END IF;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER b_tr_verifica_tipo_dipInd
BEFORE INSERT OR UPDATE ON azienda.DIP_INDETERMINATO
FOR EACH ROW
EXECUTE FUNCTION azienda.fn_verifica_tipo_dipInd();