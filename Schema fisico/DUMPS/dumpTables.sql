DROP SCHEMA IF EXISTS azienda CASCADE;



--CREAZIONE SCHEMA
CREATE SCHEMA azienda AUTHORIZATION postgres;



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