# Resoconto Tecnico: Risoluzione LeetCode 1633 (Percentage of Users Attended a Contest)

## 1. L'Approccio Iniziale: La Trappola della `LEFT JOIN`

L'idea iniziale prevedeva l'uso di una `LEFT JOIN`, posizionando la tabella `Users` a sinistra e `Register` a destra, con l'obiettivo di non perdere nessun utente nel calcolo.

```sql
SELECT
    r.contest_id,
    ROUND((COUNT(r.user_id) / (SELECT COUNT(*) FROM Users)) * 100, 2) AS percentage
FROM Users AS u
LEFT JOIN Register AS r
    ON r.user_id = u.user_id
GROUP BY r.contest_id
ORDER BY percentage DESC, contest_id ASC;
```

### Perché superava il primo testcase ma falliva subito dopo?

#### Il comportamento nei casi reali

Nei database più complessi (o nei testcase successivi di LeetCode) esistono utenti **inattivi**, cioè utenti presenti nella tabella `Users` ma che non risultano iscritti ad alcun contest nella tabella `Register`.

#### La creazione dei record `NULL`

A causa della `LEFT JOIN`, il motore SQL è obbligato a mantenere questi utenti nell'output temporaneo. Non avendo alcuna corrispondenza nella tabella `Register`, tutte le colonne provenienti da essa (compreso `contest_id`) vengono valorizzate con `NULL`.

#### Il raggruppamento fantasma

Quando viene eseguito:

```sql
GROUP BY r.contest_id
```

SQL considera `NULL` come un valore raggruppabile, creando automaticamente un gruppo aggiuntivo.

Il risultato è una riga indesiderata simile a:

| contest_id | percentage |
|------------|-----------:|
| `NULL` | `0.00` |

Questa riga extra non è prevista dall'esercizio e provoca il fallimento dei testcase.

---

## 2. La Strada verso l'Approccio Corretto: Capovolgere la Logica

Per evitare la generazione di righe con valori `NULL`, non è necessario includere gli utenti che non partecipano ad alcun contest.

L'obiettivo del problema è infatti calcolare la percentuale degli utenti iscritti ai contest, quindi è sufficiente lavorare esclusivamente con le registrazioni realmente esistenti.

Esistono due possibili soluzioni:

1. utilizzare una `INNER JOIN`, eliminando automaticamente le righe prive di corrispondenza;
2. partire direttamente dalla tabella `Register`, soluzione ancora più semplice ed efficiente.

Poiché `Register` contiene già tutti gli `user_id` dei partecipanti, non serve effettuare alcuna join per identificarli. È sufficiente conoscere il numero totale degli utenti tramite una sottoquery.

---

## 3. L'Approccio Finale Approvato (Logica "Inner")

Eliminando la dipendenza dalla `LEFT JOIN` e utilizzando direttamente la tabella delle registrazioni, la query diventa molto più pulita:

```sql
SELECT
    contest_id,
    ROUND(
        (COUNT(user_id) / (SELECT COUNT(*) FROM Users)) * 100,
        2
    ) AS percentage
FROM Register
GROUP BY contest_id
ORDER BY percentage DESC, contest_id ASC;
```

### Perché funziona?

- vengono considerate solo registrazioni realmente esistenti;
- non esistono record con `contest_id = NULL`;
- il `GROUP BY` produce esclusivamente gruppi validi;
- la sottoquery

```sql
(SELECT COUNT(*) FROM Users)
```

fornisce dinamicamente il numero totale degli utenti registrati alla piattaforma.

> **Nota:** se il problema avesse richiesto anche informazioni sugli utenti (ad esempio il nome), sarebbe stato corretto utilizzare una `INNER JOIN` partendo da `Register` verso `Users`, mantenendo comunque l'assenza di righe `NULL`.

---

## 4. Confronto tra i Due Approcci

| Caratteristica | Approccio con `LEFT JOIN` | Approccio Definitivo (`Register` / `INNER`) |
|----------------|---------------------------|---------------------------------------------|
| Tabella di partenza (`FROM`) | `Users` (include anche chi non partecipa) | `Register` (solo partecipazioni reali) |
| Gestione utenti inattivi | Mantenuti con valori `NULL` | Esclusi fin dall'inizio |
| Risultato del `GROUP BY` | Genera un gruppo `NULL` | Genera solo `contest_id` validi |
| Complessità | Maggiore | Più semplice |
| Output finale | Contiene righe spurie | Pulito |
| Esito su LeetCode | ❌ Fallito | ✅ Superato |

---

## Conclusione

L'errore non era nel calcolo della percentuale, ma nella scelta della tabella di partenza.

Una `LEFT JOIN` è utile quando si desidera mantenere anche i record senza corrispondenza, ma in questo esercizio tali record introducono un gruppo `NULL` indesiderato.

Partire direttamente da `Register` (oppure utilizzare una `INNER JOIN`) permette invece di lavorare solo con i dati realmente significativi, ottenendo una soluzione più semplice, più efficiente e conforme ai testcase di LeetCode.