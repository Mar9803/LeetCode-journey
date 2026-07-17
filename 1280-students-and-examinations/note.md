# Resoconto Tecnico: Risoluzione LeetCode 1280 (Students and Examinations)

## 1. Il punto di partenza: il tuo approccio

Il tuo approccio iniziale si è concentrato sull'unione diretta tra gli studenti e gli esami effettivamente sostenuti.

Dopo aver corretto l'errore di sintassi della `GROUP BY`, la query si presentava così:

```sql
SELECT
    s.student_id,
    s.student_name,
    e.subject_name,
    COUNT(*) AS attended_exams
FROM Students s
INNER JOIN Examinations e
    ON s.student_id = e.student_id
GROUP BY
    s.student_id,
    s.student_name,
    e.subject_name;
```

### Perché questo approccio era incompleto?

#### Il limite della `INNER JOIN`

Questa query mostra **solo gli studenti che hanno sostenuto almeno un esame**. Se uno studente non ha mai partecipato a una sessione (come **Alex**), viene completamente escluso dal risultato.

#### Il limite delle materie mancanti

Se uno studente ha sostenuto l'esame di **Matematica** ma non quello di **Fisica**, la riga relativa a **Fisica** non comparirà mai.

#### Il comportamento di `COUNT(*)`

`COUNT(*)` conta indiscriminatamente tutte le righe del gruppo, rendendo impossibile ottenere uno **0** quando non esistono esami corrispondenti.

---

# 2. La strada verso l'approccio corretto

Per soddisfare i requisiti del problema (mostrare **tutti gli studenti per tutte le materie**, anche con **0 esami**), la strategia deve cambiare radicalmente.

Si procede attraverso tre passaggi logici.

## Passo A: Generare la "griglia fissa" (`CROSS JOIN`)

Prima di contare gli esami reali, bisogna creare una matrice ideale contenente ogni studente abbinato a ogni materia esistente, indipendentemente dalle presenze.

**Strumento:** `CROSS JOIN`

**Risultato:**

Se ci sono:

- 4 studenti
- 3 materie

si ottiene una base di:

```
4 × 3 = 12 righe
```

---

## Passo B: Sovrapporre i dati reali (`LEFT JOIN`)

Sulla griglia appena creata vengono sovrapposti gli esami realmente sostenuti.

**Strumento:** `LEFT JOIN`

### Condizione di join

Bisogna verificare contemporaneamente:

- l'ID dello studente
- la materia

```sql
ON s.student_id = e.student_id
AND sub.subject_name = e.subject_name
```

### Risultato

- Se l'esame esiste → i dati vengono associati.
- Se l'esame non esiste → le colonne provenienti da `Examinations` assumono valore `NULL`.

---

## Passo C: Contare in modo selettivo (`COUNT(colonna)`)

Per evitare che una riga con valori `NULL` venga conteggiata come un esame, è necessario modificare la funzione di aggregazione.

### Soluzione

Sostituire:

```sql
COUNT(*)
```

con:

```sql
COUNT(e.subject_name)
```

### Regola SQL

`COUNT(colonna)` **ignora automaticamente i valori `NULL`**.

Di conseguenza:

- se esistono esami → restituisce il numero corretto;
- se non esistono esami → restituisce **0**.

---

# 3. L'approccio corretto (soluzione finale)

Unendo i tre passaggi logici e aggiungendo l'ordinamento richiesto da LeetCode, si ottiene la query finale.

```sql
SELECT
    s.student_id,
    s.student_name,
    sub.subject_name,
    COUNT(e.subject_name) AS attended_exams
FROM Students s
CROSS JOIN Subjects sub
LEFT JOIN Examinations e
    ON s.student_id = e.student_id
    AND sub.subject_name = e.subject_name
GROUP BY
    s.student_id,
    s.student_name,
    sub.subject_name
ORDER BY
    s.student_id,
    sub.subject_name;
```

---

# 4. Tabella comparativa dei due approcci

| Funzionalità | Il tuo approccio | Approccio corretto |
|--------------|------------------|--------------------|
| Relazione iniziale | Studenti → Esami sostenuti | Studenti × Tutte le materie |
| JOIN principale | `INNER JOIN` | `CROSS JOIN` + `LEFT JOIN` |
| Studenti senza esami | ❌ Esclusi | ✅ Inclusi |
| Materie non sostenute | ❌ Non compaiono | ✅ Compaiono con valore 0 |
| Metodo di conteggio | `COUNT(*)` | `COUNT(e.subject_name)` |
| Gestione degli zeri | Riga assente | Riga presente con valore **0** |

---

# Conclusione

La differenza fondamentale tra i due approcci è il **punto di partenza**.

- Con la `INNER JOIN` si parte dagli **esami realmente esistenti**, quindi tutto ciò che manca non può essere mostrato.
- Con la combinazione `CROSS JOIN` + `LEFT JOIN` si parte invece da **tutte le possibili combinazioni studente–materia**, per poi verificare quali esami esistono realmente.

Infine, l'utilizzo di `COUNT(e.subject_name)` permette di sfruttare il comportamento di SQL sui valori `NULL`, ottenendo automaticamente **0** quando uno studente non ha sostenuto un determinato esame.