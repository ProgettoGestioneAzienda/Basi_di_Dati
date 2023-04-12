INSERT INTO azienda.DIP_INDETERMINATO(Matricola, Tipo, Nome, Cognome, codFiscale, Indirizzo, dataNascita, dataAssunzione, dataFine, Dirigente) VALUES
('KD0001PP', 'Junior', 'Paolo', 'Rossi', 'RSSPLA76E18F839B', 'Via Medina, 5, 80133 Napoli NA', '18/05/1976', '16/03/2021', NULL, 'False'),
('AZ0156OL', 'Middle', 'Giustino', 'Tomasetti', 'TMSGTN83P08I158R', 'Via Legnano, 18, 71016 San Severo FG', '08/09/1983', '25/09/2018', NULL, 'False'),
('KP1500XD', 'Middle', 'Livia', 'Donatoni', 'DNTLVI00S53F205H', NULL, '13/11/2000', '30/09/2018', '11/12/2021', 'False'),
('NG3020OP', 'Senior', 'Oreste', 'Zamorani', 'ZMRRST85E15L120W', 'Via Olmata, 106, 04019 Terracina LT', '15/05/1985', '19/12/1999', NULL, 'False'),
('DS0155CC', 'Junior', 'Liliana', 'Coppola', 'CPPLLN65E56G482Y', 'Via Fernando Francesco d''Avalos, 9/C, 65126 Pescara PE', '16/05/1965', '15/07/1988', '05/05/1990', 'False'),
('BH0100FI', 'Senior', 'Daniele', 'Comolli', 'CMLDNL90E08L219M', NULL, '08/05/1990', '28/09/2010', NULL, 'False'),
('OD9234CC', 'Senior', 'Federico', 'Galeati', 'GLTFRC80R17E506C', 'Via Guglielmo Paladini, 19, 73100 Lecce LE', '17/10/1980', '17/10/2010', NULL, 'False'),
('EE2214XN', 'Junior', 'Fabio', 'Brancaccio', 'BRNFBA85M05H501N', 'Via dei Marrucini, 6, 00185 Roma RM', '05/08/1985', '09/09/2015', '18/09/2015', 'False'),
('CF2901KK', 'Junior', 'Claudia', 'Broggini', 'BRGCLD94A54E506J', 'Via di Leuca, 34, 73100 Lecce LE', '14/01/1994', '12/11/2022', NULL, 'False'),
('FE2901KK', 'Middle', 'Ugo', 'Corradi', 'CRRGUO89D12D612B', 'Via della Cernaia, 10, 50129 Firenze FI', '12/04/1989', '05/02/2011', '19/02/2016', 'False'),
('AL3910ZO', 'Middle', 'Ugo', 'Corradi', 'CRRGUO89D12D612B', 'Via della Cernaia, 10, 50129 Firenze FI', '12/04/1989', '25/02/2016', '21/09/2022', 'False'),
('AL3910ZP', 'Middle', 'Liliana', 'Coppola', 'CPPLLN92L52G786A', 'Via Taranto, 158, 75025 Policoro MT', '12/07/1992', '30/05/2017', NULL, 'False'),
('IP2100GF', 'Senior', 'Gianmarco', 'De Simone', 'DSMGMR02B11F205H', NULL, '11/12/1995', '04/05/2012', NULL, 'False'),
('FE2901BK', 'Junior', 'Gianni', 'Boitani', 'BTNGNN78R19H199O', 'Via Giacomo Battuzzi, 49, 48123 Ravenna RA', '19/10/1978', '12/04/2021', NULL, 'False'),
('OF6749NN', 'Junior', 'Livia', 'Donatoni', 'DNTLVI00S53F205H', NULL, '13/11/2000', '25/05/2022', NULL, 'False');


INSERT INTO azienda.SCATTO_CARRIERA(Matricola, Tipo, Data) VALUES
('IP2100GF', 'Promosso a dirigente', '30/12/2023'),
('AZ0156OL', 'Promosso a dirigente', '17/10/2022'),
('BH0100FI', 'Promosso a dirigente', '24/09/2015'),
('NG3020OP', 'Promosso a dirigente', '18/06/2007'),
('NG3020OP', 'Rimosso da dirigente', '01/08/2009'),
('NG3020OP', 'Promosso a dirigente', '16/12/2015'),
('OD9234CC', 'Promosso a dirigente', '12/11/2014'),
('OD9234CC', 'Rimosso da dirigente', '11/04/2020'),
('AL3910ZO', 'Promosso a dirigente', '08/06/2021'),
('DS0155CC', 'Promosso a dirigente', '15/02/1990');


INSERT INTO azienda.LABORATORIO(Nome, Topic, Responsabile_Scientifico) VALUES
('Ganular', 'Telecomunicazioni', 'NG3020OP'),
('Aptos', 'Intelligenza Artificiale', 'BH0100FI'),
('Aj Logics', 'Intelligenza Artificiale', 'BH0100FI'),
('Kupfert', 'Web Design', 'IP2100GF');

INSERT INTO azienda.AFFERIRE(Matricola, nomeLab, Data) VALUES
--('IP2100GF', 'Kupfert', '15/08/2015'),
('AZ0156OL', 'Kupfert', '25/11/2023'),
--('FE2901KK', 'Kupfert', '05/02/2014'), --Dovrebbe dare errore essendo una matricola licenziata OK
--('KP1500XD', 'Kupfert', '11/12/2019'), --Dovrebbe dare errore essendo una matricola licenziata OK
--('BH0100FI', 'Aptos', '28/09/2012'),
('FE2901BK', 'Aptos', '14/04/2021'),
--('EE2214XN', 'Aptos', '18/09/2015'), --Dovrebbe dare errore essendo una matricola licenziata OK
--('BH0100FI', 'Aj Logics', '17/09/2012'),
--('FE2901KK', 'Aj Logics', '08/02/2014'), --Dovrebbe dare errore essendo una matricola licenziata OK
('AZ0156OL', 'Aj Logics', '25/11/2023'),
('CF2901KK', 'Aj Logics', '28/09/2018'),
('FE2901BK', 'Aj Logics', '12/04/2021'),
('AL3910ZP', 'Aj Logics', '25/08/2017'),
--('NG3020OP', 'Ganular', '19/12/2000'),
('BH0100FI', 'Ganular', '22/12/2014'),
--('AL3910ZO', 'Ganular', '21/09/2021'), --Dovrebbe dare errore essendo una matricola licenziata OK
('IP2100GF', 'Ganular', '04/08/2012');
--('DS0155CC', 'Ganular', '02/05/1990'), --Dovrebbe dare errore essendo una matricola licenziata OK
--('EE2214XN', 'Ganular', '17/09/2015'), --Dovrebbe dare errore essendo una matricola licenziata OK

INSERT INTO azienda.PROGETTO(CUP, Nome, dataInizio, dataFine, Budget, Referente_Scientifico, Responsabile) VALUES
('J63G16029530490', 'Tricolouris', '21/12/2020', '23/05/2024', 1350, 'IP2100GF', 'IP2100GF'),
('O25H61393843815', 'Photonics', '12/10/1999', '12/10/2000', 7000, 'OD9234CC', 'AZ0156OL'),
('N50E60862030706', 'Fairytale', '05/06/2025', NULL, 2500, 'NG3020OP', 'BH0100FI'),
('N13G09807134097', 'Trident', '26/07/2013', NULL, 850, 'BH0100FI', 'AZ0156OL');

INSERT INTO azienda.LAVORARE(CUP, nomeLab) VALUES
('J63G16029530490', 'Ganular'),
('J63G16029530490', 'Kupfert'),
('J63G16029530490', 'Aj Logics'),
('O25H61393843815', 'Aptos'),
('O25H61393843815', 'Aj Logics'),
('N50E60862030706', 'Kupfert'),
('N50E60862030706', 'Aptos'),
('N50E60862030706', 'Ganular'),
('N13G09807134097', 'Ganular');

INSERT INTO azienda.ATTREZZATURA(Descrizione, nomeLab, CUP, Costo) VALUES
('Stampante 3D', 'Aptos', 'O25H61393843815', 800),
('Computer portatile', 'Ganular', 'N50E60862030706', 500),
('Computer portatile', 'Ganular', 'N50E60862030706', 500),
('Proiettore', 'Ganular', 'N13G09807134097', 350),
('mBot Robot programmabile', 'Aptos', 'N50E60862030706', 150),
('Stampante 3D', 'Aptos', 'O25H61393843815', 800),
('Monitor 32''''', 'Kupfert', 'J63G16029530490', 200),
('Monitor 48''''', 'Kupfert', 'J63G16029530490', 375),
('Smartphone', 'Kupfert', 'J63G16029530490', 80),
('Stampante 3D', 'Aj Logics', 'O25H61393843815', 800),
('Computer portatile', 'Aptos', 'O25H61393843815', 750),
('Parte di ricambio per "SoftBank Robotics Pepper Robot"', 'Kupfert', 'N50E60862030706', 100);

INSERT INTO azienda.DIP_PROGETTO(Matricola, Nome, Cognome, codfiscale, Indirizzo, dataNascita, dataAssunzione, Scadenza, CUP, Costo) VALUES
('FP2190PL', 'Fabio', 'Brancaccio', 'BRNFBA85M05H501N', 'Via dei Marrucini, 6, 00185 Roma RM', '05/08/1985', '28/07/2020', '28/12/2022', 'J63G16029530490', 125),
('GP4291SO', 'Fabio', 'Brancaccio', 'BRNFBA85M05H501N', 'Via dei Marrucini, 6, 00185 Roma RM', '05/08/1985', '01/01/2021', '01/09/2022', 'J63G16029530490', 200),
('CF1944AF', 'Claudia', 'Romiti', 'RMTCLD75M50L736F', NULL, '10/08/1975', '12/03/2013', '05/11/2013', 'N13G09807134097', 250),
('HO1034OK', 'Maria', 'Pepe', 'PPEMRA00D54B519B', 'Corso Vittorio Emanuele II, 51, 86100 Campobasso CB', '14/04/2000', '09/05/2024', '12/11/2026', 'N50E60862030706', 300),
('AL1230KF', 'Gianluigi', 'Liguori', 'LGRGLG00P08B519P', 'Via Fossi, 16, 86010 Mirabello Sannitico CB', '08/09/2000', '09/05/2024', '12/11/2026', 'N50E60862030706', 300);