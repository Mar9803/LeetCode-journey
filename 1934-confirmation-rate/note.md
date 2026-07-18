# Resoconto Tecnico: Risoluzione LeetCode 1934 (Confirmation Rate)

## 1. Il punto di partenza: la tua intuizione

Il tuo approccio iniziale ha dimostrato una buona comprensione della struttura delle relazioni tra le tabelle.

La query era la seguente:

```sql
SELECT
    s.user_id,
    COUNT(action) AS totale
FROM Signups s
LEFT JOIN Confirmations c
    ON s.user_id = c.user_id
GROUP BY s.user_id;
```

### I punti di forza del tuo codice

#### Uso corretto della `LEFT JOIN`

Hai intuito subito che, per non perdere gli utenti che non hanno ricevuto alcun messaggio di conferma (e che quindi devono avere un **confirmation rate pari a 0**), era necessario utilizzare una `LEFT JOIN`.

In questo modo la tabella `Signups` viene preservata integralmente, anche quando non esistono righe corrispondenti nella tabella `Confirmations`.

#### Raggruppamento corretto

Hai raggruppato i risultati tramite:

```sql
GROUP BY s.user_id
```

Utilizzare la chiave primaria dell'utente evita qualsiasi problema di omonimia o duplicazione, come visto negli esercizi precedenti.

### Il tassello mancante

La query calcolava correttamente il **numero totale di messaggi** inviati a ciascun utente.

Mancava però la logica necessaria per:

- individuare soltanto i messaggi con `action = 'confirmed'`;
- calcolare il rapporto tra conferme e messaggi totali.

---

# 2. La strada verso l'approccio corretto

Il problema richiede di implementare la seguente formula:

\[
\text{Confirmation Rate} =
\frac{\text{Messaggi Confermati}}
{\text{Messaggi Totali}}
\]

Per ottenere questo risultato era necessario introdurre una logica condizionale direttamente all'interno delle funzioni di aggregazione.

L'evoluzione della query è avvenuta in due passaggi.

---

## Passo A: Isolare i messaggi confermati con `CASE WHEN`

L'idea consiste nell'assegnare un valore numerico ad ogni riga:

- se `action = 'confirmed'` → valore **1**;
- altrimenti (`timeout` oppure `NULL`) → valore **0**.

La somma di questi valori restituisce esattamente il numero di conferme.

```sql
SUM(
    CASE
        WHEN c.action = 'confirmed' THEN 1
        ELSE 0
    END
)
```

---

## Passo B: Calcolare il tasso e arrotondare il risultato

Una volta ottenuti:

- il numeratore (messaggi confermati);
- il denominatore (messaggi totali);

è sufficiente eseguire la divisione e utilizzare:

```sql
ROUND(..., 2)
```

per ottenere il valore con **due cifre decimali**, come richiesto dal problema.

---

# 3. L'approccio finale (soluzione ottimizzata)

In SQL esiste una scorciatoia molto elegante.

Se una colonna contiene soltanto valori **0** e **1**, la funzione:

```sql
AVG(...)
```

calcola automaticamente la percentuale di valori pari a **1**.

Per questo motivo è possibile sostituire il rapporto:

```text
SUM(...) / COUNT(...)
```

con una semplice media.

La soluzione finale diventa quindi:

```sql
SELECT
    s.user_id,
    ROUND(
        AVG(
            IF(c.action = 'confirmed', 1, 0)
        ),
        2
    ) AS confirmation_rate
FROM Signups s
LEFT JOIN Confirmations c
    ON s.user_id = c.user_id
GROUP BY s.user_id;
```

### Perché funziona?

La funzione:

```sql
IF(c.action = 'confirmed', 1, 0)
```

trasforma ogni riga in:

| Azione | Valore |
|---------|--------|
| `confirmed` | 1 |
| `timeout` | 0 |
| `NULL` | 0 |

Successivamente:

```sql
AVG(...)
```

calcola automaticamente:

```text
(numero di 1) / (numero totale di righe)
```

che coincide esattamente con il **confirmation rate**.

Infine:

```sql
ROUND(..., 2)
```

arrotonda il risultato a due cifre decimali.

---

# 4. Tabella comparativa dell'evoluzione della query

| Caratteristica | Il tuo approccio iniziale | Soluzione finale |
|----------------|---------------------------|------------------|
| Obiettivo della metrica | Conteggio totale dei messaggi | Calcolo del tasso di conferma |
| Gestione degli utenti senza conferme | ✅ Corretta tramite `LEFT JOIN` | ✅ Preservata tramite `LEFT JOIN` |
| Filtro sulle azioni | ❌ Assente | ✅ `IF()` / `CASE WHEN` |
| Metodo di calcolo | `COUNT(action)` | `AVG(IF(...))` |
| Tipo di risultato | Numero intero | Numero decimale |
| Arrotondamento | ❌ Assente | ✅ `ROUND(..., 2)` |

---

# Conclusione

L'intuizione iniziale era già corretta nella parte più importante: utilizzare una **`LEFT JOIN`** per mantenere tutti gli utenti, anche quelli senza conferme.

L'evoluzione della soluzione è consistita nell'introdurre una logica condizionale capace di distinguere le conferme dai timeout.

Infine, sfruttando una proprietà matematica della funzione `AVG()`, la query è stata semplificata in una versione più compatta ed elegante, capace di calcolare direttamente il **confirmation rate** richiesto da LeetCode.