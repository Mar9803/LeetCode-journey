# Resoconto Tecnico: Risoluzione LeetCode 1174 (Immediate Food Delivery II)

## 1. Fase 1: L'Approccio Intuitivo e i Blocchi di Sintassi

L'obiettivo iniziale era calcolare direttamente la percentuale degli ordini immediati, ottenendo contemporaneamente:

- il numero totale dei primi ordini;
- il numero dei primi ordini consegnati nella data preferita.

La prima versione della query era la seguente:

```sql
-- Tentativo iniziale (con errori di sintassi e logica)
SELECT
    ROUND(immediate / first_order * 100, 2) AS immediate_percentage,
    SUM(CASE WHEN d.order_date = MIN(d.order_date) THEN 1 ELSE 0 END) AS first_order,
    SUM(CASE WHEN d.order_date = d.customer_pref_delivery_date THEN 1 ELSE 0 END) AS immediate
FROM Delivery AS d;
```

### I vicoli ciechi incontrati

#### Errore `Unknown column`

La query tentava di utilizzare gli alias `immediate` e `first_order` nella stessa `SELECT` in cui venivano definiti.

In SQL questo non è possibile, perché tutte le espressioni della clausola `SELECT` vengono valutate contemporaneamente.

---

#### Aggregazioni annidate

L'espressione:

```sql
SUM(CASE WHEN d.order_date = MIN(d.order_date) THEN 1 ELSE 0 END)
```

non è valida.

SQL non consente di utilizzare una funzione di aggregazione (`MIN`) all'interno di un'altra funzione di aggregazione (`SUM`) nello stesso livello della query.

---

#### Mancanza di granularità

La ricerca del primo ordine non era eseguita per ogni singolo cliente (`customer_id`), ma sull'intera tabella.

Di conseguenza, il calcolo non rispettava la logica richiesta dall'esercizio.

---

## 2. Fase 2: L'Introduzione delle CTE (`WITH`) e la Caccia ai Bug

Compreso che il primo ordine doveva essere isolato prima dei conteggi, la strategia è cambiata introducendo delle **Common Table Expressions (CTE)**.

La struttura intermedia della soluzione era la seguente:

```sql
WITH step0 AS (
    SELECT
        customer_id,
        MIN(d.order_date) AS min_order_date
    FROM Delivery AS d
    GROUP BY d.customer_id
),
step1 AS (
    SELECT
        SUM(CASE WHEN d1.order_date = step0.min_order_date THEN 1 ELSE 0 END) AS first_order,
        SUM(CASE WHEN d1.order_date = d1.customer_pref_delivery_date THEN 1 ELSE 0 END) AS immediate
    FROM Delivery AS d1
    INNER JOIN step0
        ON d1.customer_id = step0.customer_id
    GROUP BY d1.customer_id
)
SELECT
    ROUND(SUM(step1.immediate) / SUM(step1.first_order) * 100, 2) AS immediate_percentage
FROM step1;
```

### Le correzioni sintattiche affrontate

#### Eliminazione dei doppi `WITH`

È stato necessario ricordare che la parola chiave `WITH` compare una sola volta, mentre le varie CTE vengono separate da una virgola.

---

#### Correzione degli alias

Sono stati sistemati gli alias delle tabelle (`d`, `d1` e `step0`) per rendere ogni riferimento coerente.

---

#### Aggregazione finale

Poiché `step1` produceva una riga per cliente (`GROUP BY customer_id`), il risultato finale doveva essere ottenuto tramite:

```sql
SUM(immediate) / SUM(first_order)
```

ottenendo così la percentuale complessiva.

---

## 3. Fase 3: Il Rompicapo del 75% (L'Ultimo Ostacolo Logico)

Una volta eliminati tutti gli errori sintattici, la query produceva comunque un risultato errato:

- **Output ottenuto:** `75.00`
- **Output atteso:** `50.00`

### La causa del problema

La `INNER JOIN` collegava `Delivery` e `step0` utilizzando solamente:

```sql
ON d1.customer_id = step0.customer_id
```

Questo significava che, per ogni cliente, venivano recuperati **tutti gli ordini effettuati**, non soltanto il primo.

Di conseguenza:

- `first_order` identificava correttamente il primo ordine;
- `immediate`, invece, conteggiava anche eventuali ordini successivi consegnati nella data preferita.

Il risultato finale risultava quindi sovrastimato.

---

## 4. La Soluzione Finale Approvata

La correzione decisiva è consistita nell'aggiungere un secondo vincolo alla `JOIN`:

```sql
AND d1.order_date = step0.min_order_date
```

In questo modo entrano nella seconda CTE **soltanto i primi ordini reali** di ciascun cliente.

Grazie a questo filtro è stato possibile semplificare ulteriormente la query, sostituendo il precedente `SUM(CASE...)` con un semplice `COUNT(*)`.

```sql
WITH step0 AS (
    -- Passo 1: individua la data del primo ordine di ogni cliente
    SELECT
        customer_id,
        MIN(order_date) AS min_order_date
    FROM Delivery
    GROUP BY customer_id
),
step1 AS (
    -- Passo 2: considera solo i primi ordini
    SELECT
        COUNT(*) AS first_order,
        SUM(
            CASE
                WHEN d1.order_date = d1.customer_pref_delivery_date THEN 1
                ELSE 0
            END
        ) AS immediate
    FROM Delivery AS d1
    INNER JOIN step0
        ON d1.customer_id = step0.customer_id
       AND d1.order_date = step0.min_order_date
    GROUP BY d1.customer_id
)
-- Passo 3: calcola la percentuale complessiva
SELECT
    ROUND(SUM(immediate) / SUM(first_order) * 100, 2) AS immediate_percentage
FROM step1;
```

### Perché funziona?

- `step0` individua il primo ordine di ogni cliente;
- la `JOIN` filtra esclusivamente quei primi ordini;
- `COUNT(*)` rappresenta il numero totale dei primi ordini;
- `SUM(CASE...)` conta solo quelli consegnati nella data preferita;
- il rapporto finale restituisce esattamente la percentuale richiesta da LeetCode.

---

## 5. Confronto dell'Evoluzione della Soluzione

| Fase | Problema | Causa | Soluzione |
|------|----------|-------|-----------|
| **Fase 1** | `Unknown column` e errori di sintassi | Utilizzo prematuro degli alias e `MIN()` dentro `SUM()` | Introduzione delle CTE (`WITH`) |
| **Fase 2** | Errori di compilazione | Alias incoerenti, doppi `WITH` e struttura non corretta | Pulizia della sintassi e organizzazione delle CTE |
| **Fase 3** | Output errato (`75.00%` invece di `50.00%`) | La `JOIN` includeva anche gli ordini successivi al primo | Aggiunta della condizione `AND d1.order_date = step0.min_order_date` |

---

## Conclusione

La difficoltà principale dell'esercizio non risiedeva nella formula della percentuale, ma nell'identificare correttamente **quali ordini dovessero essere inclusi nel calcolo**.

L'introduzione delle CTE ha permesso di separare il problema in passaggi logici, mentre l'aggiunta del filtro sulla data nella `INNER JOIN` ha eliminato definitivamente gli ordini successivi al primo.

Il risultato è una query chiara, modulare e pienamente conforme ai requisiti di LeetCode, capace di superare anche i casi limite previsti dai testcase.