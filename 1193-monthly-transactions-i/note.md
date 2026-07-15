# 📓 Diario di Bordo: LeetCode 1193 — Monthly Transactions I

## 🎯 La Missione

Calcolare, per ogni combinazione di **mese** e **paese**, quattro metriche fondamentali:

- Numero totale di transazioni.
- Importo totale di tutte le transazioni.
- Numero di transazioni approvate.
- Importo totale delle sole transazioni approvate.

---

# 🛠️ La Strategia d'Attacco

Per risolvere il problema abbiamo seguito un approccio strutturato in tre fasi.

## 1. Pulizia e Formattazione Temporale (Il "Preprocessing")

Le date nel database erano troppo granulari (es. `2018-12-18`).

Per poter raggruppare per mese, abbiamo creato una **CTE** (`estrai_mese`) utilizzando una funzione di formattazione della data.

### MySQL

```sql
DATE_FORMAT(trans_date, '%Y-%m')
```

### PostgreSQL

```sql
TO_CHAR(trans_date, 'YYYY-MM')
```

In questo modo tutte le transazioni dello stesso mese assumono lo stesso valore (`YYYY-MM`), facilitando il raggruppamento.

---

## 2. Raggruppamento (Aggregation Group)

Una volta estratto il mese, abbiamo utilizzato:

```sql
GROUP BY month, country
```

per definire la granularità finale del report.

Ogni riga del risultato rappresenta quindi una specifica coppia:

- mese
- paese

---

## 3. Aggregazione Condizionale (Il cuore della Fraud Analytics)

Invece di eseguire query separate o `JOIN` complessi, abbiamo calcolato sia le metriche complessive sia quelle riferite alle sole transazioni approvate utilizzando il costrutto:

```sql
CASE WHEN
```

all'interno delle funzioni di aggregazione.

Esempi:

Conteggio delle transazioni approvate:

```sql
COUNT(
    CASE
        WHEN state = 'approved'
        THEN 1
    END
)
```

Importo totale delle transazioni approvate:

```sql
SUM(
    CASE
        WHEN state = 'approved'
        THEN amount
        ELSE 0
    END
)
```

Questo pattern prende il nome di **Aggregazione Condizionale**.

---

# ⚠️ Le Trappole Superate (Lessons Learned)

Durante lo sviluppo abbiamo affrontato due errori molto comuni in SQL.

---

## ❌ Trappola 1: Il `COUNT()` che conta anche gli zeri

### Il Bug

```sql
COUNT(
    CASE
        WHEN state = 'approved'
        THEN 1
        ELSE 0
    END
)
```

Il risultato era il conteggio di **tutte** le transazioni.

### Perché succede?

`COUNT()` conta qualsiasi valore che non sia `NULL`.

Poiché:

```text
0 ≠ NULL
```

anche gli zeri vengono conteggiati.

---

### ✅ Soluzione 1

Usare `SUM()`.

```sql
SUM(
    CASE
        WHEN state = 'approved'
        THEN 1
        ELSE 0
    END
)
```

Qui vengono sommati gli 1 e gli 0.

---

### ✅ Soluzione 2

Lasciare che SQL restituisca `NULL`.

```sql
COUNT(
    CASE
        WHEN state = 'approved'
        THEN 1
    END
)
```

Le righe non approvate restituiscono implicitamente `NULL`, che `COUNT()` ignora.

---

## ❌ Trappola 2: Confondere `COUNT()` con `SUM()`

### Il Bug

Usare `COUNT()` per ottenere l'importo totale delle transazioni approvate.

### Perché è sbagliato?

- `COUNT()` conta il numero di righe.
- `SUM()` somma i valori numerici.

---

### ✅ Soluzione

```sql
SUM(
    CASE
        WHEN state = 'approved'
        THEN amount
        ELSE 0
    END
)
```

---

# 🧠 Concetti SQL consolidati

Con questo esercizio hai rafforzato diversi strumenti fondamentali.

## 📅 Formattazione delle date

Permette di modificare il formato di una data per adattarlo al raggruppamento.

MySQL

```sql
DATE_FORMAT(data, '%Y-%m')
```

PostgreSQL

```sql
TO_CHAR(data, 'YYYY-MM')
```

---

## 🎯 Aggregazione Condizionale

Pattern molto comune.

Schema mentale:

```text
CASE WHEN

↓

COUNT()
```

oppure

```text
CASE WHEN

↓

SUM()
```

Permette di calcolare più metriche differenti con una sola scansione della tabella.

---

## 🔢 COUNT() vs SUM()

### `COUNT()`

Conta il numero di valori **non NULL**.

```sql
COUNT(colonna)
```

### `SUM()`

Somma i valori numerici.

```sql
SUM(colonna)
```

Regola pratica:

- vuoi sapere **quante** righe soddisfano una condizione → `COUNT()` oppure `SUM(1/0)`
- vuoi sapere **quanto** vale una quantità → `SUM()`

---

## 🚨 Attenzione ai NULL

Ricorda sempre:

```text
COUNT()

↓

ignora i NULL
```

ma

```text
COUNT(0)

↓

conta lo 0
```

Questa è una delle fonti di errore più frequenti nelle query SQL.

---

# 💡 Perché questo esercizio è importante nella Fraud Detection?

Questo pattern viene utilizzato quotidianamente nei team di **Risk**, **Fraud** e **Data Analytics** per costruire le cosiddette **Velocity Features** e gli **User Profile**.

Ad esempio, invece di raggruppare per:

```text
country
```

potremmo raggruppare per:

```text
user_id
```

e limitare l'analisi alle ultime due ore.

Otterremmo immediatamente informazioni come:

- numero di pagamenti effettuati;
- importo totale speso;
- numero di transazioni approvate;
- valore economico delle operazioni approvate.

Queste metriche costituiscono spesso la base delle regole automatiche utilizzate dai sistemi antifrode per individuare comportamenti anomali o tentativi di attacco.

---

# 📌 Cosa porto a casa

Con questo esercizio ho consolidato:

- l'uso della formattazione delle date per il raggruppamento temporale;
- il pattern di **Aggregazione Condizionale** con `CASE WHEN`;
- la differenza tra `COUNT()` e `SUM()`;
- il comportamento di `COUNT()` nei confronti dei valori `NULL`;
- un pattern SQL largamente utilizzato in contesti reali di reporting, analytics e fraud detection.