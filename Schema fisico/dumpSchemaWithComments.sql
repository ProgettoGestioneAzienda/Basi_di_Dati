--CANCELLAZIONE VECCHIO SCHEMA
DROP SCHEMA IF EXISTS azienda CASCADE;

--------------------------------------------------------------------------------------------------------------------------------------------------------------
--CREAZIONE SCHEMA

CREATE SCHEMA azienda AUTHORIZATION postgres;

--------------------------------------------------------------------------------------------------------------------------------------------------------------
--CREAZIONE DOMINI

--CREO UN GENERICO DOMINIO "STRING" PER CAMPI VARCHAR SENZA ESIGENZE SPECIFICHE
CREATE DOMAIN azienda.STRING AS VARCHAR(30);

--CREO UN DOMINIO "EURO" PER CAMPI DI CIFRE DECIMALI CHE RAPPRESENTANO UN COSTO
CREATE DOMAIN azienda.EURO AS NUMERIC(20, 2) --Va da -(10^18)+0.01 a (10^18)-0.01 e arrotonda per difetto da 0.001 a 0.004, il resto per eccesso
CONSTRAINT POSITIVE_EURO
	CHECK (VALUE >= 0);

--AGGIUNGO IL VINCOLO CHE UNA MATRICOLA DEVE ESSERE OBBLIGATORIAMENTE DI 8 CARATTERI, RINOMINANDOLA CON UNA LABEL
CREATE DOMAIN azienda.MATRICOLA AS VARCHAR(8)
CONSTRAINT DOM_MATRICOLA_CHECK_LENGTH
    CHECK (LENGTH(VALUE) = 8);

--AGGIUNGO IL VINCOLO CHE IL CUP DEVE ESSERE OBBLIGATORIAMENTE DI 15 CARATTERI, RINOMINANDOLO CON UNA LABEL
CREATE DOMAIN azienda.CUP AS VARCHAR(15)
CONSTRAINT DOM_CUP_CHECK_LENGTH
    CHECK (LENGTH(VALUE) = 15)
CONSTRAINT DOM_CUP_CHECK_ALPHANUMERIC
	CHECK (VALUE ~ '[[:alnum:]]{15}');

--AGGIUNGO IL VINCOLO CHE UN CODICE FISCALE DEVE ESSERE OBBLIGATORIAMENTE DI 16 CARATTERI, RINOMINANDOLA CON UNA LABEL
CREATE DOMAIN azienda.CODFISCALE AS VARCHAR(16)
CONSTRAINT DOM_CODFISCALE_CHECK_LENGTH
    CHECK (LENGTH(VALUE) = 16)
CONSTRAINT DOM_CODFISCALE_CHECK_ALPHANUMERIC
	CHECK (VALUE ~ '[[:alnum:]]{16}');

--IL TIPO DI UN DIPENDENTE DEVE ESSERE OBBLIGATORIAMENTE UNO DI QUESTI
CREATE DOMAIN azienda.TIPO_DIPENDENTE AS VARCHAR(6)
CONSTRAINT DOM_TIPO_DIPENDENTE_CHECK_JMS
	CHECK (UPPER(VALUE) IN ('JUNIOR', 'MIDDLE', 'SENIOR'));

--IL TIPO DI SCATTO DEVE ESSERE OBBLIGATORIAMENTE UNO DI QUESTI.
--Lo scatto da Junior a Middle è chiamato "Middle", lo scatto da Middle a Senior è chiamato "Senior" e lo scatto a Dirigente è chiamato "Dirigente"
CREATE DOMAIN azienda.TIPO_SCATTO AS VARCHAR(20)
CONSTRAINT DOM_TIPO_SCATTO_CHECK_MSD
	CHECK (UPPER(VALUE) IN ('MIDDLE', 'SENIOR', 'PROMOSSO A DIRIGENTE', 'RIMOSSO DA DIRIGENTE'));



--------------------------------------------------------------------------------------------------------------------------------------------------------------
--CREAZIONE TABELLE

CREATE TABLE azienda.DIP_INDETERMINATO(
	Matricola azienda.MATRICOLA NOT NULL,
	Tipo azienda.TIPO_DIPENDENTE NOT NULL DEFAULT 'Junior',
	Nome azienda.STRING NOT NULL,
	Cognome azienda.STRING NOT NULL,
	codFiscale azienda.CODFISCALE NOT NULL,
	Indirizzo VARCHAR(100),
	dataNascita DATE NOT NULL,
	dataAssunzione DATE NOT NULL,
	dataFine DATE,
	Dirigente BOOLEAN NOT NULL DEFAULT FALSE,
	
	CONSTRAINT pk_dip_indeterminato PRIMARY KEY (Matricola),
	--Non posso assumere un dipendente non ancora nato o licenziare un dipendente non ancora assunto
	CONSTRAINT check_ordine_date_di CHECK (dataNascita < dataAssunzione AND dataAssunzione <= dataFine)
);

CREATE TABLE azienda.SCATTO_CARRIERA(
	Matricola azienda.MATRICOLA NOT NULL,
	Tipo azienda.TIPO_SCATTO NOT NULL,
	Data DATE NOT NULL,
	
	CONSTRAINT pk_scatto_carriera PRIMARY KEY (Matricola, Tipo, Data),
	CONSTRAINT fk_matricola_scatto_carriera FOREIGN KEY (Matricola) 
		REFERENCES azienda.DIP_INDETERMINATO(Matricola)
		ON DELETE CASCADE	ON UPDATE CASCADE
);

CREATE TABLE azienda.LABORATORIO(
	Nome azienda.STRING NOT NULL,
	Topic azienda.STRING NOT NULL,
	nAfferenti INTEGER NOT NULL DEFAULT 1,
	Responsabile_Scientifico azienda.MATRICOLA NOT NULL,
	
	CONSTRAINT pk_laboratorio PRIMARY KEY (Nome),
	CONSTRAINT fk_responsabile_scientifico_laboratorio FOREIGN KEY (Responsabile_Scientifico)
		REFERENCES azienda.DIP_INDETERMINATO(Matricola)
		ON DELETE NO ACTION		ON UPDATE CASCADE,
	CONSTRAINT check_positive_nAfferenti CHECK (nAfferenti > 0) --Il numero di afferenti non può essere negativo nè zero perchè avrà almeno un afferente, cioè il responsabile scientifico
);

CREATE TABLE azienda.AFFERIRE(
	Matricola azienda.MATRICOLA NOT NULL,
	nomeLab azienda.STRING NOT NULL,
	
	CONSTRAINT pk_afferire PRIMARY KEY (Matricola, nomeLab),
	CONSTRAINT fk_matricola_afferire FOREIGN KEY (Matricola)
		REFERENCES azienda.DIP_INDETERMINATO(Matricola)
		ON DELETE CASCADE	ON UPDATE CASCADE,
	CONSTRAINT fk_nome_afferire FOREIGN KEY (nomeLab)
		REFERENCES azienda.LABORATORIO(Nome)
		ON DELETE CASCADE	ON UPDATE CASCADE
);

CREATE TABLE azienda.PROGETTO(
	CUP azienda.CUP NOT NULL,
	Nome azienda.STRING,
	dataInizio DATE NOT NULL,
	dataFine DATE,
	Budget azienda.EURO NOT NULL,
	costoAttrezzature azienda.EURO NOT NULL DEFAULT 0,
	costoContrattiProgetto azienda.EURO NOT NULL DEFAULT 0,
	Referente_Scientifico azienda.MATRICOLA NOT NULL,
	Responsabile azienda.MATRICOLA NOT NULL,
	
	CONSTRAINT pk_progetto PRIMARY KEY (CUP),
	CONSTRAINT fk_referente_scientifico_progetto FOREIGN KEY (Referente_Scientifico)
		REFERENCES azienda.DIP_INDETERMINATO(Matricola)
		ON DELETE NO ACTION		ON UPDATE CASCADE,
	CONSTRAINT fk_responsabile_progetto FOREIGN KEY (Responsabile) 
		REFERENCES azienda.dip_indeterminato(Matricola)
		ON DELETE NO ACTION		ON UPDATE CASCADE,
	CONSTRAINT nome_progetto_unico UNIQUE(Nome),
	CONSTRAINT check_positive_budget CHECK (Budget > 0), --Nella nostra azienda non possiamo lavorare a progetti con fondi minori o uguali a 0
	CONSTRAINT check_date_fine_inizio CHECK (dataInizio <= dataFine) --La data di inizio non può avvenire dopo la data di fine
);

CREATE TABLE azienda.LAVORARE(
	CUP azienda.CUP NOT NULL,
	nomeLab azienda.STRING NOT NULL,
	
	CONSTRAINT pk_lavorare PRIMARY KEY (CUP, nomeLab),
	CONSTRAINT fk_cup_lavorare FOREIGN KEY (CUP)
		REFERENCES azienda.PROGETTO(CUP)
		ON DELETE CASCADE	ON UPDATE CASCADE,
	CONSTRAINT fk_nome_lavorare FOREIGN KEY (nomeLab)
		REFERENCES azienda.LABORATORIO(Nome)
		ON DELETE CASCADE	ON UPDATE CASCADE
);

CREATE TABLE azienda.ATTREZZATURA(
	idAttrezzatura SERIAL NOT NULL,
	Descrizione VARCHAR(256) NOT NULL,
	Costo azienda.EURO NOT NULL,
	nomeLab azienda.STRING,
	CUP azienda.CUP NOT NULL,
	
	CONSTRAINT pk_attrezzatura PRIMARY KEY (idAttrezzatura),
	CONSTRAINT fk_nome_attrezzatura FOREIGN KEY (nomeLab)
		REFERENCES azienda.LABORATORIO(Nome)
/*Nel caso in cui cancellassimo un laboratorio, avremmo comunque intatto lo storico degli acquisti fatto. Dato che le attrezzature sono acquistate per un
progetto è giustificata l'azione ON DELETE SET NULL dato che abbiamo contemplato la possibilità di avere ATTREZZATURE non
possedute da nessuno.*/ 
		ON DELETE SET NULL		ON UPDATE CASCADE,
	CONSTRAINT fk_cup_attrezzatura FOREIGN KEY (CUP)
		REFERENCES azienda.progetto(CUP)
		ON DELETE CASCADE	ON UPDATE CASCADE
);

CREATE TABLE azienda.DIP_PROGETTO(
	Matricola azienda.Matricola NOT NULL,
	Nome azienda.STRING NOT NULL,
	Cognome azienda.STRING NOT NULL,
	codFiscale azienda.CODFISCALE NOT NULL,
	Indirizzo VARCHAR(100),
	dataNascita DATE NOT NULL,
	dataAssunzione DATE NOT NULL,
	Costo azienda.EURO NOT NULL,
	Scadenza DATE NOT NULL,
	CUP azienda.CUP NOT NULL,

	CONSTRAINT pk_dip_progetto PRIMARY KEY (Matricola),
	CONSTRAINT fk_cup_dip_progetto FOREIGN KEY (CUP)
		REFERENCES	azienda.progetto(CUP)
		ON DELETE CASCADE	ON UPDATE CASCADE,
	--Non posso assumere un dipendente non ancora nato o licenziare un dipendente non ancora assunto
	CONSTRAINT check_ordine_date_dp CHECK (dataNascita < dataAssunzione AND dataAssunzione <= Scadenza)
);



--------------------------------------------------------------------------------------------------------------------------------------------------------------
--CREAZIONE VIEW

-- View che permette di visualizzare i fondi totali che rimangono ai progetti e i rimanenti fondi dedicati ai contratti ed alle attrezzature
CREATE OR REPLACE VIEW azienda.FondiRimanentiProgetto AS
SELECT
  p.CUP,
  p.Nome,
  (p.Budget - p.costoAttrezzature - p.costoContrattiProgetto) AS Fondi_Rimanenti_Progetto,
  (p.Budget / 2) - (p.costoAttrezzature) AS Fondi_Rimanenti_Attrezzature,
  (p.Budget / 2) - (p.costoContrattiProgetto) AS Fondi_Rimanenti_Contratti
FROM
  azienda.PROGETTO AS p;

---------------------------------------------------------------------------------------------------------------------------------
-- Views che mostrano solo l'istanza attuale dell'azienda

--Dipendenti a tempo indeterminato attualmente in servizio
CREATE OR REPLACE VIEW azienda.dip_indeterminato_attuale AS
SELECT *
FROM azienda.dip_indeterminato AS DI
WHERE DI.DataFine IS NULL OR DI.DataFine > CURRENT_DATE;

--Scatti dei dipendenti attuali
CREATE OR REPLACE VIEW azienda.scatto_carriera_attuale AS
SELECT *
FROM azienda.scatto_carriera AS SC
WHERE SC.matricola IN (
    SELECT DI.matricola
    FROM azienda.dip_indeterminato AS DI
    WHERE DI.DataFine IS NULL OR DI.DataFine > CURRENT_DATE);

--Laboratori con almeno un dipendente in servizio. Il res_scientifico è sempre uno in servizio quindi non ci sarà mai un laboratori senza personale
--Dunque la tabella dei laboratori attuali coincide con quella "normale". Essendo superflua, non la aggiungiamo

--Dato che non tracciamo l'afferenza di dipendenti passati, la tabella "Afferire" è sempre costituita da dipendenti attualmente attivi

--Progetti con scadenza dopo quella attuale
CREATE OR REPLACE VIEW azienda.progetto_attuale AS
SELECT *
FROM azienda.progetto AS P
WHERE P.DataFine >= now() OR P.DataFine IS NULL;

--Tabella dei laboratori che lavorano a questi progetti
CREATE OR REPLACE VIEW azienda.lavorare_attuale AS 
SELECT *
FROM azienda.lavorare AS LAV
WHERE LAV.CUP IN (
    SELECT CUP
    FROM azienda.progetto AS P
    WHERE P.DataFine >= now() OR P.DataFine IS NULL);

--Le attrezzature che sono attualmente assegnate a un laboratorio
CREATE OR REPLACE VIEW azienda.attrezzatura_attuale AS
SELECT *
FROM azienda.attrezzatura
WHERE nomeLab IS NOT NULL;

--Dipendenti a progetto che lavorano su progetti ancora in corso
CREATE OR REPLACE VIEW azienda.dip_progetto_attuale AS
SELECT DP.Matricola, DP.Nome, DP.Cognome, DP.codFiscale, DP.Indirizzo, DP.dataNascita, DP.dataAssunzione, DP.Costo, DP.Scadenza, DP.CUP
FROM azienda.dip_progetto AS DP JOIN azienda.progetto AS P ON DP.CUP = P.CUP
WHERE (P.DataFine >= now() OR P.DataFine IS NULL) AND DP.Scadenza >= now();

--Progetti ai quali lavorano meno di 3 laboratori
CREATE OR REPLACE VIEW azienda.ProgettiLab AS
SELECT CUP, COUNT(*) AS "nLab lavoranti"
FROM azienda.LAVORARE
GROUP BY CUP
HAVING COUNT(*) < 3;



--------------------------------------------------------------------------------------------------------------------------------------------------------------
--CREAZIONE FUNZIONI E PROCEDURE

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

--------------------------------------------------------------------------------------------------------------------------------------------------------------
--CREAZIONE TRIGGERS

---------------------------------------------------------------------------------------------------------------------------------
--										TRIGGERS PER azienda.DIP_INDETERMINATO
---------------------------------------------------------------------------------------------------------------------------------

--Trigger che modifica all'inserimento il tipo nel formato corretto (esempio: jUniOR -> Junior)
--TIPO DIPENDENTE
CREATE OR REPLACE FUNCTION azienda.fn_nice_looking_domain_di() 
RETURNS trigger 
AS
$$
BEGIN
	NEW.tipo = CONCAT(UPPER(SUBSTR(NEW.tipo, 1, 1)), LOWER(SUBSTR(NEW.Tipo, 2, LENGTH(NEW.Tipo))));
	RETURN NEW;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER a_tr_nice_looking_domain_di
BEFORE INSERT OR UPDATE OF tipo ON azienda.DIP_INDETERMINATO
FOR EACH ROW
EXECUTE FUNCTION azienda.fn_nice_looking_domain_di();

---------------------------------------------------------------------------------------------------------------------------------

--Trigger che impedisce qualsiasi modifica manuale a "Dirigente" in dip_indetetrminato

CREATE OR REPLACE FUNCTION azienda.fn_blocco_modifica_dirigente() RETURNS trigger AS
$$
BEGIN
    IF OLD.Matricola IS NULL THEN --L'unico caso in cui può essere NULL è l'inserimento
        IF (NEW.Dirigente <> FALSE) THEN
            RAISE NOTICE E'Non puoi inserire manualmente lo stato dirigenziale del dipendete %. E'' necessario inserire l''apposito scatto in "azienda.scatto_carriera"', NEW.Matricola;
            NEW.Dirigente = FALSE;
        END IF;
    ELSE --Se non è l'inserimento, allora è un update
        IF (NEW.Dirigente <> OLD.Dirigente) THEN 
            RAISE NOTICE E'Non puoi inserire manualmente lo stato dirigenziale del dipendete %. E'' necessario inserire l''apposito scatto in "azienda.scatto_carriera"', NEW.Matricola;
            NEW.Dirigente = OLD.Dirigente;
        END IF;
    END IF;

    RETURN NEW;

END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tr_blocco_modifica_dirigente
BEFORE INSERT OR UPDATE OF Dirigente ON azienda.DIP_INDETERMINATO
FOR EACH ROW
WHEN (pg_trigger_depth() < 1)
EXECUTE FUNCTION azienda.fn_blocco_modifica_dirigente();

---------------------------------------------------------------------------------------------------------------------------------

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

---------------------------------------------------------------------------------------------------------------------------------
-- Automatismo dell'inserimento dello scatto di carriera di un dipendente indeterminato
-- Ogni qual volta avviene uno scatto di carriera e quindi si modifica la relazione dip. a tempo indeterminato
-- si innesca un trigger che riporta nella relazione SCATTO_CARRIERA il relativo scatto al TIPO aggiornato

CREATE OR REPLACE FUNCTION azienda.fn_aggiorna_scatti_tipo() 
RETURNS trigger 
AS
$$
BEGIN
    IF OLD.Matricola IS NULL THEN --E' l'inserimento
        CALL azienda.check_scatto(NEW.Matricola, NEW.Tipo, NEW.dataAssunzione);
    ELSE --E' l'update
        --Serie di IF aggiunti nel caso, a seguito di modifiche alla dataAssunzione o dataFine, il dipendente risulti essere di tipo minore a quello precedente
        IF NEW.Tipo = 'Junior' AND (OLD.Tipo = 'Middle' OR OLD.Tipo = 'Senior') THEN --Sto passando da Middle o Senior a Junior
            DELETE FROM azienda.SCATTO_CARRIERA
            WHERE Matricola = NEW.Matricola AND (Tipo = 'Middle' OR Tipo = 'Senior'); --Elimino gli scatti superflui

        ELSIF NEW.Tipo = 'Middle' AND (OLD.Tipo = 'Senior') THEN --Sto passando da Senior a Junior
            DELETE FROM azienda.SCATTO_CARRIERA
            WHERE Matricola = NEW.Matricola AND Tipo = 'Senior'; --Elimino gli scatti superflui
        END IF;

        CALL azienda.check_scatto(NEW.Matricola, NEW.Tipo, NEW.dataAssunzione); --Se scatto in avanti aggiungo gli scatti mancanti
    END IF;
    
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER b_tr_aggiorna_scatti_tipo
AFTER INSERT OR UPDATE ON azienda.DIP_INDETERMINATO
FOR EACH ROW
EXECUTE FUNCTION azienda.fn_aggiorna_scatti_tipo();

---------------------------------------------------------------------------------------------------------------------------------

--Trigger che verifica che non vi siano contratti già aperti per la persona con lo stesso codice fiscale
--nel caso venisse riassunto un dipendente
CREATE OR REPLACE FUNCTION azienda.fn_assunzione_coerente()
RETURNS Trigger
AS
$$
DECLARE
	cursore CURSOR FOR
		SELECT DI.Matricola, DI.codFiscale, DI.dataAssunzione, DI.dataFine
		FROM azienda.DIP_INDETERMINATO DI
		WHERE DI.codFiscale = NEW.codFiscale AND DI.matricola <> NEW.Matricola
		ORDER BY DI.dataAssunzione ASC;
		
	dip_ind RECORD;

	lista_contratti TEXT := ''; --Lista dei contratti che danno errore
BEGIN
	OPEN cursore;
	LOOP
		FETCH cursore INTO dip_ind;
		EXIT WHEN NOT FOUND;

		IF (((dip_ind.dataFine IS NULL) AND (dip_ind.Matricola <> NEW.Matricola)) OR --Non posso avere un contratto se ce n'è un altro aperto
		(dip_ind.dataAssunzione <= NEW.dataAssunzione AND NEW.dataAssunzione < dip_ind.dataFine) OR --Non posso avere un'assunzione nel bel mezzo di un altro contratto
		(dip_ind.dataAssunzione < NEW.dataFine AND NEW.dataFine <= dip_ind.dataFine) OR --Non posso essere licenziato nel bel mezzo di un altro contratto
		NEW.dataAssunzione < dip_ind.dataAssunzione AND NEW.dataFine > dip_ind.dataFine) THEN --Non posso avere un contratto che contiene un altro contratto
			lista_contratti := CONCAT(lista_contratti, dip_ind.Matricola || ', ');
		END IF;

	END LOOP;
	CLOSE cursore;

	IF lista_contratti <> '' THEN
		lista_contratti := SUBSTR(lista_contratti, 1, LENGTH(lista_contratti)-2);
		RAISE EXCEPTION 'Non è stato possibile stipulare il contratto con matricola % per %. La persona ha ancora un contratto in corso o vi è un conflitto tra la data di assunzione (o di fine) e i seguenti contratti: %', NEW.Matricola, NEW.codFiscale, lista_contratti;
	END IF;
	
	RETURN NEW;
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE TRIGGER c_tr_assunzione_coerente
BEFORE INSERT OR UPDATE OF codFiscale, dataAssunzione, dataFine
ON azienda.DIP_INDETERMINATO
FOR EACH ROW
EXECUTE FUNCTION azienda.fn_assunzione_coerente();

-------------------------------------------------------------------------------------------------------------------------------------

/*
La funzione viene eseguita dopo l'aggiornamento della data di fine di un dipendente e controlla se la data è antecedente alla data corrente. 
In tal caso, la funzione elimina tutte le afferenze correlate al dipendente nella tabella "AFFERIRE" e restituisce un messaggio di avviso. 
Altrimenti, la funzione restituisce un messaggio di avviso informando che le afferenze ai laboratori saranno mantenute.
*/

CREATE OR REPLACE FUNCTION azienda.fn_delete_dipInd_afferenze()
RETURNS TRIGGER
AS $$
BEGIN
    --se viene impostata una datafine per il dipendente precedente al momento in cui viene innescato il trigger, vengono eliminate le afferenze,
    --altrimenti verranno mantenute le afferenze sino la data specificata.

    IF NEW.dataFine <= DATE(NOW()) THEN
    --eliminazione di tutte le tuple correlate all'impiegato in AFFERIRE
        DELETE FROM azienda.AFFERIRE
        WHERE Matricola = OLD.Matricola;

        RAISE NOTICE 'Eliminate tutte le afferenze della matricola % non più attiva!', OLD.Matricola;
    ELSE
        RAISE NOTICE 'Siccome la dataFine inserita % è successiva rispetto la data corrente %, verranno mantenute tutte le afferenze ai laboratori.', NEW.dataFine, DATE(NOW());
    END IF;

    RETURN NEW;
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE TRIGGER tr_delete_dipInd_afferenze
AFTER UPDATE OF dataFine
ON azienda.DIP_INDETERMINATO
FOR EACH ROW
WHEN (OLD.dataFine IS DISTINCT FROM NEW.DataFine AND NEW.dataFine IS NOT NULL)
EXECUTE FUNCTION azienda.fn_delete_dipInd_afferenze();

-----------------------------------------------------------------------------------------------------------------------------------

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

---------------------------------------------------------------------------------------------------------------------------------
--										TRIGGERS PER azienda.SCATTO_CARRIERA
---------------------------------------------------------------------------------------------------------------------------------

--Trigger che modifica all'inserimento il tipo dello scatto nel formato corretto (esempio: jUniOR -> Junior)
--SCATTO CARRIERA
CREATE OR REPLACE FUNCTION azienda.fn_nice_looking_domain_sc() 
RETURNS trigger 
AS
$$
BEGIN
	NEW.tipo = CONCAT(UPPER(SUBSTR(NEW.tipo, 1, 1)), LOWER(SUBSTR(NEW.Tipo, 2, LENGTH(NEW.Tipo))));
	RETURN NEW;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER a_tr_nice_looking_domain_sc
BEFORE INSERT OR UPDATE OF tipo ON azienda.SCATTO_CARRIERA
FOR EACH ROW
EXECUTE FUNCTION azienda.fn_nice_looking_domain_sc();

---------------------------------------------------------------------------------------------------------------------------------

--Trigger che verifica la correttezza degli scatti a Middle e a Senior rispetto alla data di assunzione e al tipo del dipendente

CREATE OR REPLACE FUNCTION azienda.fn_verifica_scatto_tipo_IU() 
RETURNS trigger 
AS
$$
DECLARE
    dati_matricola RECORD;
BEGIN
    SELECT Tipo, dataAssunzione INTO dati_matricola
    FROM azienda.dip_indeterminato
    WHERE Matricola = NEW.Matricola;

    --Non posso registrare lo scatto di una matricola che non esiste
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Matricola % non esistente', NEW.Matricola;
    END IF;

    --Non posso registrare lo scatto a Middle di una matricola Junior
    IF NEW.Tipo = 'Middle' AND dati_matricola.Tipo = 'Junior' THEN
        RAISE EXCEPTION 'La matricola % è "Junior"! Impossibile registrare lo scatto da "Junior" a "Middle"', NEW.Matricola;
    END IF;

    --Non posso registrare lo scatto a Middle con una data sbagliata
    IF NEW.Tipo = 'Middle' AND NEW.Data <> CAST(dati_matricola.dataAssunzione + interval '3 years' AS DATE) THEN
        RAISE EXCEPTION 'Per la matricola %, lo scatto da "Junior" a "Middle" deve essere in data %!', NEW.Matricola, CAST(dati_matricola.dataAssunzione + interval '3 years' AS DATE);
    END IF;

    --Non posso registrare lo scatto a Senior di una matricola Middle o Junior
    IF NEW.Tipo = 'Senior' AND (dati_matricola.Tipo = 'Middle' OR dati_matricola.Tipo = 'Junior') THEN
        RAISE EXCEPTION 'La matricola % è "Middle"! Impossibile registrare lo scatto da "Middle" a "Senior"', NEW.Matricola;
    END IF;

    --Non posso registrare lo scatto a Senior con una data sbagliata
    IF NEW.Tipo = 'Senior' AND NEW.Data <> CAST(dati_matricola.dataAssunzione + interval '7 years' AS DATE) THEN
        RAISE EXCEPTION 'Per la matricola %, lo scatto da "Middle" a "Senior" deve essere in data %!', NEW.Matricola, CAST(dati_matricola.dataAssunzione + interval '7 years' AS DATE);
    END IF;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER b_tr_verifica_scatto_tipo_IU
BEFORE INSERT OR UPDATE ON azienda.SCATTO_CARRIERA
FOR EACH ROW
WHEN (NEW.Tipo = 'Middle' OR NEW.Tipo = 'Senior')
EXECUTE FUNCTION azienda.fn_verifica_scatto_tipo_IU();

/* 
All'interno del trigger, non è necessario controllare che la data dello scatto sia compresa tra la data di assunzione e la data di fine del dipendente. 
Questo perché, nel contesto specifico in cui il trigger viene utilizzato, la data esatta in cui avverrà lo scatto è già nota e verrà inserita nel database in modo accurato.
Inoltre, è possibile garantire che la matricola sia del tipo corretto grazie al controllo effettuato in fase di inserimento del dipendente. 
Analogamente, è già stata verificata la correttezza della data dello scatto grazie ad un altro trigger (verifica_tipo).
*/

---------------------------------------------------------------------------------------------------------------------------------

--Trigger che verifica la correttezza degli scatti a Middle e a Senior rispetto alla data di assunzione e al tipo del dipendente

CREATE OR REPLACE FUNCTION azienda.fn_verifica_scatto_tipo_D() 
RETURNS trigger 
AS
$$
DECLARE
    dati_matricola RECORD;
    numero_anni_trascorsi INTEGER := 0;
BEGIN
    SELECT Tipo INTO dati_matricola
    FROM azienda.dip_indeterminato
    WHERE Matricola = OLD.Matricola;

    --Non posso eliminare lo scatto a Senior di una matricola Senior
    IF OLD.Tipo = 'Senior' AND dati_matricola.Tipo = 'Senior' THEN
        RAISE EXCEPTION 'La matricola % è "Senior"! Impossibile eliminare lo scatto da "Middle" a "Senior"', OLD.Matricola;
    END IF;

    --Non posso eliminare lo scatto a Middle di una matricola Middle o Senior
    IF OLD.Tipo = 'Middle' AND (dati_matricola.Tipo = 'Middle' OR dati_matricola.Tipo = 'Senior') THEN
        RAISE EXCEPTION 'La matricola % è "%"! Impossibile eliminare lo scatto da "Junior" a "Middle"', OLD.Matricola, dati_matricola.Tipo;
    END IF;

    RETURN OLD;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER b_tr_verifica_scatto_tipo_D
BEFORE DELETE ON azienda.SCATTO_CARRIERA
FOR EACH ROW
WHEN (OLD.Tipo = 'Middle' OR OLD.Tipo = 'Senior')
EXECUTE FUNCTION azienda.fn_verifica_scatto_tipo_D();

---------------------------------------------------------------------------------------------------------------------------------

-- Trigger che, se inserisco lo scatto a dirigente, verifica che non sia una ripetizione
-- e che gli scatti della vecchia matricola (nel caso dell'update) siano ancora coerenti

CREATE OR REPLACE FUNCTION azienda.fn_verifica_scatto_dirigente_IU() RETURNS trigger AS
$$
DECLARE
    --Prendo tutti gli scatti della nuova matricola, escludendo la tupla appena modificata
    cursore_nuova_matricola CURSOR FOR
        SELECT Tipo, Data
        FROM azienda.scatto_carriera
        WHERE Matricola = NEW.Matricola AND (Tipo = 'Rimosso da dirigente' OR Tipo = 'Promosso a dirigente')
		ORDER BY Data ASC; --Le tuple andranno da quella più lontana a quella più vicina a oggi;


    --Prendo tutti gli scatti della vecchia matricola, escludendo anche quello che verrà modificato (o eliminato)
    cursore_vecchia_matricola CURSOR FOR 
        SELECT Tipo, Data
        FROM azienda.scatto_carriera
        WHERE Matricola = OLD.Matricola AND (Tipo = 'Rimosso da dirigente' OR Tipo = 'Promosso a dirigente')
		ORDER BY Data ASC; --Le tuple andranno da quella più lontana a quella più vicina a oggi;

    scatto_attuale RECORD;
    scatto_precedente RECORD;

    dati_matricola RECORD;
    looped BOOLEAN := FALSE;
BEGIN
    SELECT dataAssunzione, dataFine, Dirigente INTO dati_matricola
    FROM azienda.dip_indeterminato
    WHERE Matricola = NEW.Matricola;


    --Non posso registrare lo scatto di una matricola che non esiste
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Matricola % non esistente', NEW.Matricola;
    END IF;


    --Update su Matricola
    IF OLD.Matricola IS NOT NULL AND NEW.Matricola <> OLD.Matricola THEN
        OPEN cursore_vecchia_matricola;
        FETCH cursore_vecchia_matricola INTO scatto_precedente;

        IF FOUND THEN --Mi è rimasto almeno uno scatto. Verifico che il primo sia "Promosso a dirigente"
            IF scatto_precedente.Tipo <> 'Promosso a dirigente' THEN
                RAISE EXCEPTION 'Cambiando lo scatto di %, il primo scatto risulta essere "Rimosso da dirigente"', OLD.Matricola;
            END IF;

            LOOP
                FETCH cursore_vecchia_matricola INTO scatto_attuale;
                EXIT WHEN NOT FOUND;

                IF scatto_precedente.Tipo = scatto_attuale.Tipo THEN --Verifico la coerenza negli scatti rimanenti
                    RAISE EXCEPTION 'Lo scatto in data % è uguale a quello in data % per la matricola %', scatto_precedente.Data, scatto_attuale.Tipo, OLD.Matricola;
                END IF;

                scatto_precedente = scatto_attuale; --Aggiorno gli scatti da confrontare
            END LOOP;
        END IF;
        CLOSE cursore_vecchia_matricola;
    END IF;


    --Non posso registrare lo scatto di un dipendente fuori servizio
    IF dati_matricola.dataFine IS NULL THEN
        IF NEW.Data < dati_matricola.dataAssunzione THEN
            RAISE EXCEPTION 'La matricola % non può essere dirigente (o essere rimosso da dirigente) prima di essere assunta!', NEW.Matricola;
        END IF;
    ELSE
        IF NEW.Data < dati_matricola.dataAssunzione OR NEW.Data > dati_matricola.dataFine THEN
            RAISE EXCEPTION 'La matricola % non può essere dirigente (o essere rimosso da dirigente) fuori dal suo periodo di servizio!', NEW.Matricola;
        END IF;
    END IF;


    --Verifica la coerenza nell'alternanza degli scatti
    OPEN cursore_nuova_matricola;
    FETCH cursore_nuova_matricola INTO scatto_precedente;

    --Il primo scatto e DEVE essere per forza "Promosso a dirigente"
    IF scatto_precedente.Tipo <> 'Promosso a dirigente' THEN
        RAISE EXCEPTION 'Il dipendente % non può avere come primo scatto "Rimosso da dirigente"!', NEW.Matricola;
    END IF;
    
    LOOP --Verifico che ci siano altri scatti
        FETCH cursore_nuova_matricola INTO scatto_attuale; --Lo scatto successivo sarà più recente di quello già preso
        EXIT WHEN NOT FOUND;

        --Devo verificare che sia verificata l'alternanza tra scatti. Essendo le tuple ordinate asc, scatto_precedente.Data < scatto_attuale.Data
        IF scatto_precedente.Tipo = scatto_attuale.Tipo THEN
            RAISE EXCEPTION 'Lo scatto in data % è uguale a quello in data % per la matricola %', scatto_precedente.Data, scatto_attuale.Data, NEW.Matricola;
        ELSIF scatto_precedente.Data = scatto_attuale.Data THEN
            RAISE EXCEPTION 'Il dipendente % ha due scatti dirigenziali in data %', NEW.Matricola, scatto_precedente.Data;
        END IF;

        scatto_precedente = scatto_attuale; --Aggiorno gli scatti da confrontare
    END LOOP;
    CLOSE cursore_nuova_matricola;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER a_tr_verifica_scatto_dirigente_IU
AFTER INSERT OR UPDATE ON azienda.SCATTO_CARRIERA
FOR EACH ROW
WHEN (NEW.Tipo = 'Rimosso da dirigente' OR NEW.Tipo = 'Promosso a dirigente')
EXECUTE FUNCTION azienda.fn_verifica_scatto_dirigente_IU();

---------------------------------------------------------------------------------------------------------------------------------

-- Trigger che, se rimuovo lo scatto a dirigente, verifica che non si sia creata una ripetizione

CREATE OR REPLACE FUNCTION azienda.fn_verifica_scatto_dirigente_D() RETURNS trigger AS
$$
DECLARE
    --Prendo tutti gli scatti della vecchia matricola
    cursore_vecchia_matricola CURSOR FOR 
        SELECT Tipo, Data
        FROM azienda.scatto_carriera
        WHERE Matricola = OLD.Matricola AND (Tipo = 'Rimosso da dirigente' OR Tipo = 'Promosso a dirigente')
        ORDER BY Data ASC; --Le tuple andranno da quella più lontana a quella più vicina a oggi;

    scatto_attuale RECORD;
    scatto_precedente RECORD;
BEGIN
    --Verifico che ci sia ancora coerenza tra gli scatti della vecchia matricola
    OPEN cursore_vecchia_matricola;
    FETCH cursore_vecchia_matricola INTO scatto_precedente;

    IF FOUND THEN
        IF scatto_precedente.Tipo <> 'Promosso a dirigente' THEN
            RAISE EXCEPTION 'Eliminando lo scatto di %, il primo scatto risulta essere "Rimosso da dirigente"', OLD.Matricola;
        END IF;

        LOOP
            FETCH cursore_vecchia_matricola INTO scatto_attuale;
            EXIT WHEN NOT FOUND;

            IF scatto_precedente.Tipo = scatto_attuale.Tipo THEN --Verifico la coerenza negli scatti rimanenti
                RAISE EXCEPTION 'Lo scatto in data % è uguale a quello in data % per la matricola %', scatto_precedente.Data, scatto_attuale.Data, OLD.Matricola;
            END IF;

            scatto_precedente = scatto_attuale; --Aggiorno gli scatti da confrontare
        END LOOP;
    END IF;
    CLOSE cursore_vecchia_matricola;

    RETURN OLD;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER a_tr_verifica_scatto_dirigente_D
AFTER DELETE ON azienda.SCATTO_CARRIERA
FOR EACH ROW
WHEN (OLD.Tipo = 'Rimosso da dirigente' OR OLD.Tipo = 'Promosso a dirigente')
EXECUTE FUNCTION azienda.fn_verifica_scatto_dirigente_D();

---------------------------------------------------------------------------------------------------------------------------------

--Trigger che aggiorna lo stato dirigenziale di un dipendente sulla base dello scatto più recente

CREATE OR REPLACE FUNCTION azienda.fn_aggiorna_dirigente_IU() RETURNS TRIGGER AS $$
DECLARE
    tipo_matricola azienda.scatto_carriera.tipo%TYPE;
    dirigente_matricola azienda.dip_indeterminato.Dirigente%TYPE;
BEGIN
    --Aggiorno la dirigenza della vecchia matricola
    IF OLD.Matricola IS NOT NULL AND NEW.Matricola <> OLD.Matricola THEN --Update su Matricola

        SELECT Dirigente INTO dirigente_matricola --Prendo l'attuale stato dirigenziale della vecchia matricola
        FROM azienda.dip_indeterminato
        WHERE Matricola = OLD.Matricola;

        SELECT Tipo INTO tipo_matricola --Prendo l'ultimo scatto dirigenziale della vecchia matricola
        FROM azienda.scatto_carriera
        WHERE Matricola = OLD.Matricola AND 
              (Tipo = 'Promosso a dirigente' OR Tipo = 'Rimosso da dirigente')
        ORDER BY Data DESC
        LIMIT 1;

        IF NOT FOUND THEN --Non ho più lo scatto a dirigente per la vecchia matricola, quindi deve tornare a DEFAULT, cioè FALSE
            UPDATE azienda.dip_indetermianto
            SET Dirigente = FALSE
            WHERE Matricola = OLD.Matricola;
        ELSE --Verifico che ci sia coerenza, altrimenti aggiorno
            IF tipo_matricola = 'Promosso a dirigente' THEN
                IF dirigente_matricola = FALSE THEN
                    UPDATE azienda.dip_indeterminato
                    SET Dirigente = TRUE
                    WHERE matricola = OLD.Matricola;
                END IF;
            ELSE
                IF dirigente_matricola = TRUE THEN
                    UPDATE azienda.dip_indeterminato
                    SET Dirigente = FALSE
                    WHERE matricola = OLD.Matricola;
                END IF;
            END IF;
        END IF;
    END IF;



    --Devo verificare che l'attuale stato dirigenziale della nuova matricola è aggiornato, altrimenti aggiorna
    SELECT Tipo INTO tipo_matricola --Prendo l'ultimo scatto dirigenziale della nuova matricola
    FROM azienda.scatto_carriera
    WHERE Matricola = NEW.Matricola AND 
            (Tipo = 'Promosso a dirigente' OR Tipo = 'Rimosso da dirigente')
    ORDER BY Data DESC
    LIMIT 1;

    SELECT Dirigente INTO dirigente_matricola --Prendo l'attuale stato dirigenziale della nuova matricola
    FROM azienda.dip_indeterminato
    WHERE Matricola = NEW.Matricola;

    --Verifico che ci sia coerenza, altrimenti aggiorno
    IF tipo_matricola = 'Promosso a dirigente' THEN
        IF dirigente_matricola = FALSE THEN
            UPDATE azienda.dip_indeterminato
            SET Dirigente = TRUE
            WHERE matricola = NEW.Matricola;
        END IF;
    ELSE
        IF dirigente_matricola = TRUE THEN
            UPDATE azienda.dip_indeterminato
            SET Dirigente = FALSE
            WHERE matricola = NEW.Matricola;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql; 
 
CREATE OR REPLACE TRIGGER b_tr_aggiorna_dirigente_IU
AFTER INSERT OR UPDATE ON azienda.SCATTO_CARRIERA
FOR EACH ROW 
WHEN (NEW.Tipo IN ('Promosso a dirigente', 'Rimosso da dirigente')) 
EXECUTE FUNCTION azienda.fn_aggiorna_dirigente_IU();

---------------------------------------------------------------------------------------------------------------------------------

--Trigger che aggiorna lo stato dirigenziale di un dipendente sulla base dello scatto più recente

CREATE OR REPLACE FUNCTION azienda.fn_aggiorna_dirigente_D() RETURNS TRIGGER AS $$
DECLARE
    tipo_matricola azienda.scatto_carriera.tipo%TYPE;
    dirigente_matricola azienda.dip_indeterminato.Dirigente%TYPE;
BEGIN
    SELECT Dirigente INTO dirigente_matricola --Prendo l'attuale stato dirigenziale della vecchia matricola
    FROM azienda.dip_indeterminato
    WHERE Matricola = OLD.Matricola;


    --Aggiorno la dirigenza della vecchia matricola
    SELECT Tipo INTO tipo_matricola --Prendo l'ultimo scatto dirigenziale della vecchia matricola
    FROM azienda.scatto_carriera
    WHERE Matricola = OLD.Matricola AND 
          (Tipo = 'Promosso a dirigente' OR Tipo = 'Rimosso da dirigente')
    ORDER BY Data DESC
    LIMIT 1;

    IF NOT FOUND THEN --Non ho più lo scatto a dirigente per la vecchia matricola, quindi deve tornare a DEFAULT, cioè FALSE
        UPDATE azienda.dip_indeterminato
        SET Dirigente = FALSE
        WHERE Matricola = OLD.Matricola;
    ELSE --Ho ancora uno scatto e devo impostare il tipo dello scatto più recente
        IF tipo_matricola = 'Promosso a dirigente' THEN
            IF dirigente_matricola = FALSE THEN
                UPDATE azienda.dip_indeterminato
                SET Dirigente = TRUE
                WHERE matricola = OLD.Matricola;
            END IF;
        ELSE --Lo scatto più recente è "Rimosso da dirigente"
            IF dirigente_matricola = TRUE THEN
                UPDATE azienda.dip_indeterminato
                SET Dirigente = FALSE
                WHERE matricola = OLD.Matricola;
            END IF;
        END IF;
    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql; 
 
CREATE OR REPLACE TRIGGER b_tr_aggiorna_dirigente_D
AFTER DELETE ON azienda.SCATTO_CARRIERA
FOR EACH ROW 
WHEN (OLD.Tipo IN ('Promosso a dirigente', 'Rimosso da dirigente')) 
EXECUTE FUNCTION azienda.fn_aggiorna_dirigente_D();

---------------------------------------------------------------------------------------------------------------------------------
--										TRIGGERS PER azienda.LABORATORIO
---------------------------------------------------------------------------------------------------------------------------------

--RESPONSABILE SCIENTIFICO
--controlla se un dipendente assegnato come responsabile scientifico di un progetto è senior o meno
CREATE OR REPLACE FUNCTION azienda.fn_res_scientifico_senior()
RETURNS trigger
AS
$$
DECLARE
	dip_ind RECORD;
BEGIN
	SELECT Nome, Cognome, Matricola, Tipo, DataFine INTO dip_ind
	FROM azienda.DIP_INDETERMINATO
	WHERE Matricola = NEW.Responsabile_Scientifico;
	
	IF dip_ind.Matricola IS NULL THEN
        RAISE EXCEPTION 'La matricola % non esiste', NEW.Responsabile_Scientifico;
    END IF;

	IF dip_ind.Tipo <> 'Senior' THEN
		RAISE EXCEPTION 'Il dipendente "% %" con matricola % non è di tipo "Senior"! Non può essere nominato Responsabile scientifico per il laboratorio %', dip_ind.Nome, dip_ind.Cognome, dip_ind.Matricola, NEW.Nome;
	END IF;
	
	IF dip_ind.DataFine IS NOT NULL THEN
		RAISE EXCEPTION 'Il dipendente "% %" con matricola % ha una data di licenziamento! Non è possibile assegnare l''incarico di Responsabile Scientifico del laboratorio %!', dip_ind.Nome, dip_ind.Cognome, dip_ind.Matricola, NEW.Nome;
	END IF;

	RETURN NEW;

END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tr_res_scientifico_senior
BEFORE INSERT OR UPDATE 
OF Responsabile_Scientifico ON azienda.LABORATORIO
FOR EACH ROW
EXECUTE FUNCTION azienda.fn_res_scientifico_senior();

---------------------------------------------------------------------------------------------------------------------------------

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

---------------------------------------------------------------------------------------------------------------------------------

/*
Prima della modifica di un responsabile scientifico in azienda.LABORATORIO per un dato laboratorio, viene verificato se il nuovo responsabile scientifico è un afferente al laboratorio o meno. 
Se non lo è, la vecchia tupla del responsabile scientifico viene sostituita con quella nuova in azienda.AFFERIRE. 
Se invece il nuovo responsabile scientifico è un afferente, il controllo passa al trigger aggiungi_lab_res_scient_afferente_U. 
Nel primo caso, verrà rimossa l'afferenza dell'OLD.Responsabile scientifico, quindi quando il controllo passerà al trigger aggiungi_lab_res_scient_afferente_U, 
il suo corpo verrà ignorato in quanto non troverà in azienda.AFFERIRE l'afferenza del vecchio responsabile scientifico.
*/

CREATE OR REPLACE FUNCTION azienda.fn_aggiungi_lab_res_scient_non_afferente_U()
RETURNS TRIGGER
AS $$
BEGIN

    --se il nuovo responsabile scientifico non è già un afferente al laboratorio, allora bisogna sostituirlo con il responsabile
    --se viene ignorato l'if significa che il nuovo responsabile scientifico è già un afferente del laboratorio
    IF NOT EXISTS (SELECT *
                    FROM azienda.AFFERIRE
                    WHERE Matricola = NEW.Responsabile_scientifico AND
                    nomeLab = OLD.nome) THEN

        --se non viene specificata anche la condizione nomeLab = OLD.nome, verrebbero sostituite tutte le afferenze (anche quelle semplici)
        --del vecchio responsabile scientifico, facendo risultare quest'ultimo come NON afferente ad alcun laboratorio
        UPDATE azienda.AFFERIRE
        SET Matricola = NEW.Responsabile_Scientifico
        WHERE Matricola = OLD.Responsabile_Scientifico AND nomeLab = OLD.nome;

    RAISE NOTICE 'L''afferenza del vecchio responsabile scientifico % è stata sostituita con l''afferenza del nuovo responsabile scientifico % per il laboratorio %
Non è stata conservata l''afferenza del vecchio responsabile scientifico %, che ora non afferirà più al laboratorio %'
                      , OLD.Responsabile_Scientifico, NEW.Responsabile_Scientifico, NEW.nome, OLD.Responsabile_Scientifico, NEW.nome;

    END IF;

    RETURN NEW;
END;
$$
LANGUAGE PLPGSQL;
CREATE OR REPLACE TRIGGER tr_z_aggiungi_lab_res_scient_non_afferente_U
BEFORE UPDATE OF Responsabile_Scientifico
ON azienda.LABORATORIO
FOR EACH ROW
WHEN (OLD.nome <> NEW.nome OR OLD.Responsabile_scientifico <> NEW.Responsabile_scientifico)
EXECUTE FUNCTION azienda.fn_aggiungi_lab_res_scient_non_afferente_U();
---------------------------------------------------------------------------------------------------------------------------------

/*
Quando si è aggiornato il Responsabile scientifico con una matricola che non afferiva già al laboratorio, questo trigger non ha effetto.
Altrimenti, se il corpo del trigger precedente tr_z_aggiungi_lab_res_scient_non_afferente_U è stato ignorato, significa che siamo ancora in grado di reperire in azienda.AFFERIRE
l'afferenza del vecchio responsabile scientifico, stando a significare che il nuovo responsabile scientifico già afferiva al laboratorio.
In questo caso, il controllo entra nell'IF e viene eliminata l'afferenza del vecchio responsabile scientifico, e quella nuova già c'è.
*/

CREATE OR REPLACE FUNCTION azienda.fn_aggiungi_lab_res_scient_afferente_U()
RETURNS TRIGGER
AS $$
BEGIN

    --se il nuovo responsabile scientifico è già un afferente del laboratorio
    --bisogna eliminare la vecchia afferenza del vecchio responsabile scientifico
    IF EXISTS (SELECT *
               FROM azienda.AFFERIRE
               WHERE Matricola = OLD.Responsabile_scientifico AND
               nomeLab = OLD.nome) THEN

    --se la nuova matricola Resp_scient è già un afferente al lab,
    --elimino direttamente quella del vecchio resp, altrimenti faccio l'update
    DELETE FROM azienda.AFFERIRE
    WHERE nomeLab = OLD.nome AND Matricola = OLD.Responsabile_scientifico;

    RAISE NOTICE 'L''afferenza del vecchio responsabile scientifico % è stata sostituita con l''afferenza del nuovo responsabile scientifico % per il laboratorio %
Non è stata conservata l''afferenza del vecchio responsabile scientifico %, che ora non afferirà più al laboratorio %'
                      , OLD.Responsabile_Scientifico, NEW.Responsabile_Scientifico, NEW.nome, OLD.Responsabile_Scientifico, NEW.nome;

    END IF;

    RETURN NEW;
END;
$$
LANGUAGE PLPGSQL;
CREATE OR REPLACE TRIGGER tr_z_aggiungi_lab_res_scient_afferente_U
AFTER UPDATE OF Responsabile_Scientifico
ON azienda.LABORATORIO
FOR EACH ROW
WHEN (OLD.nome <> NEW.nome OR OLD.Responsabile_scientifico <> NEW.Responsabile_scientifico)
EXECUTE FUNCTION azienda.fn_aggiungi_lab_res_scient_afferente_U();

---------------------------------------------------------------------------------------------------------------------------------

/*
Si vuole impedire la modifica diretta del campo "nAfferenti" nella tabella "azienda.LABORATORIO".
Per farlo, è stato creato un trigger che si attiva prima dell'aggiornamento del campo "nAfferenti". 
In questo modo, se si cerca di modificare direttamente il campo "nAfferenti", il trigger viene attivato automaticamente, evitando così la modifica diretta del campo.
La funzione "pg_trigger_depth()" viene utilizzata per controllare se il trigger è stato attivato. 
Se la funzione restituisce un valore maggiore di 0, significa che il trigger è stato attivato e quindi la modifica è stata effettuata in modo corretto. 
In caso contrario, se la funzione restituisce 0, significa che la modifica è stata effettuata direttamente sulla tabella senza attivare il trigger, e quindi la modifica viene impedita.
*/

CREATE OR REPLACE FUNCTION azienda.fn_blocco_nAfferenti()
RETURNS TRIGGER
AS $$
BEGIN

    IF OLD.nome IS NULL THEN --Inserimento
        IF NEW.nAfferenti <> 1 THEN
            RAISE NOTICE 'Non è possibile inserire direttamente il numero di afferenti al laboratorio %!', NEW.nome;
            NEW.nAfferenti = 1;
        END IF;
    ELSE --Update
        IF NEW.nAfferenti <> OLD.nAfferenti THEN
            RAISE NOTICE 'Non è possibile modificare direttamente il numero di afferenti al laboratorio %!', NEW.nome;
            NEW.nAfferenti = OLD.nAfferenti;
        END IF;

    END IF;

    RETURN NEW;
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE TRIGGER tr_blocco_nAfferenti
BEFORE INSERT OR UPDATE OF nAfferenti
ON azienda.LABORATORIO
FOR EACH ROW
WHEN (pg_trigger_depth() < 1)
EXECUTE FUNCTION azienda.fn_blocco_nAfferenti();

---------------------------------------------------------------------------------------------------------------------------------
--										TRIGGERS PER azienda.AFFERIRE
---------------------------------------------------------------------------------------------------------------------------------

/*
Il trigger intende verificare che una matricola esista, che il laboratorio esista, che la matricola sia attiva
e che non si stia andando ad aggiungere un'afferenza di un dipendente in dirittura di licenziamento
*/

CREATE OR REPLACE FUNCTION azienda.fn_verifica_afferenza()
RETURNS TRIGGER
AS $$
BEGIN
    --Si verifica che la matricola ed il laboratorio specificati esistano effettivamente
    --(questo viene fatto solo per personalizzare il messaggio di errore, dal punto di vista concettuale viene già verificato dal vincolo di integrità referenziale)
    IF NOT EXISTS (SELECT * FROM azienda.DIP_INDETERMINATO WHERE Matricola = NEW.Matricola) THEN
        RAISE EXCEPTION 'La matricola % non esiste!', NEW.Matricola;
    END IF;

    IF NOT EXISTS (SELECT * FROM azienda.LABORATORIO WHERE nome = NEW.nomeLab) THEN
        RAISE EXCEPTION 'Il laboratorio % non esiste!', NEW.nomeLab;
    END IF;

    --Si verifica che il dipendente a tempo indeterminato non presenti una dataFine, ovvero che sia ancora attivo nell'azienda
    IF (SELECT dataFine
        FROM azienda.DIP_INDETERMINATO
        WHERE Matricola = NEW.Matricola) IS NOT NULL THEN

        RAISE EXCEPTION 'La matricola % ha una data di licenziamento! Non è possibile assegnare la nuova afferenza al laboratorio %.', NEW.Matricola, NEW.nomeLab;
    END IF;

    RETURN NEW;
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE TRIGGER tr_verifica_afferenza
BEFORE INSERT ON azienda.AFFERIRE
FOR EACH ROW
EXECUTE FUNCTION azienda.fn_verifica_afferenza();


-------------------------------------------------------------------------------------------------------------------

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


-------------------------------------------------------------------------------------------------------

/*
Si intende verificare, dopo che è stata registrata l'afferenza di una matricola ad un laboratorio, che, per scopi di coerenza con il corrispettivo nAfferenti del laboratorio,
la matricola non sia il responsabile scientifico del laboratorio in questione. Se così fosse, si lascia inalterato in nAfferenti di quel laboratorio, poichè già contato di DEFAULT.
*/

CREATE OR REPLACE FUNCTION azienda.fn_change_nAfferenti_I()
RETURNS TRIGGER
AS $$
BEGIN

    --controlliamo se la matricola appena inserita è responsabile scientifico del laboratorio appena inserito
    IF NEW.Matricola = (SELECT Responsabile_scientifico
                        FROM azienda.LABORATORIO 
                        WHERE nome = NEW.nomeLab) THEN
                        
        RAISE NOTICE 'L''afferenza del Responsabile Scientifico % di % è già conteggiata!', NEW.Matricola, NEW.nomeLab;
    ELSE
        --nel caso sia stata inserita una coppia (laboratorio, matricola) dove la matricola non è responsabile scientifico del laboratorio
        --incrementa il numero di afferenti di 1 di quel laboratorio
        UPDATE azienda.LABORATORIO
        SET nAfferenti = nAfferenti + 1
        WHERE nome = NEW.nomeLab;

        RAISE NOTICE 'Incrementato di 1 il numero di afferenti del laboratorio %!', NEW.nomeLab;
    END IF;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tr_change_nAfferenti_I
AFTER INSERT
ON azienda.AFFERIRE
FOR EACH ROW
EXECUTE FUNCTION azienda.fn_change_nAfferenti_I();

-------------------------------------------------------------------------------------------------------

/*
Si intende rendere coerente il campo nAfferenti per eventuali modifiche delle afferenze in cui questi ultimi sono coinvolti.
Disponiamo di 3 casi da analizzare:
Per una tupla (Matricola, nomeLab)
1) Nel caso venga aggiornata solo la matricola, il laboratorio non perde alcuna afferenza, pertanto nAfferenti rimane invariato
2) Nel caso venga aggiornato solo il laboratorio, il vecchio laboratorio perde una afferenza, mentre il nuovo la guadagna
3) Nel caso vengano aggiornati entrambi, il vecchio laboratorio perderà una afferenza, mentre il nuovo laboratorio ne guadagna una.
*/

CREATE OR REPLACE FUNCTION azienda.fn_change_nAfferenti_U()
RETURNS TRIGGER
AS $$
BEGIN
    --si controlla la condizione per coprire il caso di update su azienda.LABORATORIO
    --altrimenti il decremento non andrà mai a buon fine siccome non esiste più il vecchio laboratorio, già modificato
    --viene fatto per non far azionare il conteggio con l'update del nome di laboratorio in CASCADE
    IF EXISTS (SELECT *
               FROM azienda.LABORATORIO
               WHERE nome = OLD.nomeLab) THEN

        --nel caso sia stata modificata una tupla (laboratorio, matricola) dove la matricola non è responsabile scientifico del laboratorio
        --si decrementa il numero di afferenti di 1 del vecchio laboratorio e si incrementa invece il numero di afferenti di 1 del nuovo laboratorio.
        UPDATE azienda.LABORATORIO
        SET nAfferenti = nAfferenti - 1
        WHERE nome = OLD.nomeLab;

        RAISE NOTICE 'Decrementato di 1 il numero di afferenti del vecchio laboratorio %!', OLD.nomeLab;

        UPDATE azienda.LABORATORIO
        SET nAfferenti = nAfferenti + 1
        WHERE nome = NEW.nomeLab;

        RAISE NOTICE 'Incrementato di 1 il numero di afferenti del nuovo laboratorio %!', NEW.nomeLab;
    END IF;

    RETURN NEW;
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE TRIGGER tr_change_nAfferenti_U
AFTER UPDATE
ON azienda.AFFERIRE
FOR EACH ROW
WHEN (NEW.nomeLab <> OLD.nomeLab)
EXECUTE FUNCTION azienda.fn_change_nAfferenti_U();

-------------------------------------------------------------------------------------------------------

/*
Si intende verificare che, ogni qual volta viene effettuata una rimozione di una afferenza per un determinato laboratorio, il numero di afferenti
del laboratorio venga decrementato.
*/

CREATE OR REPLACE FUNCTION azienda.fn_change_nAfferenti_D()
RETURNS TRIGGER
AS $$
BEGIN

    UPDATE azienda.LABORATORIO
    SET nAfferenti = nAfferenti - 1
    WHERE nome = OLD.nomeLab;

    RAISE NOTICE 'Decrementato il numero di afferenti del laboratorio %!', OLD.nomeLab;

    RETURN OLD;
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE TRIGGER tr_change_nAfferenti_D
AFTER DELETE
ON azienda.AFFERIRE
FOR EACH ROW
EXECUTE FUNCTION azienda.fn_change_nAfferenti_D();

---------------------------------------------------------------------------------------------------------------------------------
--										TRIGGERS PER azienda.PROGETTO
---------------------------------------------------------------------------------------------------------------------------------

--REFERENTE SCIENTIFICO
--controlla se un dipendente assegnato come referente di un laboratorio è senior o meno
CREATE OR REPLACE FUNCTION azienda.fn_ref_scientifico_senior()
RETURNS TRIGGER
AS
$$
DECLARE
	dip_ind RECORD;
BEGIN
	SELECT Nome, Cognome, Matricola, Tipo, DataFine	INTO dip_ind
	FROM azienda.DIP_INDETERMINATO
	WHERE Matricola = NEW.Referente_Scientifico;
	
	IF dip_ind.Matricola IS NULL THEN

        RAISE EXCEPTION 'La matricola % non esiste', NEW.Referente_Scientifico;
    END IF;

	IF dip_ind.Tipo <> 'Senior' THEN

		RAISE EXCEPTION 'Il dipendente "% %" con matricola % non è di tipo "Senior"! Non è stato possibile assegnarlo come referente scientifico del progetto %', dip_ind.Nome, dip_ind.Cognome, dip_ind.Matricola, NEW.CUP;
	END IF;

	IF NEW.dataFine IS NULL THEN --Il progetto non è finito
		IF dip_ind.DataFine IS NOT NULL THEN
		    RAISE EXCEPTION 'Il dipendente "% %" con matricola % ha una data di licenziamento! Non è possibile assegnare l''incarico di Referente Scientifico al progetto %', dip_ind.Nome, dip_ind.Cognome, dip_ind.Matricola, NEW.CUP;
        END IF;

	ELSE --Il progetto è finito o conosciamo la dataFine
		IF dip_ind.DataFine IS NOT NULL AND dip_ind.DataFine < NEW.dataFine THEN --Se il dipendete che vogliamo inserire è stato licenziato, deve essere stato licenziato dopo la dataFine del progetto
			RAISE EXCEPTION 'Il dipendente "% %" con matricola % è stato licenziato prima della fine del progetto! Non è stato possibile assegnarlo come referente scientifico del progetto %', dip_ind.Nome, dip_ind.Cognome, dip_ind.Matricola, NEW.CUP;
		END IF;

	END IF;

	RETURN NEW;
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE TRIGGER tr_ref_scientifico_senior
BEFORE INSERT OR UPDATE OF Referente_Scientifico 
ON azienda.PROGETTO
FOR EACH ROW
EXECUTE FUNCTION azienda.fn_ref_scientifico_senior();

---------------------------------------------------------------------------------------------------------------------------------

--RESPONSABILE (Progetto)
--controlla se un dipendente assegnato come responsabile di un progetto è un dirigente o meno
CREATE OR REPLACE FUNCTION azienda.fn_res_progetto_dirigente()
RETURNS trigger
AS
$$
DECLARE
	dip_ind RECORD;
BEGIN
	SELECT Nome, Cognome, Matricola, Dirigente, DataFine INTO dip_ind
	FROM azienda.DIP_INDETERMINATO
	WHERE Matricola = NEW.Responsabile;
	
	IF dip_ind.Matricola IS NULL THEN
        RAISE EXCEPTION 'La matricola % non esiste', NEW.Responsabile;
    END IF;

	IF dip_ind.Dirigente <> TRUE THEN
		RAISE EXCEPTION 'Il dipendente "% %" con matricola % non è "Dirigente"! Non è stato possibile assegnarlo come responsabile del progetto %', dip_ind.Nome, dip_ind.Cognome, dip_ind.Matricola, NEW.CUP;
	END IF;

	IF NEW.dataFine IS NULL THEN --Il progetto non è finito
		IF dip_ind.DataFine IS NOT NULL THEN
		    RAISE EXCEPTION 'Il dipendente "% %" con matricola % ha una data di licenziamento! Non è possibile assegnare l''incarico di Responsabile al progetto %', dip_ind.Nome, dip_ind.Cognome, dip_ind.Matricola, NEW.CUP;
        END IF;
	
	ELSE --Il progetto è finito o conosciamo la dataFine
		IF dip_ind.DataFine IS NOT NULL AND dip_ind.DataFine < NEW.dataFine THEN --Se il dipendete che vogliamo inserire è stato licenziato, deve essere stato licenziato dopo la dataFine del progetto
			RAISE EXCEPTION 'Il dipendente "% %" con matricola % è stato licenziato prima della fine del progetto! Non è stato possibile assegnarlo come responsabile del progetto %', dip_ind.Nome, dip_ind.Cognome, dip_ind.Matricola, NEW.CUP;
		END IF;

	END IF;

	RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tr_res_progetto_dirigente
BEFORE INSERT OR UPDATE OF Responsabile
ON azienda.PROGETTO
FOR EACH ROW
EXECUTE FUNCTION azienda.fn_res_progetto_dirigente();

---------------------------------------------------------------------------------------------------------------------------------

--Trigger che impedisce qualsiasi modifica manuale a "costoAttrezzature" e "costoContrattiProgetto".
CREATE OR REPLACE FUNCTION azienda.fn_blocco_modifiche_costi() RETURNS trigger AS
$$
DECLARE
    half_budget azienda.EURO := (0.5 * NEW.Budget)-0.005;
BEGIN
    IF OLD.CostoAttrezzature IS NULL THEN --L'unico caso in cui può essere NULL è l'inserimento
        IF (NEW.costoAttrezzature <> 0 OR NEW.costoContrattiProgetto <> 0) THEN
            RAISE NOTICE E'Non puoi inserire manualmente il costo totale delle attrezzature o il costo totale dei contratti a progetto di %!\nBisogna comprare le attrezzature o i contratti relativi a questo progetto.\nL''inserimento a questi campi è stato ignorato', NEW.CUP;
            NEW.costoAttrezzature = 0;
            NEW.costoContrattiProgetto = 0;
        END IF;
    ELSE --Se non è l'inserimento, allora è un update
        IF (NEW.CostoAttrezzature <> OLD.costoAttrezzature OR NEW.costoContrattiProgetto <> OLD.costoContrattiProgetto) THEN 
            RAISE NOTICE E'Non puoi modificare manualmente il costo totale delle attrezzature o il costo totale dei contratti a progetto di %!\nBisogna modificare gli acquisti delle attrezzature o dei contratti relativi a questo progetto.\nLe modifiche di questi campi sono state ignorate', NEW.CUP;
            NEW.costoAttrezzature = OLD.costoAttrezzature;
            NEW.costoContrattiProgetto = OLD.costoContrattiProgetto;
        END IF;
    END IF;

    RETURN NEW;

END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tr_blocco_modifiche_costi
BEFORE INSERT OR UPDATE OF costoAttrezzature, costoContrattiProgetto ON azienda.PROGETTO
FOR EACH ROW
WHEN (pg_trigger_depth() < 1)
EXECUTE FUNCTION azienda.fn_blocco_modifiche_costi();

---------------------------------------------------------------------------------------------------------------------------------

--Trigger che impedisce la modifica del Budget tale da rendere illegale l'attuale costoAttrezzature o costoContrattiProgetto
CREATE OR REPLACE FUNCTION azienda.fn_verifica_budget_costi() RETURNS trigger AS
$$
DECLARE
    half_budget azienda.EURO := (0.5 * NEW.Budget)-0.005;
BEGIN
    IF ((half_budget < NEW.CostoAttrezzature) OR (half_budget < NEW.costoContrattiProgetto)) THEN
        RAISE EXCEPTION 'Non è stato possibile modificare il Budget da % a % perchè attualmente per il progetto % vi è una spesa in attrezzature o contratti a progetto superiore a % (il 50%% di %)! Modifica rifiutata.', OLD.Budget, NEW.Budget, NEW.CUP, half_budget, NEW.Budget;
    END IF;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tr_verifica_budget_costi
BEFORE UPDATE OF Budget ON azienda.PROGETTO
FOR EACH ROW
EXECUTE FUNCTION azienda.fn_verifica_budget_costi();

---------------------------------------------------------------------------------------------------------------------------------
--										TRIGGERS PER azienda.LAVORARE
---------------------------------------------------------------------------------------------------------------------------------

--verifica che ad un progetto non lavorino più di tre laboratori
--Il trigger utilizza una query per contare il numero di laboratori che lavorano a un progetto specifico. 
--Se il numero di laboratori che lavorano a un progetto supera o è uguale a tre, viene generato un messaggio di errore.

CREATE OR REPLACE FUNCTION azienda.fn_controllo_laboratori_progetto()
RETURNS trigger
AS
$$
DECLARE
	lavora_su RECORD;
	cup_exists RECORD;
	laboratorio_exists RECORD;
	numLabOnProg INTEGER := 0;
BEGIN
	SELECT * INTO cup_exists
	FROM azienda.PROGETTO 
	WHERE CUP = NEW.CUP;

	IF NOT FOUND THEN
		RAISE EXCEPTION 'Il progetto con CUP % non esiste', NEW.CUP;
	END IF;

	SELECT * INTO laboratorio_exists
	FROM azienda.LABORATORIO
	WHERE nome = NEW.nomeLab;

	IF NOT FOUND THEN
        RAISE EXCEPTION 'Il laboratorio % non esiste', NEW.nomeLab;
	END IF;

	SELECT * INTO lavora_su
	FROM azienda.LAVORARE
	WHERE CUP = NEW.CUP AND nomeLab = NEW.nomeLab;

	IF FOUND THEN
		RAISE EXCEPTION 'Il laboratorio % lavora già sul progetto con CUP %', NEW.nomeLab, NEW.CUP;
    END IF;

	SELECT COUNT(*) INTO numLabOnProg
	FROM azienda.LAVORARE
	WHERE CUP = NEW.CUP AND
		  nomeLab NOT IN
			(SELECT nomeLab
			 FROM azienda.LAVORARE
			 WHERE CUP = OLD.CUP AND nomeLab = OLD.nomeLab);

    --Se ci sono già 3 laboratori, non possono esserne aggiunti altri
	IF numLabOnProg >= 3 THEN

		RAISE EXCEPTION 'Non è possibile assegnare più di 3 laboratori ad un progetto! Il laboratorio % non può essere aggiunto al progetto %', NEW.nomeLab, NEW.CUP;
		--nel caso la condizione di controllo non venga soddisfatta, 
		--l'exception impedirà l'esecuzione del trigger.
	END IF;

	RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tr_controllo_laboratori_progetto
BEFORE INSERT OR UPDATE ON azienda.LAVORARE
FOR EACH ROW
EXECUTE FUNCTION azienda.fn_controllo_laboratori_progetto();


---------------------------------------------------------------------------------------------------------------------------------
--										TRIGGERS PER azienda.ATTREZZATURA
---------------------------------------------------------------------------------------------------------------------------------

/*
Si verifica che, prima di un inserimento di un'attrezzatura, oppure prima di un aggiornamento del laboratorio o del CUP per una data attrezzatura,
il nuovo laboratorio inserito lavori effettivamente per il nuovo progetto riportato

*/
CREATE OR REPLACE FUNCTION azienda.fn_coerenza_acquisto_attr_lab()
RETURNS TRIGGER
AS $$
DECLARE
    corrispondenze RECORD;
BEGIN

    --Si verifica che il laboratorio ed il progetto specificati esistano effettivamente
    --(questo viene fatto solo per personalizzare il messaggio di errore, dal punto di vista concettuale viene già verificato dal vincolo di integrità referenziale)
    IF NOT EXISTS (SELECT *
                   FROM azienda.LABORATORIO
                   WHERE nome = NEW.nomeLab) THEN
        RAISE EXCEPTION 'Il laboratorio % non esiste!', NEW.nomeLab;
    END IF;

    IF NOT EXISTS (SELECT *
                   FROM azienda.PROGETTO
                   WHERE CUP = NEW.CUP) THEN
        RAISE EXCEPTION 'Il progetto % non esiste!', NEW.CUP;
    END IF;

    IF NOT EXISTS (SELECT *
                   FROM azienda.LAVORARE
                   WHERE CUP = NEW.CUP AND nomeLab = NEW.nomeLab) THEN

        RAISE EXCEPTION 'Il laboratorio % non lavora per il progetto %, % non registrato come attrezzatura!', NEW.nomeLab, NEW.CUP, NEW.Descrizione;
    END IF;

    RETURN NEW;

END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE TRIGGER tr_coerenza_acquisto_attr_lab
BEFORE INSERT OR UPDATE OF nomeLab, CUP
ON azienda.ATTREZZATURA
FOR EACH ROW
WHEN (NEW.nomeLab IS NOT NULL AND NEW.CUP IS NOT NULL) 
EXECUTE FUNCTION azienda.fn_coerenza_acquisto_attr_lab();

---------------------------------------------------------------------------------------------------------------------------------

--Trigger che calcola il costo delle attrezzature così che non superi il budget (si deve adattare ad un eventuale update del costo delle attrezzature)
--INSERIMENTO
CREATE OR REPLACE FUNCTION azienda.fn_incr_costo_attrezzature_e_50_I() 
RETURNS TRIGGER 
AS
$$
DECLARE
	dati_progetto record;
	half_budget azienda.EURO := 0;
BEGIN
	SELECT Budget, costoAttrezzature INTO dati_progetto
	FROM azienda.PROGETTO
	WHERE CUP = NEW.CUP;

	dati_progetto.CostoAttrezzature = dati_progetto.CostoAttrezzature + NEW.Costo;

	half_budget := (0.5 * dati_progetto.Budget)-0.005;

	IF half_budget >= dati_progetto.CostoAttrezzature THEN

		UPDATE azienda.PROGETTO AS PR
		SET costoAttrezzature = dati_progetto.CostoAttrezzature
		WHERE PR.CUP = NEW.CUP;

	ELSE
		RAISE EXCEPTION 'Il costo totale delle attrezzature, ovvero €%, sfora il 50%% del budget (€%)! L''attrezzatura "%" non è stata acquistata per il progetto %', dati_progetto.CostoAttrezzature, half_budget, NEW.Descrizione, NEW.CUP;
	END IF;

	RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tr_incr_costo_attrezzature_e_50_I
BEFORE INSERT ON azienda.ATTREZZATURA
FOR EACH ROW
EXECUTE FUNCTION azienda.fn_incr_costo_attrezzature_e_50_I();


--UPDATE
CREATE OR REPLACE FUNCTION azienda.fn_incr_costo_attrezzature_e_50_U() 
RETURNS TRIGGER 
AS
$$
DECLARE
	dati_progetto record;
	half_budget azienda.EURO := 0;
BEGIN
	SELECT Budget, costoAttrezzature INTO dati_progetto
	FROM azienda.PROGETTO
	WHERE CUP = NEW.CUP;

	dati_progetto.CostoAttrezzature = dati_progetto.CostoAttrezzature + NEW.Costo;
	IF OLD.CUP = NEW.CUP THEN --Se l'attrezzatura è sempre dello stesso progetto, devo aggiornare il valore totale
		dati_progetto.CostoAttrezzature = dati_progetto.CostoAttrezzature - OLD.Costo;
	END IF;

	half_budget := (0.5 * dati_progetto.Budget)-0.005;

	IF half_budget >= dati_progetto.CostoAttrezzature THEN

		--Aggiorno il costo delle attrezzature per il progetto
		UPDATE azienda.PROGETTO AS PR
		SET costoAttrezzature = dati_progetto.CostoAttrezzature
		WHERE PR.CUP = NEW.CUP;

		IF OLD.CUP <> NEW.CUP THEN --Se ho cambiato il CUP vuol dire che il costo dell'attrezzatura non contribuisce più al costo totale del progetto precedente
			UPDATE azienda.PROGETTO AS PR
			SET costoAttrezzature = costoAttrezzature - OLD.Costo
			WHERE PR.CUP = OLD.CUP;
		END IF;

	ELSE
		RAISE EXCEPTION 'Il costo totale delle attrezzature, ovvero €%, sfora il 50%% del budget (€%)! L''attrezzatura "%" non è stata acquistata per il progetto %', dati_progetto.CostoAttrezzature, half_budget, NEW.Descrizione, NEW.CUP;
	END IF;

	RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tr_incr_costo_attrezzature_e_50_U
BEFORE UPDATE ON azienda.ATTREZZATURA
FOR EACH ROW
EXECUTE FUNCTION azienda.fn_incr_costo_attrezzature_e_50_U();


--DELETE
CREATE OR REPLACE FUNCTION azienda.fn_incr_costo_attrezzature_e_50_D() 
RETURNS TRIGGER 
AS
$$
DECLARE
	dati_progetto record;
BEGIN
	SELECT Budget, costoAttrezzature INTO dati_progetto
	FROM azienda.PROGETTO
	WHERE CUP = OLD.CUP;

	dati_progetto.CostoAttrezzature = dati_progetto.CostoAttrezzature - OLD.Costo;

	UPDATE azienda.PROGETTO AS PR
	SET costoAttrezzature = dati_progetto.CostoAttrezzature
	WHERE PR.CUP = OLD.CUP;

	RETURN OLD;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tr_incr_costo_attrezzature_e_50_D
AFTER DELETE ON azienda.ATTREZZATURA
FOR EACH ROW
EXECUTE FUNCTION azienda.fn_incr_costo_attrezzature_e_50_D();

---------------------------------------------------------------------------------------------------------------------------------
--										TRIGGERS PER azienda.DIP_PROGETTO
---------------------------------------------------------------------------------------------------------------------------------

/*
Si verifica che, prima di un inserimento di un dipendente a progetto, oppure prima di un aggiornamento della data di scadenza contratto di un dipendente a progetto,
quest'ultima, in base al progetto vincolato al contratto, sia compresa tra la data di inzio del progetto e la data di fine di quest'ultimo 
*/

CREATE OR REPLACE FUNCTION azienda.fn_verifica_dipProg()
RETURNS TRIGGER
AS $$
DECLARE
    dati_progetto RECORD;
BEGIN
    SELECT dataInizio, dataFine
    INTO dati_progetto
    FROM azienda.PROGETTO
    WHERE CUP = NEW.CUP;

    IF NEW.Scadenza < dati_progetto.dataInizio OR NEW.Scadenza > dati_progetto.dataFine THEN
        RAISE EXCEPTION 'La data di scadenza del dipendente a progetto % non è compresa tra %(inizio progetto) e %(fine progetto)!', NEW.Matricola, dati_progetto.dataInizio, dati_progetto.dataFine;
    END IF;

    RETURN NEW; 
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE TRIGGER tr_verifica_dipProg
BEFORE INSERT OR UPDATE OF Scadenza
ON azienda.DIP_PROGETTO
FOR EACH ROW
EXECUTE FUNCTION azienda.fn_verifica_dipProg();

---------------------------------------------------------------------------------------------------------------------------------

--Trigger che calcola il costo dei contratti così che non superi il budget (si deve adattare ad un eventuale update del costo dei contratti)
--INSERIMENTO
CREATE OR REPLACE FUNCTION azienda.fn_incr_costo_dipProgetto_e_50_I() 
RETURNS TRIGGER 
AS
$$
DECLARE
	dati_progetto record;
	half_budget azienda.EURO := 0;
BEGIN
	SELECT Budget, costoContrattiProgetto INTO dati_progetto
	FROM azienda.PROGETTO
	WHERE CUP = NEW.CUP;

	dati_progetto.costoContrattiProgetto = dati_progetto.costoContrattiProgetto + NEW.Costo;

	half_budget := (0.5 * dati_progetto.Budget)-0.005;

	IF half_budget >= dati_progetto.costoContrattiProgetto THEN

		UPDATE azienda.PROGETTO AS PR
		SET costoContrattiProgetto = dati_progetto.costoContrattiProgetto
		WHERE PR.CUP = NEW.CUP;

	ELSE
		RAISE EXCEPTION 'Il costo totale dei contratti a progetto, ovvero €%, sfora il 50%% del budget (€%)! Il contratto % è stato annullato per il progetto %', dati_progetto.costoContrattiProgetto, half_budget, NEW.Matricola, NEW.CUP;
	END IF;
	
	RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tr_incr_costo_dipProgetto_e_50_I
BEFORE INSERT ON azienda.DIP_PROGETTO
FOR EACH ROW
EXECUTE FUNCTION azienda.fn_incr_costo_dipProgetto_e_50_I();


--UPDATE
CREATE OR REPLACE FUNCTION azienda.fn_incr_costo_dipProgetto_e_50_U() 
RETURNS TRIGGER 
AS
$$
DECLARE
	dati_progetto record;
	half_budget azienda.EURO := 0;
BEGIN
	SELECT Budget, costoContrattiProgetto INTO dati_progetto
	FROM azienda.PROGETTO
	WHERE CUP = NEW.CUP;

	dati_progetto.costoContrattiProgetto = dati_progetto.costoContrattiProgetto + NEW.Costo;
	IF OLD.CUP = NEW.CUP THEN --Se il contratto è sempre dello stesso progetto, devo aggiornare il valore totale
		dati_progetto.costoContrattiProgetto = dati_progetto.costoContrattiProgetto - OLD.Costo;
	END IF;

	half_budget := (0.5 * dati_progetto.Budget)-0.005;

	IF half_budget >= dati_progetto.costoContrattiProgetto THEN

		--Aggiorno il costo dei contratti per il progetto
		UPDATE azienda.PROGETTO AS PR
		SET costoContrattiProgetto = dati_progetto.costoContrattiProgetto
		WHERE PR.CUP = NEW.CUP;

		IF OLD.CUP <> NEW.CUP THEN --Se ho cambiato il CUP vuol dire che il costo del contratto non contribuisce più al costo totale del progetto precedente
			UPDATE azienda.PROGETTO AS PR
			SET costoContrattiProgetto = costoContrattiProgetto - OLD.Costo
			WHERE PR.CUP = OLD.CUP;
		END IF;
		
	ELSE
		RAISE EXCEPTION 'Il costo totale dei contratti a progetto, ovvero €%, sfora il 50%% del budget (€%)! Il contratto % è stato annullato per il progetto %', dati_progetto.costoContrattiProgetto, half_budget, NEW.Matricola, NEW.CUP;
	END IF;

	RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tr_incr_costo_dipProgetto_e_50_U
BEFORE UPDATE ON azienda.DIP_PROGETTO
FOR EACH ROW
EXECUTE FUNCTION azienda.fn_incr_costo_dipProgetto_e_50_U();


--DELETE
CREATE OR REPLACE FUNCTION azienda.fn_incr_costo_dipProgetto_e_50_D() 
RETURNS TRIGGER 
AS
$$
DECLARE
	dati_progetto record;
BEGIN
	SELECT Budget, costoContrattiProgetto INTO dati_progetto
	FROM azienda.PROGETTO
	WHERE CUP = OLD.CUP;

	dati_progetto.costoContrattiProgetto = dati_progetto.costoContrattiProgetto - OLD.Costo;

	UPDATE azienda.PROGETTO AS PR
	SET costoContrattiProgetto = dati_progetto.costoContrattiProgetto
	WHERE PR.CUP = OLD.CUP;

	RETURN OLD;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tr_incr_costo_dipProgetto_e_50_D
AFTER DELETE ON azienda.DIP_PROGETTO
FOR EACH ROW
EXECUTE FUNCTION azienda.fn_incr_costo_dipProgetto_e_50_D();