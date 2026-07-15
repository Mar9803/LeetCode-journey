##SoLuzione 1 NON OTTIMA

# 📝 Diario di Bordo: La Sfida dei Numeri Consecutivi (LeetCode 180)

## 1. Il Problema e il Fallimento del Primo Approccio

L'obiettivo era trovare i numeri che appaiono **consecutivamente per almeno tre volte** in una tabella.

### L'idea iniziale

Usare una classica Window Function, ad esempio:

```sql
COUNT(num) OVER (PARTITION BY num)
```

per contare quante volte compariva ogni numero.

### Perché è fallito?

Le Window Functions basate su `PARTITION BY` aggregano i dati **per valore**, ma **non tengono conto della posizione consecutiva** (cioè dell'ordine delle righe).

Ad esempio, se la tabella contiene:

| id | num |
|---:|----:|
| 1 | 1 |
| 2 | 1 |
| 3 | 1 |
| 4 | 2 |
| 5 | 1 |

`COUNT(num) OVER (PARTITION BY num)` conterebbe **4 occorrenze** del numero `1`, ignorando completamente il fatto che l'ultimo `1` sia separato dalla sequenza precedente.

Avevamo quindi bisogno di un modo per individuare le **interruzioni** (*gaps*) tra le sequenze di numeri consecutivi.

---

## 2. La Svolta: L'Approccio "Islands & Gaps"

Per risolvere il problema abbiamo ricostruito l'ordine dei dati e diviso la tabella in tante **isole** (blocchi di valori consecutivi).

L'approccio si sviluppa in tre passaggi logici.

### Step 1: Rilevare il cambio (Il Flag)

Grazie alla funzione `LAG()`, abbiamo confrontato ogni numero con quello della riga precedente.

Se il numero era diverso, significava che la sequenza si era interrotta.

Abbiamo quindi creato un flag:

- `0` → il numero è uguale al precedente (la sequenza continua);
- `1` → il numero cambia (inizia una nuova sequenza).

---

### Step 2: Creare l'ID del Gruppo (La Somma Cumulativa)

Abbiamo eseguito una **somma progressiva** del flag.

Ogni volta che il flag valeva `1`, la somma aumentava di uno, generando automaticamente un nuovo `group_id`.

Finché il flag rimaneva `0`, la somma non cambiava e tutte quelle righe continuavano ad appartenere allo stesso gruppo.

In questo modo ogni sequenza consecutiva riceve un identificatore univoco.

---

### Step 3: Filtrare le Sequenze

Una volta isolate tutte le sequenze, è bastato:

- raggruppare per `group_id`;
- contare quante righe appartenevano a ogni gruppo;
- mantenere solo i gruppi con almeno **3 righe**.

---

# 3. Il Bagaglio Tecnico: Cosa ho imparato

## 🛠️ `LAG()`

### Cosa fa

Permette di "sbirciare" la riga precedente senza dover eseguire un complicato **self join** della tabella.

### Sintassi

```sql
LAG(colonna) OVER (ORDER BY ordinamento)
```

La clausola `OVER` è obbligatoria perché indica a SQL in quale ordine deve guardare le righe precedenti.

---

## 🔀 `CASE WHEN ... THEN ... ELSE ... END`

### Cosa fa

È l'equivalente dell'istruzione `if...else` dei linguaggi di programmazione.

Permette di trasformare condizioni logiche in valori.

Nel nostro caso è servito per generare il flag:

- `0` → continua la sequenza;
- `1` → inizia una nuova sequenza.

---

## ➕ `SUM(...) OVER (ORDER BY ...)`

### Cosa fa

Quando `SUM()` viene utilizzata insieme a `OVER (ORDER BY ...)`, non calcola una somma totale della tabella.

Calcola invece una **somma cumulativa** (running total), aggiornandosi riga dopo riga.

È proprio questa caratteristica che permette di trasformare i flag in identificatori di gruppo (`group_id`).

---

## 🎯 `HAVING`

### Cosa fa

`HAVING` è molto simile a `WHERE`, ma opera **dopo il raggruppamento**.

### Differenza rispetto a `WHERE`

- `WHERE` filtra le righe **prima** del `GROUP BY`;
- `HAVING` filtra i gruppi **dopo** il `GROUP BY`.

Nel nostro caso abbiamo scritto:

```sql
HAVING COUNT(*) >= 3
```

per mantenere solamente le sequenze lunghe almeno tre elementi.

---

## 🗂️ CTE Multiple (`WITH ... AS`)

### Cosa fanno

Le Common Table Expressions permettono di costruire query modulari, suddividendole in più passaggi logici.

Ad esempio:

- Step 1
- Step 2
- Step 3

Ogni CTE rappresenta una tabella temporanea virtuale che rende il codice molto più leggibile e semplice da debuggare.

### Regola d'oro imparata

La parola chiave `WITH` si scrive **una sola volta** all'inizio della query.

Le CTE successive si separano semplicemente con una virgola:

```sql
WITH step1 AS (...),
step2 AS (...),
step3 AS (...)
SELECT ...
```

---

## ⚠️ Errore `ONLY_FULL_GROUP_BY`

### Cosa ho imparato

Quando si utilizza un `GROUP BY`, tutte le colonne presenti nella `SELECT` devono rispettare una delle due condizioni:

- essere incluse nel `GROUP BY`;
- oppure essere racchiuse in una funzione di aggregazione (`MAX()`, `MIN()`, `SUM()`, `COUNT()`, ecc.).

Non è possibile lasciare colonne "libere" nella `SELECT`, perché il database non saprebbe quale valore scegliere tra quelli appartenenti allo stesso gruppo.

---

# Conclusione

Questo esercizio mi ha insegnato uno degli schemi più importanti nell'analisi dei dati con SQL: il pattern **Islands & Gaps**.

Oltre a imparare nuove funzioni come `LAG()`, ho consolidato concetti fondamentali come le **Window Functions**, le **CTE**, le **somme cumulative**, l'utilizzo corretto di `HAVING` e il motivo per cui esiste il vincolo `ONLY_FULL_GROUP_BY`.

Più che una semplice query, è stato un esercizio di ragionamento: scomporre il problema in piccoli passaggi logici fino ad arrivare a una soluzione pulita e leggibile.


##SOLUIZONE 2 OTTIMALE

WITH Confronto AS (
    SELECT num,
           -- Guarda 1 riga indietro
           LAG(num, 1) OVER (ORDER BY id) AS prev1,
           -- Guarda 2 righe indietro
           LAG(num, 2) OVER (ORDER BY id) AS prev2
    FROM Logs
)
SELECT DISTINCT num AS ConsecutiveNums
FROM Confronto
WHERE num = prev1 AND num = prev2;
