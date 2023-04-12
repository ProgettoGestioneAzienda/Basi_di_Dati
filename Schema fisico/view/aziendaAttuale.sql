--Views che mostrano solo l'istanza attuale dell'azienda

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