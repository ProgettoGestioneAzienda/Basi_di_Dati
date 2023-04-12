-- Una view che permette di visualizzare i fondi totali che rimangono ai progetti
-- e i rimanenti fondi dedicati ai contratti ed alle attrezzature

CREATE OR REPLACE VIEW azienda.FondiRimanentiProgetto AS
SELECT
  p.CUP,
  p.Nome,
  (p.Budget - p.costoAttrezzature - p.costoContrattiProgetto) AS Fondi_Rimanenti_Progetto,
  (p.Budget / 2) - (p.costoAttrezzature) AS Fondi_Rimanenti_Attrezzature,
  (p.Budget / 2) - (p.costoContrattiProgetto) AS Fondi_Rimanenti_Contratti
FROM
  azienda.PROGETTO AS p;