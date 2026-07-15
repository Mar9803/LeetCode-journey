# 📚 SQL Cheat Sheet – Window Functions & Pattern Avanzati

Questo documento raccoglie i costrutti SQL più importanti emersi durante la risoluzione degli esercizi **LeetCode** 

---

# 🗂️ Common Table Expression (CTE)

Permette di creare una tabella temporanea virtuale.

## Sintassi

```sql
WITH nome_cte AS (
    SELECT ...
)
SELECT *
FROM nome_cte;
```

## Più CTE

```sql
WITH step1 AS (
    ...
),
step2 AS (
    ...
),
step3 AS (
    ...
)
SELECT *
FROM step3;
```

### Quando usarla

- dividere problemi complessi in più passaggi
- migliorare la leggibilità
- riutilizzare risultati intermedi

> 💡 `WITH` si scrive una sola volta.

---

# 📊 GROUP BY

Raggruppa le righe con lo stesso valore.

```sql
SELECT
    visited_on,
    SUM(amount)
FROM Customer
GROUP BY visited_on;
```

### Da ricordare

Con `GROUP BY` ogni colonna nella `SELECT` deve essere:

- presente nel `GROUP BY`
- oppure dentro una funzione di aggregazione.

---

# ➕ Funzioni di aggregazione

Le principali sono:

```sql
COUNT(*)

SUM(colonna)

AVG(colonna)

MAX(colonna)

MIN(colonna)
```

---

# 🎯 HAVING

Filtra i gruppi dopo il `GROUP BY`.

```sql
SELECT num
FROM table
GROUP BY num
HAVING COUNT(*) >= 3;
```

## Differenza

`WHERE`

↓

filtra le righe

`HAVING`

↓

filtra i gruppi

---

# 🪟 Window Functions

Le Window Functions calcolano valori senza perdere le righe originali.

Sintassi generale:

```sql
funzione() OVER(...)
```

---

# ORDER BY dentro OVER

Serve a definire l'ordine della finestra.

```sql
SUM(amount)
OVER(
    ORDER BY visited_on
)
```

Senza `ORDER BY` non esiste una progressione temporale.

---

# PARTITION BY

Divide i dati in gruppi indipendenti.

```sql
COUNT(*)
OVER(
    PARTITION BY department
)
```

Ogni partizione viene elaborata separatamente.

⚠️ Non serve per trovare sequenze consecutive.

---

# ROWS BETWEEN

Definisce la dimensione della finestra.

```sql
ROWS BETWEEN
6 PRECEDING
AND CURRENT ROW
```

Significa:

```
6 righe precedenti
+
riga corrente
```

Totale:

```
7 righe
```

Utilissimo per:

- medie mobili
- somme mobili
- finestre temporali

---

# SUM() OVER()

Somma cumulativa.

```sql
SUM(flag)
OVER(
    ORDER BY id
)
```

Produce:

```
1
1
1
2
2
3
3
```

Molto utile per creare identificatori di gruppo.

---

# AVG() OVER()

Media mobile.

```sql
AVG(amount)
OVER(
    ORDER BY visited_on
    ROWS BETWEEN 6 PRECEDING
    AND CURRENT ROW
)
```

---

# LAG()

Legge la riga precedente.

```sql
LAG(num)
OVER(
    ORDER BY id
)
```

Esempio

| id | num | lag |
|----|-----|-----|
|1|1|NULL|
|2|1|1|
|3|2|1|
|4|2|2|

Serve per confrontare righe consecutive.

---

# ROW_NUMBER()

Genera una numerazione progressiva.

```sql
ROW_NUMBER()
OVER(
    ORDER BY visited_on
)
```

Output

```
1
2
3
4
5
...
```

Perfetto per:

- eliminare le prime N righe
- ranking
- paginazione

---

# CASE WHEN

L'equivalente di un if.

```sql
CASE
    WHEN num = LAG(num)
    THEN 0
    ELSE 1
END
```

Molto usato per creare flag.

---

# Pattern: Running Total

Somma progressiva.

```sql
SUM(valore)
OVER(
    ORDER BY id
)
```

Output

```
5
8
15
20
...
```

---

# Pattern: Moving Window

Finestra mobile.

```sql
SUM(amount)
OVER(
ORDER BY data
ROWS BETWEEN 6 PRECEDING
AND CURRENT ROW
)
```

Usi tipici

- media ultimi 7 giorni
- vendite ultimi 30 giorni
- statistiche temporali

---

# Pattern: Islands & Gaps

Serve a trovare sequenze consecutive.

Schema mentale:

```
LAG()

↓

CASE

↓

Flag

↓

SUM() OVER()

↓

Group ID

↓

GROUP BY

↓

HAVING
```

È il pattern classico per esercizi sui valori consecutivi.

---

# Ordine di esecuzione SQL

Da ricordare sempre.

```
FROM

↓

WHERE

↓

GROUP BY

↓

HAVING

↓

SELECT

↓

Window Functions

↓

ORDER BY

↓

LIMIT
```

Per questo motivo non puoi scrivere:

```sql
WHERE ROW_NUMBER() > 5
```

nella stessa query.

Bisogna usare una CTE o una subquery.

---

# Errore ONLY_FULL_GROUP_BY

Errore tipico.

❌

```sql
SELECT
id,
COUNT(*)
FROM table
GROUP BY num;
```

Perché `id` non è aggregato.

✔️

```sql
SELECT
num,
COUNT(*)
FROM table
GROUP BY num;
```

oppure

```sql
SELECT
MAX(id),
COUNT(*)
FROM table
GROUP BY num;
```

---

# Quando usare cosa?

| Situazione | Strumento |
|------------|-----------|
| Raggruppare dati | `GROUP BY` |
| Filtrare gruppi | `HAVING` |
| Tabella temporanea | `WITH` |
| Confrontare con la riga precedente | `LAG()` |
| Numerare righe | `ROW_NUMBER()` |
| Somma progressiva | `SUM() OVER()` |
| Media mobile | `AVG() OVER()` |
| Finestra temporale | `ROWS BETWEEN` |
| Dividere dati in partizioni | `PARTITION BY` |
| Logica condizionale | `CASE WHEN` |
| Sequenze consecutive | Pattern **Islands & Gaps** |

---

# 🧠 Regole d'oro

- Usa una **CTE** quando la query diventa difficile da leggere.
- Le **Window Functions** non riducono il numero di righe.
- `GROUP BY` riduce il numero di righe.
- `HAVING` lavora sui gruppi.
- `WHERE` lavora sulle righe.
- `LAG()` permette di confrontare una riga con la precedente.
- `ROWS BETWEEN` definisce una finestra mobile.
- `SUM() OVER()` crea una somma cumulativa.
- `ROW_NUMBER()` assegna un indice progressivo.
- Per trovare sequenze consecutive pensa subito al pattern **Islands & Gaps**.
```