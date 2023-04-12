--popolazione luca
INSERT INTO azienda.DIP_INDETERMINATO
(Matricola, Tipo, Nome, Cognome, CodFiscale, Indirizzo, DataNascita, DataAssunzione, DataFine, Dirigente)
VALUES
('X3KJ7B5D', 'Junior', 'Berenice', 'Fanucci', 'BRNFCC73P55B354I', 'Via Pisanelli, 117, 00011 Roma RM', '15/09/1973', '12/10/2022', NULL, false), 		--no scatto
('Y9LQ8T2R', 'Middle', 'Alma', 'Rizzo', 'RZZLMA81R57E715O', 'Via Firenze, 80, 06015 Perugia PG', '17/10/1981', '03/03/2020', NULL, false), 				--scatto middle
('H6MNB4VC', 'Middle', 'Ruggero', 'Folliero', 'FLLRGR82A21D643A', 'Via Foria, 89, 92015 Agrigento AG', '21/01/1982', '05/07/2019', NULL, false),        --scatto middle
('G1PZ2X4F', 'Junior', 'Benedetta', 'Trevisan', 'TRVBDT91P62F205X', 'Via del Caggio, 96, 70896 Bari BA', '22/09/1991', '07/05/2022', NULL, false),      --no scatto
('C9VH2J8N', 'Senior', 'Lamberto', 'Sabbatini', 'SBBLBR63L03H703X', 'Viale delle Province, 111, 81057 Caserta CA', '03/07/1963', '23/02/2012', NULL, false),		--scatto middle scatto senior FactoryIoT
('K4S6D7F9', 'Senior', 'Filippo', 'Russo', 'RSSFPP75A24C242H', 'Via San Pietro Ad Aram, 3, 85067 Potenza PZ', '24/01/1975', '15/02/2016', NULL, true),			--scatto middle scatto senior 
('Q2WY7U5E', 'Middle', 'Palmiro', 'Napolitano', 'NPLPMR57R10E040Z', 'Via Catullo, 27, 72018 Brindisi BR', '10/10/1986', '03/08/2018', '13/12/2022', false),		--licenziato middle
('N5B8J3M7', 'Junior', 'Claudia', 'Lucchese', 'LCCCLD92E55F839O', 'Via Nicola Spaventa, 74, 91040 Trapani TP', '15/05/1992', '19/12/2022', NULL, false),		--no scatto
('P6L2K8T4', 'Middle', 'Doroteo', 'Udinese', 'DNSDRT82T21L049G', 'Via Piave, 101, 97098 Ragusa RG', '21/12/1982', '14/01/2018', NULL, false),					--scatto middle
('Z1X5C2V9', 'Junior', 'Nella', 'Romano', 'RMNNLL74D53A662E', 'Via Palermo, 38, 95032 Catania CT', '13/04/1974', '05/04/2021', NULL, false),					--no scatto
('F8R6G3J7', 'Senior', 'Giuseppe', 'Lo Duca', 'LDCGPP68L08H501Y', 'Via Pasquale Scura, 46, 98045 Messina ME', '08/07/1968', '21/10/2010', NULL, true),			--scatto middle scatto senior TechLab dirigente
('T5K9M7H1', 'Senior', 'Piero', 'Angelo', 'NGLPRI64C08L049L', 'Via Galileo Ferraris, 31, 02015 Rieti RI', '08/03/1964', '18/05/2011', NULL, false),				--scatto middle scatto senior DataWorks
('U2N6B4L8', 'Senior', 'Monica', 'Pirozzi', 'PRZMNC59L48D612U', 'Piazza Principe Umberto, 107, 11028 Aosta AO', '08/07/1959', '05/03/2011', '18/09/2019', false), --licenziato scatto senior
('V9C5F2P7', 'Middle', 'Costantino', 'Bruno', 'CSTBRN02A05F257E', 'Piazza Bovio, 79, 17043 Savona SV', '05/01/2002', '05/03/2020', NULL, false), 			--scatto Middl
('W1Q8Z2X4', 'Senior', 'Gaspare', 'Buccho', 'BCCGPR83L31F839G', 'Via Galileo Ferraris, 32, 10013 Torino TO', '31/07/1983', '21/05/2010', NULL, true),      --senior dirigente
('Z8MH9F2E', 'Junior', 'Gabriele', 'Russo', 'RSSGBR80L27B345E', 'Via Casoria, 23, 00132 Roma RM', '20/05/1980', '01/11/2022', NULL, false),      			
('W5KL6H9Z', 'Middle', 'Simone', 'Ferrari', 'FRRSMN73A23L219E', 'Via dei Serpenti, 43, 00184 Roma RM', '07/06/1973', '01/03/2019', NULL, false),
('F4J9X7K2', 'Senior', 'Jolanda', 'Greco', 'GRCJND77R56I452S', 'Via Croce Rossa, 100, 07052 Sassari SS', '16/10/1977', '13/11/2011', NULL, false),
('T8M3B2N6', 'Senior', 'Remo', 'Romani', 'RMNRME61D18H473W', 'Piazza Trieste e Trento, 4, 12050 Roddino CN', '18/04/1961', '17/03/2009', NULL, false),
('L6P9R2V7', 'Senior', 'Antonio', 'Cremonesi', 'CRMNTN67A09L682H', 'Via Lagrange, 134, 21100 Varese VA', '09/01/1967', '11/05/2012', NULL, false);

INSERT INTO azienda.SCATTO_CARRIERA
(Matricola, Tipo, Data)
VALUES
('Y9LQ8T2R', 'Middle', '03/03/2023'),
('H6MNB4VC', 'Middle', '05/07/2022'),
('C9VH2J8N', 'Middle', '23/02/2015'),
('C9VH2J8N', 'Senior', '23/02/2019'),
('K4S6D7F9', 'Middle', '15/02/2019'),
('K4S6D7F9', 'Senior', '15/02/2023'),
('Q2WY7U5E', 'Middle', '03/08/2021'),
('P6L2K8T4', 'Middle', '14/01/2021'),
('F8R6G3J7', 'Middle', '21/10/2013'),
('F8R6G3J7', 'Senior', '21/10/2017'),
('T5K9M7H1', 'Middle', '18/05/2014'),
('T5K9M7H1', 'Senior', '18/05/2018'),
('U2N6B4L8', 'Middle', '05/03/2014'),   --licenziato
('U2N6B4L8', 'Senior', '05/03/2018'),   --licenziato
('V9C5F2P7', 'Middle', '05/03/2023'),
('W1Q8Z2X4', 'Middle', '21/05/2013'),
('W1Q8Z2X4', 'Senior', '21/05/2017'),
('W1Q8Z2X4', 'Promosso a dirigente', '28/01/2019'),
('C9VH2J8N', 'Promosso a dirigente', '12/05/2019'),
('F8R6G3J7', 'Promosso a dirigente', '20/02/2020'),
('C9VH2J8N', 'Rimosso da dirigente', '24/03/2020'),
('K4S6D7F9', 'Promosso a dirigente', '20/02/2023'),
('W5KL6H9Z', 'Middle', '01/03/2022'),
('F4J9X7K2', 'Middle', '13/11/2014'),
('F4J9X7K2', 'Senior', '13/11/2018'),
('T8M3B2N6', 'Middle', '17/03/2012'),
('T8M3B2N6', 'Senior', '17/03/2016'),
('L6P9R2V7', 'Middle', '11/05/2015'),
('L6P9R2V7', 'Senior', '11/05/2019');

INSERT INTO azienda.LABORATORIO
(Nome, Topic, nAfferenti, Responsabile_Scientifico)
VALUES
('FactoryIoT', 'Internet delle Cose (IoT)', 1, 'C9VH2J8N'),
('CodeLab', 'Sviluppo software', 1, 'C9VH2J8N'),
('TechLab', 'Ricerca e sviluppo', 1, 'K4S6D7F9'),
('TrustChain', 'Blockchain', 1, 'F8R6G3J7'),
('DataWorks', 'Data science', 1, 'T5K9M7H1'),
('TestZone', 'Testing qualità software', 1, 'W1Q8Z2X4'), 
('UserXperience', 'Interfacce utente', 1, 'K4S6D7F9'),
('QuantumLab', 'Quantum Computing', 1, 'W1Q8Z2X4');

--alcuni laboratorio con solo il referente scientifico
INSERT INTO azienda.AFFERIRE
(Matricola, nomeLab)
VALUES
----  afferenze Responsabili scientifici
('C9VH2J8N', 'FactoryIoT'),
('K4S6D7F9', 'TechLab'),
('F8R6G3J7', 'TrustChain'),
('T5K9M7H1', 'DataWorks'),
('W1Q8Z2X4', 'TestZone'),
('K4S6D7F9', 'UserXperience'),
('W1Q8Z2X4', 'QuantumLab'),
----  afferenze Responsabili scientifici
('X3KJ7B5D', 'FactoryIoT'),
('G1PZ2X4F', 'FactoryIoT'),
('G1PZ2X4F', 'TestZone'),
('N5B8J3M7', 'TestZone'),
('N5B8J3M7', 'UserXperience'),
('Z1X5C2V9', 'FactoryIoT'),
('Z8MH9F2E', 'FactoryIoT'),
('Z8MH9F2E', 'TrustChain'),
('Z8MH9F2E', 'TestZone'),
('Y9LQ8T2R', 'TechLab'),
('Y9LQ8T2R', 'DataWorks'),
('H6MNB4VC', 'DataWorks'),
('H6MNB4VC', 'QuantumLab'),
--('Q2WY7U5E', 'TrustChain'), --licenziato
--('Q2WY7U5E', 'UserXperience'), --licenziato
--('Q2WY7U5E', 'TechLab'), --licenziato
('P6L2K8T4', 'FactoryIoT'),
('P6L2K8T4', 'TestZone'),
('P6L2K8T4', 'TrustChain'),
('V9C5F2P7', 'QuantumLab'),
('W5KL6H9Z', 'TestZone'),
('W5KL6H9Z', 'UserXperience'),
('C9VH2J8N', 'QuantumLab'),
('C9VH2J8N', 'TechLab'),
('K4S6D7F9', 'QuantumLab'),
('F8R6G3J7', 'DataWorks'),
('T5K9M7H1', 'FactoryIoT'),
('T5K9M7H1', 'TrustChain'),
('T5K9M7H1', 'TestZone'),
--('U2N6B4L8', 'TestZone'), --licenziato
--('U2N6B4L8', 'QuantumLab'), --licenziato
('W1Q8Z2X4', 'TechLab'),
('F4J9X7K2', 'DataWorks'),
('T8M3B2N6', 'QuantumLab'),
('T8M3B2N6', 'TechLab'),
('L6P9R2V7', 'CodeLab'),
('L6P9R2V7', 'UserXperience');

INSERT INTO azienda.PROGETTO
(CUP, Nome, dataInizio, dataFine, Budget, Referente_Scientifico, Responsabile)
VALUES
('OUNH7DFJ8T1M2KP', 'ResourceWise', '05/02/2020', '10/01/2024', 450000, 'F4J9X7K2', 'W1Q8Z2X4'), --in corso
('CQYR9VXW5A6E1HZ', 'SecurityShield', '24/04/2020', '23/07/2024', 485000, 'T8M3B2N6', 'F8R6G3J7'), --in corso
('P3K7D5F8L4S9J6G', 'InvoicesChain', '11/12/2021', '17/10/2025', 430000, 'F4J9X7K2', 'W1Q8Z2X4'), --in corso
('N1X4Z8B5G7V6H2J', 'AIfinity', '23/03/2022', '07/05/2025', 550000, 'T8M3B2N6', 'F8R6G3J7'), --in corso
('M5S8D4F9K2L1G7H', 'AutoTest', '10/04/2018', '25/07/2023', 430000, 'L6P9R2V7', 'K4S6D7F9'), --in corso
('3N7D6G9X2R8K1S4', 'SmartShop', '07/05/2019', '15/01/2023', 300000, 'L6P9R2V7', 'K4S6D7F9');  --finito

INSERT INTO azienda.LAVORARE
(CUP, nomeLab)
VALUES
('OUNH7DFJ8T1M2KP', 'FactoryIoT'),
('OUNH7DFJ8T1M2KP', 'DataWorks'),
('OUNH7DFJ8T1M2KP', 'UserXperience'),
('CQYR9VXW5A6E1HZ', 'QuantumLab'),
('CQYR9VXW5A6E1HZ', 'TechLab'),
('P3K7D5F8L4S9J6G', 'TrustChain'),
('P3K7D5F8L4S9J6G', 'DataWorks'),
('P3K7D5F8L4S9J6G', 'CodeLab'),
('N1X4Z8B5G7V6H2J', 'TechLab'),
('N1X4Z8B5G7V6H2J', 'TrustChain'),
('N1X4Z8B5G7V6H2J', 'QuantumLab'),
('M5S8D4F9K2L1G7H', 'TestZone'),
('M5S8D4F9K2L1G7H', 'UserXperience'),
('M5S8D4F9K2L1G7H', 'CodeLab'),
('3N7D6G9X2R8K1S4', 'CodeLab'),
('3N7D6G9X2R8K1S4', 'UserXperience'),
('3N7D6G9X2R8K1S4', 'FactoryIoT');

INSERT INTO azienda.ATTREZZATURA
(Descrizione, nomeLab, CUP, Costo)
VALUES
('PC Desktop', 'FactoryIoT', 'OUNH7DFJ8T1M2KP', 3200),
('Monitor 32 inch.', 'FactoryIoT', 'OUNH7DFJ8T1M2KP', 350),
('Sensore', 'FactoryIoT', 'OUNH7DFJ8T1M2KP', 210),
('Sensore', 'FactoryIoT', 'OUNH7DFJ8T1M2KP', 560),
('Microcontroller M1', 'FactoryIoT', 'OUNH7DFJ8T1M2KP', 270),
('PC Portatile', 'FactoryIoT', '3N7D6G9X2R8K1S4', 1560),
('Proiettore', 'FactoryIoT', '3N7D6G9X2R8K1S4', 150),
('Microfono', 'FactoryIoT', '3N7D6G9X2R8K1S4', 40),
('Microcontroller M2', 'FactoryIoT', '3N7D6G9X2R8K1S4', 320),
('Modulo di rete', 'DataWorks', 'OUNH7DFJ8T1M2KP', 120),
('Server', 'DataWorks', 'OUNH7DFJ8T1M2KP', 1350),
('Server', 'DataWorks', 'OUNH7DFJ8T1M2KP', 870),
('PC ad alte prestazioni', 'DataWorks', 'OUNH7DFJ8T1M2KP', 5679),
('PC ad alte prestazioni', 'DataWorks', 'P3K7D5F8L4S9J6G', 7660),
('Server', 'DataWorks', 'P3K7D5F8L4S9J6G', 532),
('PC Portatile', 'DataWorks', 'P3K7D5F8L4S9J6G', 870),
('PC Portatile', 'UserXperience', 'OUNH7DFJ8T1M2KP', 1265),
('Adobe XD copia fisica', 'UserXperience', 'OUNH7DFJ8T1M2KP', 130),
('Eye Tracker', 'UserXperience', 'OUNH7DFJ8T1M2KP', 540),
('PC Portatile', 'UserXperience', 'M5S8D4F9K2L1G7H', 953),
('Tavoletta grafica', 'UserXperience', 'M5S8D4F9K2L1G7H', 220),
('PC Portatile', 'UserXperience', '3N7D6G9X2R8K1S4', 1230),
('Videocamera', 'UserXperience', '3N7D6G9X2R8K1S4', 250),
('Tavoletta grafica', 'UserXperience', '3N7D6G9X2R8K1S4', 220),
('PC quantistico', 'QuantumLab', 'CQYR9VXW5A6E1HZ', 5340),
('Strumento di visualizzazione', 'QuantumLab', 'CQYR9VXW5A6E1HZ', 3679),
('PC quantistico', 'QuantumLab', 'N1X4Z8B5G7V6H2J', 8760),
('Simulatore quantistico', 'QuantumLab', 'N1X4Z8B5G7V6H2J', 4500),
('Magnetometro', 'QuantumLab', 'N1X4Z8B5G7V6H2J', 1350),
('PC ad alte prestazioni', 'TechLab', 'CQYR9VXW5A6E1HZ', 6740),
('Monitor 43 inch.', 'TechLab', 'CQYR9VXW5A6E1HZ', 650),
('Misuratore onde elettromagnetiche', 'TechLab', 'CQYR9VXW5A6E1HZ', 1455),
('Criptatore Hardware', 'TechLab', 'CQYR9VXW5A6E1HZ', 3650),
('Scanner', 'TechLab', 'N1X4Z8B5G7V6H2J', 2700),
('Robot specializzato', 'TechLab', 'N1X4Z8B5G7V6H2J', 6000),
('PC portatile', 'CodeLab', 'P3K7D5F8L4S9J6G', 1200),
('PC Dekstop', 'CodeLab', 'M5S8D4F9K2L1G7H', 3500),
('Monitor 24 inch.', 'CodeLab', 'M5S8D4F9K2L1G7H', 370),
('Lavagna', 'CodeLab', 'M5S8D4F9K2L1G7H', 200),
('PC portatile', 'CodeLab', '3N7D6G9X2R8K1S4', 950),
('Proiettore', 'CodeLab', '3N7D6G9X2R8K1S4', 250),
('Microfono', 'CodeLab', '3N7D6G9X2R8K1S4', 150),
('PC Desktop', 'TestZone', 'M5S8D4F9K2L1G7H', 3560),
('Monitor 42 inch.', 'TestZone', 'M5S8D4F9K2L1G7H', 660),
('Smartphone', 'TestZone', 'M5S8D4F9K2L1G7H', 550),
('Misuratore di prestazioni', 'TestZone', 'OUNH7DFJ8T1M2KP', 1350),
('Analizzatore del traffico di rete', 'TestZone', 'OUNH7DFJ8T1M2KP', 3360),
('Generatore di segnali', 'TestZone', 'OUNH7DFJ8T1M2KP', 4320);

INSERT INTO azienda.DIP_PROGETTO
(Matricola, Nome, Cognome, codfiscale, Indirizzo, dataNascita, dataAssunzione, Scadenza, CUP, Costo)
VALUES
('K7H2F8L4', 'Valeria', 'Milani', 'MLNVLR70D19F205E', 'Via Foria, 19, 20021 Milano MI', '19/04/1970', '19/01/2020', '05/01/2024', 'OUNH7DFJ8T1M2KP', 120000),
('E3R9G5N1', 'Italo', 'Mazzi', 'MZZTLI71B23F839Q', 'Via Piave, 107, 80131 Napoli NA', '23/02/1971', '20/04/2020', '10/07/2024', 'CQYR9VXW5A6E1HZ', 145442),
('T4V7A6Z9', 'Sara', 'Esposito', 'SPSSRA85D28A271Z', 'Via Solfatara, 56, 60125 Ancona AN', '28/04/1985', '01/12/2021', '14/10/2025', 'P3K7D5F8L4S9J6G', 165350),
('Q1D8B6K2', 'Vincenzo', 'Trevisano', 'TRVVCN76H10D969R', 'Piazza della Repubblica, 140, 16121 Genova GE', '10/06/1976', '13/03/2022', '01/05/2025', 'N1X4Z8B5G7V6H2J', 115000),
('J9X6C3Y2', 'Giancarlo', 'Gallo', 'GLLGCR82D04G273Q', 'Via Piccinni, 88, 90131 Palermo PA', '04/04/1982', '27/04/2018', '20/07/2023', 'M5S8D4F9K2L1G7H', 133500),
('M2P5F7R1', 'Elio', 'Romano', 'RMNLEI85H30L219V', 'Via Alessandro Manzoni, 70, 10143 Torino TO', '30/06/1985', '28/04/2019', '10/01/2023', '3N7D6G9X2R8K1S4', 111500); --scaduto