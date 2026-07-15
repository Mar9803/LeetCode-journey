# 📚 SQL Cheat Sheet – Window Functions & Pattern Avanzati

Questo documento raccoglie i costrutti SQL più importanti emersi durante la risoluzione degli esercizi **LeetCode SQL**.

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

```
WHERE

↓

Filtra le righe
```

```
HAVING

↓

Filtra i gruppi
```

---

# 🪟 Window Functions

Le Window Functions calcolano valori mantenendo tutte le righe originali.

Sintassi generale:

```sql
funzione()
OVER(...)
```

---

# ORDER BY dentro OVER

Definisce l'ordine con cui la Window Function scorre le righe.

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

=

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

Legge una riga precedente.

```sql
LAG(colonna)
OVER(
    ORDER BY id
)
```

## Esempio

| id | num | lag |
|----|-----|-----|
|1|1|NULL|
|2|1|1|
|3|2|1|
|4|2|2|

Serve per confrontare la riga corrente con una precedente.

---

# LEAD()

Legge una riga successiva.

```sql
LEAD(colonna)
OVER(
    ORDER BY id
)
```

## Esempio

| id | people | lead |
|----|--------|------|
|1|120|150|
|2|150|80|
|3|80|200|
|4|200|NULL|

Serve per confrontare la riga corrente con una successiva.

---

# Offset in LAG() e LEAD()

Per default entrambe lavorano con offset = 1.

È possibile specificarne uno diverso.

```sql
LAG(id,2)
OVER(
    ORDER BY id
)
```

```sql
LEAD(id,2)
OVER(
    ORDER BY id
)
```

Significato:

```
offset = 1

↓

riga precedente/successiva
```

```
offset = 2

↓

due righe prima/dopo
```

```
offset = 3

↓

tre righe prima/dopo
```

Questo evita di dover concatenare molte Window Functions.

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

L'equivalente di un `if`.

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

Schema mentale

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

# Pattern: Triplette Consecutive

Quando il problema richiede almeno **3 elementi consecutivi**, non sempre serve usare Islands & Gaps.

Basta verificare le tre possibili posizioni della riga corrente.

Scenario A

```
Corrente

↓

Successiva

↓

Successiva
```

Scenario B

```
Precedente

↓

Corrente

↓

Successiva
```

Scenario C

```
Precedente

↓

Precedente

↓

Corrente
```

Se almeno uno scenario è valido, la riga appartiene a una sequenza consecutiva.

---

# Ordine di esecuzione SQL

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

Per questo motivo non puoi scrivere

```sql
WHERE ROW_NUMBER() > 5
```

nella stessa query.

Serve una CTE o una subquery.

---

# Calcola prima, filtra dopo

Le Window Functions lavorano sul dataset corrente.

❌

```sql
WHERE people >= 100

↓

LAG()

↓

LEAD()
```

Il filtro modifica il contesto e può rompere la consecutività.

✔️

```sql
LAG()

↓

LEAD()

↓

WHERE
```

Prima si calcola il contesto.

Poi si filtrano i risultati.

---

# Precedenza degli operatori logici

Ordine di priorità:

```
NOT

↓

AND

↓

OR
```

Quando si combinano molti scenari è buona norma usare sempre le parentesi.

```sql
(
    Scenario A
)
OR
(
    Scenario B
)
OR
(
    Scenario C
)
```

---

# Coerenza dell'ORDER BY

Quando utilizzi più Window Functions nella stessa query, usa sempre lo stesso criterio di ordinamento.

```sql
LAG(id)
OVER(ORDER BY id)

LEAD(id)
OVER(ORDER BY id)

ROW_NUMBER()
OVER(ORDER BY id)
```

Così tutte le funzioni fanno riferimento allo stesso ordine logico.

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
| Confrontare con la riga successiva | `LEAD()` |
| Numerare righe | `ROW_NUMBER()` |
| Somma progressiva | `SUM() OVER()` |
| Media mobile | `AVG() OVER()` |
| Finestra temporale | `ROWS BETWEEN` |
| Dividere dati in partizioni | `PARTITION BY` |
| Logica condizionale | `CASE WHEN` |
| Sequenze consecutive lunghe | Pattern **Islands & Gaps** |
| Sequenze di almeno 3 elementi | Pattern **Triplette Consecutive** |

---

# 🧠 Regole d'oro

- Usa una **CTE** quando la query diventa difficile da leggere.
- Le **Window Functions** non riducono il numero di righe.
- `GROUP BY` riduce il numero di righe.
- `HAVING` lavora sui gruppi.
- `WHERE` lavora sulle righe.
- `LAG()` guarda indietro.
- `LEAD()` guarda avanti.
- `LAG()` e `LEAD()` possono usare un offset (`2`, `3`, ...).
- `ROWS BETWEEN` definisce una finestra mobile.
- `SUM() OVER()` crea una somma cumulativa.
- `ROW_NUMBER()` assegna un indice progressivo.
- Calcola sempre le Window Functions prima di filtrare i dati.
- Usa le parentesi quando combini molti `AND` e `OR`.
- Mantieni coerente l'`ORDER BY` in tutte le Window Functions della stessa query.
- Per trovare sequenze consecutive pensa prima al pattern più adatto: **Islands & Gaps** oppure **Triplette Consecutive**.


# Pattern: Aggregazione Condizionale

## Quando usarlo

Quando devi calcolare **più metriche sullo stesso gruppo** (conteggi, somme, KPI) senza eseguire query separate.

Esempi tipici:

- dashboard
- report mensili
- analytics
- fraud detection

---

## Funzioni coinvolte

- `GROUP BY`
- `CASE WHEN`
- `COUNT()`
- `SUM()`
- `DATE_FORMAT()` *(MySQL)* / `TO_CHAR()` *(PostgreSQL)* *(se serve un raggruppamento temporale)*

---

## Schema mentale

```text
Pulizia dati (opzionale)

↓

GROUP BY

↓

CASE WHEN

↓

COUNT() / SUM()

↓

Report finale
```

---

## Sintassi

### Conteggio condizionale

```sql
COUNT(
    CASE
        WHEN condizione
        THEN 1
    END
)
```

oppure

```sql
SUM(
    CASE
        WHEN condizione
        THEN 1
        ELSE 0
    END
)
```

---

### Somma condizionale

```sql
SUM(
    CASE
        WHEN condizione
        THEN importo
        ELSE 0
    END
)
```

---

## ⚠️ Attenzione

- `COUNT()` conta tutti i valori **non NULL** (anche `0`).
- Per sommare importi usa sempre `SUM()`, non `COUNT()`.
- Se devi raggruppare per mese, normalizza prima la data con `DATE_FORMAT()` o `TO_CHAR()`.