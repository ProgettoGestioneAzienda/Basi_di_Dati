<a name="readme-top"></a>

# ProgettoBasiDiDati

## Introduzione

<table>
<tr>
<td>

Questo progetto permette l'utilizzo di una basi di dati sviluppata tramite i linguaggi di programmazione PLPGSQL ed SQL. Il progetto consente agli utenti di creare tabelle, inserire dati e interrogare la base di dati. In particolare, è basato sul sistema di gestione di personale e progetti di un’azienda.

Questo database è progettato per gestire le informazioni relative al personale dell'azienda, inclusi i dati anagrafici dei dipendenti, i loro ruoli, i laboratori a cui partecipano e il loro stato occupazionale. Inoltre, la base di dati è stata progettata per supportare la gestione dei progetti, compresi i dettagli del progetto, da quali laboratori sono lavorati e gli acquisti fatti per esso.

</td>
</tr>
</table>

<details>
  <summary>Indice</summary>
  <ol>
    <li><a href="#creazione-database-e-gestione-utenti-con-privilegi">Creazione DataBase</a></li>
    <li><a href="#installazione-database">Installazione DataBase</a></li>
    <li><a href="#informazioni-sul-database">Informazioni sul DataBase</a></li>
  </ol>
</details>

## Creazione database e gestione utenti con privilegi

Di seguito viene descritta la procedura per la creazione di un nuovo database e la gestione degli utenti con i relativi privilegi. Per creare un nuovo utente con password, è possibile utilizzare il comando SQL "CREATE USER" seguito dal nome dell'utente e dalla password assegnata.

```
CREATE USER nomeUtente WITH PASSWORD 'passwordUtente';   
```

Per creare un nuovo database, è possibile utilizzare il comando SQL "CREATE DATABASE" seguito dal nome del nuovo database.

```
CREATE DATABASE GestioneAzienda;   
```

Qualora si desideri fornire i permessi di utilizzo in un determinato schema compreso nel database, è possibile utilizzare il comando SQL "GRANT USAGE" seguito dal nome dello schema e dal nome dell'utente a cui si vogliono fornire i permessi.

```
GRANT USAGE ON Azienda TO nome_user;
```

Per garantire tutti i diritti ed i privilegi al nuovo utente sul nuovo database, è possibile utilizzare il comando SQL "GRANT ALL" seguito dal nome del database e dal nome dell'utente. 

```
GRANT ALL ON DATABASE GestioneAzienda TO nomeUtente;
```

Il nuovo utente ora possiede tutti i diritti ed i privilegi su GestioneAzienda, ma non ne è ancora l'ADMIN. Per assegnare il ruolo di ADMIN al nuovo utente, è possibile utilizzare il comando SQL "ALTER DATABASE OWNER" seguito dal nome del database e dal nome dell'utente.

```
ALTER DATABASE GestioneAzienda OWNER TO nomeUtente;
```

## Installazione database
Innanzitutto, è necessario procedere con la compilazione del codice fornito ([istruzioni creazione database](https://github.com/ProgettoGestioneAzienda/Basi_di_Dati/blob/main/Schema%20fisico/dumpSchema.sql), è possibile anche consultare le [istruzioni con annessi commenti](https://github.com/ProgettoGestioneAzienda/Basi_di_Dati/blob/main/Schema%20fisico/dumpSchemaWithComments.sql)) per l'implementazione su PostgreSQL, completo di creazione di tabelle, vincoli, funzioni, procedure e triggers così da rendere il database pronto all'uso. Successivamente, per procedere con la fase di popolamento, si dovrà proseguire con la compilazione dell'apposito [file contenente la popolazione](https://github.com/ProgettoGestioneAzienda/Basi_di_Dati/blob/main/Schema%20fisico/dumpPopolazione.sql).
Dopodichè sarà possibile utilizzare liberamente il database.

## Informazioni sul DataBase
É consigliato fare riferimento alla [documentazione](https://github.com/ProgettoGestioneAzienda/Basi_di_Dati/blob/main/Documentazione/main.pdf) per ulteriori informazioni riguardanti le specifiche del database, nonché per le varie descrizioni e precisazioni correlate.


<p align="right">(<a href="#readme-top">torna all'inizio</a>)</p>
