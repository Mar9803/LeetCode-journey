# Diario di Bordo: Come ho risolto LeetCode 1321 (Restaurant Growth)

Risolvere questo problema richiede di passare da un approccio SQL standard basato su aggregazioni semplici a un uso avanzato delle **Window Functions** (funzioni finestra). Di seguito ho riassunto tutte le sfide logiche che ho incontrato durante lo sviluppo della soluzione e come le ho superate passo dopo passo.

---

## 🛑 Sfida 1: La trappola del dataset (Transazioni multiple nello stesso giorno)

Il mio punto di partenza logico era applicare direttamente la window function sulla tabella `Customer`.

### Il problema

La tabella `Customer` contiene più transazioni per lo stesso giorno (`visited_on`).

Se avessi applicato una finestra temporale basata sulle righe direttamente qui, SQL avrebbe contato le **singole transazioni** e non i **giorni reali**.

---

## 💡 La soluzione: Raggruppamento preventivo (La prima CTE)

Ho capito che, per far funzionare i calcoli sui giorni, dovevo prima **compattare** i dati in modo da avere esattamente **una riga per ogni data**.

Ho creato quindi la tabella temporanea `daily_Table`:

```sql
WITH daily_Table AS (
    SELECT
        visited_on,
        SUM(amount) AS sumDay_amount
    FROM Customer
    GROUP BY visited_on
)
```

---

## 🛑 Sfida 2: Come muoversi nel tempo (Ordinamento e Finestra Temporale)

Una volta compattati i dati, dovevo calcolare la somma e la media degli ultimi 7 giorni.

All'inizio avevo pensato a un semplice:

```sql
PARTITION BY visited_on
```

### Il problema

- `PARTITION BY` isola ogni giorno a sé stante, impedendo di guardare al passato.
- Mancava una direzione temporale.
- SQL non permette di inserire un `WHERE` dentro la clausola `OVER()` per filtrare le date.

---

## 💡 La soluzione: `ORDER BY` e il Window Frame (`ROWS BETWEEN`)

Per risolvere questo blocco ho sfruttato due concetti chiave delle Window Functions:

- `ORDER BY visited_on`: indica a SQL in quale direzione scorre il tempo.
- `ROWS BETWEEN 6 PRECEDING AND CURRENT ROW`: definisce il **frame** (la finestra) dicendo a SQL di prendere la riga corrente e le **6 precedenti**, ottenendo così una finestra di **7 giorni**.

```sql
SUM(sumDay_amount) OVER (
    ORDER BY visited_on
    ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
) AS amount
```

---

## 🛑 Sfida 3: Scartare i dati incompleti (I primi 6 giorni)

Dopo aver applicato la finestra mobile, la query calcolava comunque la somma e la media anche per il primo giorno del dataset, il secondo, il terzo e così via.

Tuttavia, per i primi **6 giorni** non esiste ancora una finestra completa di 7 giorni.

LeetCode richiede invece di mostrare **solo** i giorni che possiedono uno storico completo di una settimana.

### Il problema

Non è possibile filtrare direttamente il risultato di una Window Function nel `WHERE` della stessa query in cui viene calcolata.

Questo dipende dall'ordine di esecuzione di SQL:

1. `FROM`
2. `WHERE`
3. `GROUP BY`
4. `HAVING`
5. `SELECT` (qui vengono calcolate le Window Functions)
6. `ORDER BY`
