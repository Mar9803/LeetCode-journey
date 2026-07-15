<h2><a href="https://leetcode.com/problems/restaurant-growth">1452. Restaurant Growth</a></h2><h3>Medium</h3><hr><p>Table: <code>Customer</code></p>

<pre>
+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| customer_id   | int     |
| name          | varchar |
| visited_on    | date    |
| amount        | int     |
+---------------+---------+
In SQL,(customer_id, visited_on) is the primary key for this table.
This table contains data about customer transactions in a restaurant.
visited_on is the date on which the customer with ID (customer_id) has visited the restaurant.
amount is the total paid by a customer.
</pre>

<p>&nbsp;</p>

<p>You are the restaurant owner and you want to analyze a possible expansion (there will be at least one customer every day).</p>

<p>Compute the moving average of how much the customer paid in a seven days window (i.e., current day + 6 days before). <code>average_amount</code> should be <strong>rounded to two decimal places</strong>.</p>

<p>Return the result table ordered by <code>visited_on</code> <strong>in ascending order</strong>.</p>

<p>The result format is in the following example.</p>

<p>&nbsp;</p>
<p><strong class="example">Example 1:</strong></p>

<pre>
<strong>Input:</strong> 
Customer table:
+-------------+--------------+--------------+-------------+
| customer_id | name         | visited_on   | amount      |
+-------------+--------------+--------------+-------------+
| 1           | Jhon         | 2019-01-01   | 100         |
| 2           | Daniel       | 2019-01-02   | 110         |
| 3           | Jade         | 2019-01-03   | 120         |
| 4           | Khaled       | 2019-01-04   | 130         |
| 5           | Winston      | 2019-01-05   | 110         | 
| 6           | Elvis        | 2019-01-06   | 140         | 
| 7           | Anna         | 2019-01-07   | 150         |
| 8           | Maria        | 2019-01-08   | 80          |
| 9           | Jaze         | 2019-01-09   | 110         | 
| 1           | Jhon         | 2019-01-10   | 130         | 
| 3           | Jade         | 2019-01-10   | 150         | 
+-------------+--------------+--------------+-------------+
<strong>Output:</strong> 
+--------------+--------------+----------------+
| visited_on   | amount       | average_amount |
+--------------+--------------+----------------+
| 2019-01-07   | 860          | 122.86         |
| 2019-01-08   | 840          | 120            |
| 2019-01-09   | 840          | 120            |
| 2019-01-10   | 1000         | 142.86         |
+--------------+--------------+----------------+
<strong>Explanation:</strong> 
1st moving average from 2019-01-01 to 2019-01-07 has an average_amount of (100 + 110 + 120 + 130 + 110 + 140 + 150)/7 = 122.86
2nd moving average from 2019-01-02 to 2019-01-08 has an average_amount of (110 + 120 + 130 + 110 + 140 + 150 + 80)/7 = 120
3rd moving average from 2019-01-03 to 2019-01-09 has an average_amount of (120 + 130 + 110 + 140 + 150 + 80 + 110)/7 = 120
4th moving average from 2019-01-04 to 2019-01-10 has an average_amount of (130 + 110 + 140 + 150 + 80 + 110 + 130 + 150)/7 = 142.86
</pre>

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

Il `WHERE` viene quindi eseguito **prima** del calcolo delle Window Functions.

---

## 💡 La soluzione: Stratificazione con una seconda CTE (`Calculated_table`)

Ho deciso di dividere ulteriormente il processo creando una seconda tabella temporanea (`Calculated_table`) in cui:

- calcolo la somma mobile;
- calcolo la media mobile;
- genero un indice progressivo dei giorni tramite `ROW_NUMBER() OVER (ORDER BY visited_on)`.

```sql
ROW_NUMBER() OVER (
    ORDER BY visited_on
) AS row_num
```

In questo modo:

- il primo giorno riceve `row_num = 1`;
- il secondo `row_num = 2`;
- ...
- il settimo `row_num = 7`.

A questo punto, nella query finale, posso filtrare semplicemente:

```sql
WHERE row_num >= 7
```

ottenendo esclusivamente i giorni che dispongono di una finestra completa di 7 giorni.

---

# Conclusione

Questo esercizio mi ha insegnato che le **Window Functions** non sostituiscono le aggregazioni tradizionali, ma le estendono.

La soluzione è stata costruita in tre passaggi logici:

1. **Aggregare** le transazioni giornaliere (`daily_Table`).
2. **Applicare** le Window Functions su dati già normalizzati nel tempo.
3. **Filtrare** i risultati tramite una seconda CTE, rispettando l'ordine di esecuzione di SQL.

Più che imparare una nuova sintassi, questo problema mi ha aiutato a comprendere come SQL elabori una query passo dopo passo e perché, spesso, suddividere il problema in CTE successive porta a una soluzione più chiara e corretta.
