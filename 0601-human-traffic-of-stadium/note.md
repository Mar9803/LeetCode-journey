# 📝 Diario di Bordo: Human traffic of stadium (LeetCode 601)

## 1. Il Problema e l'Evoluzione del Ragionamento

L'obiettivo era trovare tutte le righe delle visite allo stadio che appartenessero ad almeno **3 ID consecutivi** con un numero di visitatori **maggiore o uguale a 100**.

---

## La prima intuizione (e il rischio di errore)

### L'idea iniziale

Applicare subito il filtro:

```sql
WHERE people >= 100
```

e successivamente utilizzare `LAG()` e `LEAD()` per verificare la consecutività degli ID.

### Perché non funzionava?

Filtrando immediatamente le righe con meno di 100 visitatori si creano dei **buchi artificiali** nel dataset.

Ad esempio:

| id | people |
|---:|-------:|
| 3 | 120 |
| 4 | 50 |
| 5 | 130 |

Dopo il filtro rimarrebbero solo:

| id | people |
|---:|-------:|
| 3 | 120 |
| 5 | 130 |

A questo punto `LAG()` e `LEAD()` vedrebbero gli ID `3` e `5` come righe adiacenti, anche se **non sono consecutivi**.

L'informazione sulla continuità degli ID verrebbe quindi alterata.

---

## 💡 La regola d'oro imparata

> **Calcola prima, filtra dopo.**

Le Window Functions devono lavorare sul dataset originale.

Solo dopo aver calcolato tutte le informazioni di contesto (`LAG()` e `LEAD()`) è corretto applicare il filtro finale.

---

# 2. La Strategia delle Triplette Simmetriche

L'obiettivo era trovare sequenze di **3 o più** righe consecutive.

La prima idea poteva essere utilizzare il pattern **Islands & Gaps**, ma sarebbe risultato più complesso del necessario.

Abbiamo invece osservato una proprietà molto interessante.

## L'idea chiave

Qualsiasi sequenza consecutiva composta da:

- 3 elementi
- 4 elementi
- 5 elementi
- ...

è costituita da una o più **triplette consecutive**.

Quindi è sufficiente individuare tutte le righe che appartengono ad almeno una tripletta valida.

In questo modo vengono automaticamente catturate anche le sequenze più lunghe.

---

## Scenario A

La riga corrente è la **prima** della tripletta.

Devono essere vere tutte queste condizioni:

- riga corrente ≥ 100
- riga successiva ≥ 100
- seconda riga successiva ≥ 100

e gli ID devono essere consecutivi:

```text
next_id_1 - id = 1

next_id_2 - id = 2
```

---

## Scenario B

La riga corrente è **al centro** della tripletta.

Devono valere:

- riga precedente ≥ 100
- riga corrente ≥ 100
- riga successiva ≥ 100

e gli ID devono essere consecutivi:

```text
id - prev_id_1 = 1

next_id_1 - id = 1
```

---

## Scenario C

La riga corrente è **l'ultima** della tripletta.

Devono valere:

- seconda riga precedente ≥ 100
- riga precedente ≥ 100
- riga corrente ≥ 100

con gli ID consecutivi:

```text
id - prev_id_1 = 1

prev_id_1 - prev_id_2 = 1
```

---

# 3. takeaways:

## 🚀 `LAG()` e `LEAD()` con offset personalizzati

### Cosa ho imparato

Le funzioni `LAG()` e `LEAD()` non sono limitate alla riga immediatamente precedente o successiva.

È possibile specificare un **offset**.

Esempio:

```sql
LAG(id, 2) OVER (ORDER BY id)

LEAD(id, 2) OVER (ORDER BY id)
```

Questo permette di recuperare dati di due righe prima o due righe dopo senza utilizzare costosi self join.

---

## 🎯 Precedenza degli operatori logici (`AND` / `OR`)

In SQL:

- `AND` ha priorità maggiore di `OR`.

Per questo motivo ogni scenario è stato racchiuso tra parentesi:

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

Le parentesi garantiscono che ogni scenario venga valutato come un blocco logico indipendente.

---

## 🗂️ Coerenza dell'ordinamento nelle Window Functions

Quando all'interno della stessa CTE vengono calcolate più Window Functions, è importante utilizzare sempre lo stesso criterio di ordinamento.

Ad esempio:

```sql
OVER (ORDER BY id)
```

oppure

```sql
OVER (ORDER BY visit_date)
```

ma sempre in maniera coerente per tutte le colonne calcolate.

In questo modo i valori restituiti da `LAG()` e `LEAD()` rimangono perfettamente allineati e descrivono lo stesso contesto temporale o sequenziale.

---

# Conclusione

Questo esercizio mi ha insegnato che non sempre il pattern più complesso è quello migliore.

Invece di ricorrere a **Islands & Gaps**, è stato possibile risolvere il problema con una semplice osservazione geometrica: ogni sequenza lunga contiene almeno una tripletta consecutiva.

Dal punto di vista tecnico ho consolidato:

- l'utilizzo avanzato di `LAG()` e `LEAD()` con offset personalizzati;
- l'importanza dell'ordine di esecuzione delle operazioni (calcolare prima, filtrare dopo);
- la precedenza tra operatori logici (`AND` e `OR`);
- la necessità di mantenere un ordinamento coerente nelle Window Functions.

Questo esercizio ha rafforzato ulteriormente il mio modo di ragionare sui problemi SQL, spingendomi a cercare prima la proprietà matematica del problema e solo dopo lo strumento SQL più adatto per implementarla.