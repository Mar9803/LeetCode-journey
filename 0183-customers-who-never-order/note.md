# Diario di Bordo: Risoluzione LeetCode 183

## Problema
**Customers Who Never Order (LeetCode 183)**

**Pattern Applicato:** `Exclusion Join (LEFT JOIN + IS NULL)`

---

# 1. La Trappola Logica: Gli Approcci Errati

Prima di arrivare alla soluzione ottimale, è facile cadere in due errori classici di modellazione logica. Analizzarli aiuta a capire perché una normale unione non sia sufficiente.

## Errore 1: Il Non-Equi Join (`INNER JOIN` con `<>`)

```sql
-- ATTENZIONE: Errore Logico!
SELECT C.name
FROM Customers C
INNER JOIN Orders O
    ON C.id <> O.customerId;
```

### Perché è sbagliato

La condizione

\[
C.id \neq O.customerId
\]

all'interno di una `INNER JOIN` accoppia ogni cliente con **tutti gli ordini che non sono suoi**.

Ad esempio, se il cliente **A** ha effettuato l'ordine **1**, ma nel database esistono anche gli ordini **2** e **3** appartenenti ad altri clienti, il database produrrà comunque delle righe per il cliente **A**, accoppiandolo agli ordini **2** e **3**.

Di conseguenza **nessun cliente viene realmente escluso**.

---

## Errore 2: `NOT IN` senza gestione dei `NULL`

```sql
-- ATTENZIONE: Rischio blocco query!
SELECT name
FROM Customers
WHERE id NOT IN (
    SELECT customerId
    FROM Orders
);
```

### Perché è rischioso

Se la colonna `customerId` della tabella `Orders` contiene anche **un solo valore `NULL`**, l'intera espressione `NOT IN` restituisce **zero righe**.

Questo accade perché qualsiasi confronto con `NULL` in SQL produce il valore logico **UNKNOWN**, impedendo alla condizione di risultare vera.

---

# 2. Il Modello Mentale Corretto: L'intuizione del `LEFT JOIN`

Per risolvere il problema in modo efficiente e sicuro utilizziamo una **Exclusion Join**, realizzata tramite un `LEFT JOIN`.

La forza di questo approccio deriva dal modo in cui il motore SQL esegue una join sinistra.

## Preservazione della tabella sinistra

Il database prende **ogni riga** della tabella `Customers` e tenta di trovare una corrispondenza nella tabella `Orders` utilizzando la condizione

\[
C.id = O.customerId
\]

---

## Generazione dei `NULL` (La chiave di volta)

Il comportamento è il seguente:

- Se il match esiste, le due righe vengono combinate normalmente.
- Se il match **non esiste**, la riga del cliente **non viene eliminata**.

Al contrario, il database:

- mantiene la riga del cliente;
- riempie tutte le colonne provenienti dalla tabella `Orders` con valori `NULL`.

È proprio questo comportamento che rende possibile individuare i clienti senza ordini.

---

## Rappresentazione Visiva del Matching

| C.id | C.name | O.id | O.customerId | Note |
|------|--------|------|--------------|------|
| 1 | Joe | 101 | 1 | Match trovato (ha ordinato) |
| 2 | Henry | NULL | NULL | Nessun match (non ha mai ordinato) |
| 3 | Sam | 102 | 3 | Match trovato (ha ordinato) |

L'intuizione fondamentale è che **gli unici record che presenteranno valori `NULL` nelle colonne della tabella di destra saranno proprio quelli dei clienti che non hanno mai effettuato un ordine**.

---

# 3. Implementazione Finale: Isolare i `NULL`

Sfruttando questa proprietà è sufficiente filtrare le righe in cui la tabella `Orders` non ha trovato alcuna corrispondenza.

```sql
SELECT C.name AS Customers
FROM Customers AS C
LEFT JOIN Orders AS O
    ON C.id = O.customerId
WHERE O.customerId IS NULL;
```

La clausola

```sql
WHERE O.customerId IS NULL
```

seleziona esclusivamente i record "orfani", cioè quei clienti per cui il `LEFT JOIN` non ha trovato alcun ordine.

---

# Perché questo approccio è il preferito nei colloqui?

## Performance

Rispetto ad alcune implementazioni con `NOT IN`, i database moderni ottimizzano molto bene i `LEFT JOIN`, sfruttando algoritmi come:

- Hash Join
- Merge Join

che consentono un'esecuzione molto efficiente.

---

## Sicurezza

L'approccio è completamente immune al problema dei valori `NULL` presenti nella tabella `Orders`.

Per questo motivo rappresenta la soluzione standard e più robusta per il pattern **Customers Who Never Order**.