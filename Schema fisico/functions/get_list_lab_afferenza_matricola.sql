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