# 📘 Report Tecnico — LeetCode 550: Game Play Analysis IV

## 🎯 Obiettivo del problema

Calcolare la frazione (arrotondata a **2 cifre decimali**) di giocatori che hanno effettuato un nuovo accesso **il giorno immediatamente successivo** al loro primo login.

In formula:

\[
\text{fraction} =
\frac{\text{Numero di giocatori rientrati il giorno dopo il primo login}}
{\text{Numero totale di giocatori unici}}
\]

---

# 🛑 Fase 1 — L'approccio diretto e la trappola degli alias

L'idea iniziale consisteva nel calcolare il primo login e verificare il login del giorno successivo direttamente nello stesso blocco di aggregazione.

### Tentativo iniziale

```sql
SELECT
    MIN(event_date) AS firstLog,
    COUNT(
        CASE
            WHEN event_date = DATE_ADD(firstLog, INTERVAL 1 DAY)
            THEN 1
        END
    ) / COUNT(DISTINCT player_id)
FROM Activity
GROUP BY player_id;
```

## ❌ Perché ha fallito?

### 1. Uso prematuro dell'alias (`firstLog`)

SQL valuta tutte le espressioni della `SELECT` contemporaneamente.

Di conseguenza **non è possibile utilizzare un alias appena definito** nello stesso livello della query.

---

### 2. Ambito del `GROUP BY`

Con

```sql
GROUP BY player_id
```

la query produce **una riga per ogni giocatore**, mentre il problema richiede **un'unica frazione globale**.

---

### 3. Mancanza dell'isolamento del primo login

Senza separare preventivamente

```sql
MIN(event_date)
```

per ciascun giocatore, quel valore non può essere riutilizzato come riferimento fisso per confrontare i login successivi.

---

# 📈 Fase 2 — Introduzione della CTE (`WITH`) e le insidie delle JOIN

Per isolare il primo login viene introdotta una **CTE (Common Table Expression)**.

### Tentativo intermedio

```sql
WITH estraifirst AS (
    SELECT
        player_id,
        MIN(event_date) AS firstlog
    FROM Activity
    GROUP BY player_id
)

SELECT
    ROUND(
        COUNT(
            CASE
                WHEN a.event_date = DATE_ADD(e.firstlog, INTERVAL 1 DAY)
                THEN 1
            END
        )
        /
        (SELECT COUNT(DISTINCT a.player_id) FROM Activity),
        2
    ) AS fraction
FROM Activity a, estraifirst e;
```

## ⚠️ Bug affrontati

### Cross Join involontaria

Scrivere

```sql
FROM Activity a, estraifirst e
```

senza una clausola `ON`

produce un **prodotto cartesiano**.

Ogni login viene confrontato con il primo login di **tutti** gli utenti.

---

### Alias errato nella sottoquery

Nel denominatore:

```sql
SELECT COUNT(DISTINCT a.player_id)
FROM Activity
```

l'alias `a` non è visibile all'interno della sottoquery.

Bisogna semplicemente scrivere:

```sql
SELECT COUNT(DISTINCT player_id)
FROM Activity
```

---

# 🏆 Fase 3 — La soluzione finale

```sql
WITH estraifirst AS (

    -- Primo login di ogni giocatore
    SELECT
        player_id,
        MIN(event_date) AS firstlog
    FROM Activity
    GROUP BY player_id
)

SELECT
    ROUND(
        COUNT(
            CASE
                WHEN a.event_date = DATE_ADD(e.firstlog, INTERVAL 1 DAY)
                THEN 1
            END
        )
        /
        (
            SELECT COUNT(DISTINCT player_id)
            FROM Activity
        ),
        2
    ) AS fraction
FROM Activity a
INNER JOIN estraifirst e
    ON a.player_id = e.player_id;
```

---

# 💡 Perché funziona?

### ✅ Isolamento del primo login

La CTE

```sql
estraifirst
```

calcola una sola volta il primo login di ogni giocatore.

---

### ✅ JOIN corretta (relazione 1:N)

```sql
INNER JOIN
```

associa ogni riga storica del giocatore con la sua data iniziale.

---

### ✅ Uso di `DATE_ADD`

```sql
DATE_ADD(firstlog, INTERVAL 1 DAY)
```

aggiunge un giorno in modo sicuro, evitando problemi legati a:

- cambio mese;
- cambio anno;
- anni bisestili.

---

### ✅ Denominatore corretto

```sql
SELECT COUNT(DISTINCT player_id)
FROM Activity
```

calcola il numero totale di utenti unici.

---

# 📊 Evoluzione della soluzione

| Fase | Problema | Causa | Soluzione |
|------|----------|--------|-----------|
| **Fase 1** | `Unknown column 'firstLog'` | Tentativo di riutilizzare un alias nella stessa `SELECT` | Isolare il primo login con una CTE |
| **Fase 2** | Prodotto cartesiano e alias errati | `FROM A, B` senza `JOIN ... ON` e alias non valido nella sottoquery | `INNER JOIN` e sottoquery corretta |
| **Fase 3** | ✅ Soluzione accettata | CTE + JOIN + `DATE_ADD()` + `ROUND()` | Query corretta e leggibile |

---

# 🎓 Conclusione

Nei problemi di **retention**, **cohort analysis** o confronti tra **giorno 0** e **giorno 1**, è fondamentale separare:

- **l'evento ancora** (ad esempio il primo login);
- **gli eventi successivi**.

Una **CTE** permette di fissare il primo evento in modo chiaro e riutilizzabile.

Successivamente è sufficiente collegare i dati tramite una `INNER JOIN` e utilizzare funzioni per la gestione delle date come `DATE_ADD()`.

Questa strategia evita gli errori più comuni legati a:

- alias non riutilizzabili;
- aggregazioni premature;
- `GROUP BY` nel livello sbagliato;
- prodotti cartesiani involontari.