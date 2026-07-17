# Resoconto Tecnico: Risoluzione LeetCode 570 (Managers with at Least 5 Direct Reports)

## 1. Il primo approccio: la trappola dell'omonimia

Nel tuo primo tentativo hai giustamente intuito la necessità di una **Self JOIN** (unire la tabella con se stessa) per collegare i manager ai rispettivi dipendenti.

Il codice si presentava così:

```sql
WITH extract AS (
    SELECT
        e1.name AS name,
        COUNT(e1.name) AS cont
    FROM Employee e1
    INNER JOIN Employee e2
        ON e1.id = e2.managerId
    GROUP BY name
    HAVING cont >= 5
)
SELECT name
FROM extract;
```

### Il problema: raggruppare per `name`

Il testcase di LeetCode ha fallito perché l'output attendeva **due manager chiamati "John"**, mentre la query ne ha restituito soltanto uno.

### Cosa è successo?

All'interno dell'azienda esistono due persone differenti con lo stesso nome:

- John (ID 101)
- John (ID 102)

Poiché la query utilizza:

```sql
GROUP BY name
```

SQL considera entrambi i manager come un'unica entità.

Di conseguenza:

- i dipendenti del primo John;
- i dipendenti del secondo John;

vengono aggregati nello stesso gruppo e conteggiati insieme.

> ⚠️ **Regola d'oro dei database**
>
> I nomi non sono mai identificativi univoci. Per distinguere correttamente le entità (persone, prodotti, città, ecc.) bisogna sempre utilizzare la **chiave primaria (`id`)**.

---

# 2. Il secondo approccio: JOIN e raggruppamento corretto

Per risolvere il problema mantenendo la struttura con la **CTE (`WITH`)**, è sufficiente cambiare il criterio di raggruppamento.

Invece di raggruppare per nome, bisogna raggruppare per l'identificativo univoco del manager (`e1.id`).

Per evitare inoltre l'errore `ONLY_FULL_GROUP_BY`, è necessario inserire anche `e1.name` nella clausola `GROUP BY`.

## Il codice corretto

```sql
WITH extract AS (
    SELECT
        e1.id,
        e1.name AS name,
        COUNT(e2.id) AS cont
    FROM Employee e1
    INNER JOIN Employee e2
        ON e1.id = e2.managerId
    GROUP BY
        e1.id,
        e1.name
    HAVING cont >= 5
)
SELECT name
FROM extract;
```

### Perché funziona?

Il raggruppamento avviene su:

```sql
GROUP BY e1.id, e1.name
```

Poiché ogni manager possiede un ID differente, SQL crea un gruppo separato per ciascuno di essi.

Anche se due persone si chiamano entrambe **John**, avranno due gruppi distinti:

| ID | Nome | Gruppo |
|----|------|---------|
| 101 | John | Gruppo 1 |
| 102 | John | Gruppo 2 |

Di conseguenza il conteggio dei dipendenti viene effettuato correttamente per ogni manager.

---

# 3. Tabella comparativa dei due approcci

| Caratteristica | Primo approccio (Errato) | Secondo approccio (Corretto) |
|----------------|---------------------------|-------------------------------|
| Criterio di raggruppamento | `GROUP BY name` | `GROUP BY e1.id, e1.name` |
| Gestione degli omonimi | ❌ Unisce persone con lo stesso nome | ✅ Mantiene separate le persone grazie all'ID |
| Precisione del `COUNT()` | Somma i dipendenti di tutti i "John" | Conta i dipendenti del singolo manager |
| Identificatore utilizzato | Nome | Chiave primaria (`id`) |
| Esito del testcase | ❌ Fallito | ✅ Superato |

---

# Conclusione

L'errore non riguardava la **JOIN**, che era stata impostata correttamente, ma il criterio di raggruppamento.

Il principio fondamentale è:

- utilizzare il **nome** per visualizzare i dati;
- utilizzare la **chiave primaria (`id`)** per identificarli e raggrupparli.

Questa distinzione evita problemi di omonimia e garantisce risultati corretti anche quando più record condividono lo stesso nome.