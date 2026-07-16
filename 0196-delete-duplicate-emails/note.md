# Diario di Bordo: Risoluzione LeetCode 196

## Problema: Delete Duplicate Emails (LeetCode 196)

**Pattern Applicato:** Gradual Self-Join Isolation (Isolamento progressivo tramite SELECT)

---

## 1. La Strategia Metodologica: "Select before Delete"

Per evitare errori di logica o cancellazioni accidentali, l'approccio migliore non è scrivere subito un'istruzione `DELETE`, bensì costruire una query di selezione (`SELECT *`) che isoli progressivamente ed esclusivamente le righe che dovranno essere eliminate.

Una volta ottenuto il set di dati corretto, basterà convertire la query in una rimozione fisica.

**Principio chiave:** Il problema richiede di confrontare i record di una tabella con altri record della tabella stessa. Questo rende necessario l'utilizzo di un **Self-Join** (alias `p1` e `p2`).

---

## 2. Costruzione Graduale della Query

### Step 1: Il Self-Join di base (Accoppiamento per Email)

Il primo passo consiste nell'unire la tabella a se stessa usando l'uguaglianza delle email come criterio di accoppiamento:

```sql
SELECT *
FROM Person p1
INNER JOIN Person p2
    ON p1.email = p2.email;