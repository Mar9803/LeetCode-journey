# 📝 Report di Studio: Soluzione "Sales by Match" (Sock Merchant)

## 🎯 Obiettivo del Problema

Dato un array di numeri interi in cui ogni numero rappresenta il colore di un calzino, determinare il numero massimo di coppie dello stesso colore che si possono formare.

---

## 🛑 Tentativo 1: Approccio ingenuo (Brute Force) — Sbagliato / Inefficiente

### Idea iniziale

Scorrere l'array con un doppio ciclo `for` annidato.

Per ogni calzino:

- cercare un gemello nel resto della lista;
- eliminarli entrambi una volta trovati;
- incrementare il contatore delle coppie.

### Perché non è la soluzione ideale

- **Complessità temporale:** `O(N²)`
  - Con array molto grandi (test avanzati di HackerRank) il codice termina con **Time Limit Exceeded (Timeout)**.

- **Gestione degli indici**
  - Eliminare o modificare elementi durante l'iterazione porta facilmente a bug logici e a conteggi errati.

---

## 📈 Tentativo 2: Ordinamento (Sorting)

### Idea

Ordinare l'array in modo che i calzini dello stesso colore risultino adiacenti.

Esempio:

```text
[1, 1, 2, 2, 3]
```

Successivamente scorrere la lista confrontando gli elementi consecutivi e saltando di due posizioni ogni volta che viene trovata una coppia.

### Analisi

- **Complessità temporale:** `O(N log N)`
  - dovuta all'ordinamento (`sort()`).

### Risultato

✅ Funziona e supera tutti i test.

Tuttavia è possibile ottenere prestazioni migliori utilizzando una struttura dati più adatta.

---

# 🏆 Soluzione Definitiva: Frequenze con Hash Map (Dizionario)

L'approccio ottimale consiste nel dividere il problema in due fasi utilizzando un **dizionario (Hash Map)**.

## Fase 1 — Conteggio delle frequenze

Si esegue un solo ciclo sull'array.

Per ogni colore:

- se è già presente nel dizionario, incrementare il contatore;
- altrimenti inizializzarlo a `1`.

---

## Fase 2 — Calcolo delle coppie

Si scorrono i valori del dizionario.

Per ogni frequenza si calcola:

```python
frequenza // 2
```

La divisione intera elimina automaticamente l'eventuale calzino spaiato.

Esempio:

```text
5 calzini dello stesso colore

5 // 2 = 2 coppie
```

---

# 💻 Codice Finale

```python
def sockMerchant(n, ar):
    # Fase 1: Creazione della mappa delle frequenze
    pila = {}

    for i in ar:
        if i in pila:
            pila[i] += 1
        else:
            pila[i] = 1

    # Fase 2: Calcolo del numero totale di coppie
    total_pairs = 0

    for j in pila.values():
        total_pairs += j // 2

    return total_pairs
```

---

# 📊 Analisi delle Complessità (Big O)

## ⏱️ Time Complexity

\[
O(N)
\]

Si effettuano due passaggi:

1. un ciclo sull'array (`N`);
2. un ciclo sui colori distinti (`K`).

Poiché:

\[
K \le N
\]

la complessità complessiva rimane lineare.

---

## 💾 Space Complexity

\[
O(N)
\]

Nel caso peggiore tutti i calzini hanno colori diversi.

Il dizionario conterrà quindi `N` chiavi.

---

# 💡 Trick to Remember

Quando un problema richiede di:

- contare frequenze;
- trovare duplicati;
- creare coppie;
- verificare occorrenze;

❌ evita i cicli annidati.

Usa invece una **Hash Map (Dizionario)**.

In molti problemi di algoritmi, spendere un po' di memoria (`O(N)`) permette di ridurre drasticamente il tempo di esecuzione fino a **`O(N)`**.

---

