# Cheatsheet HackerRank & Leet code--> coding, strutture

## 🔹 Algo 01 — HackerRank: Jumping on the Clouds -> [Full Report](../20832-jumping-on-the-clouds-Hackerrank/note.md)

---

### 🛠️ Cosa ho usato

- ```python
  while i < n - 1:
  ```
  - Ciclo con puntatore manuale per gestire un avanzamento a passo variabile (`+1` o `+2`). "for i in c" Avanzamento rigido: fa sempre +1.

- ```python
  if i + 2 < n and c[i + 2] == 0:
  ```
  - Controllo preventivo dei limiti dell'array (*bound checking*) insieme alla verifica che la nuvola di destinazione sia sicura.

- **Approccio Greedy (Avido)**
  - Scelta locale ottimale: effettuare sempre il salto più lungo possibile (`+2`) quando consentito, così da minimizzare il numero totale di salti.

---

### ⚠️ Errore vs Soluzione (Cicli rigidi vs puntatori variabili)

### ❌ Errore

```python
for i in c:
    # Tentativo di saltare o fare controlli con i + 1 o i + 2
```

**Bug:** in Python, `for i in lista` itera sui **valori** della lista e non sui loro indici. Inoltre, un ciclo `for` avanza automaticamente di una sola posizione per iterazione, rendendo impossibile modificare dinamicamente il passo per effettuare salti di due posizioni.

---

### ✅ Soluzione corretta

Utilizzare un ciclo `while` gestendo manualmente l'indice corrente.

```python
i = 0

while i < n - 1:
    if condizione_salto_lungo:
        i += 2      # Salto doppio
    else:
        i += 1      # Salto singolo
```

---

### 💡 Regola d'oro per gli algoritmi Greedy

Quando un problema chiede di trovare un **minimo** o un **massimo**, chiediti se puoi prendere la decisione migliore **nel momento presente** senza compromettere le scelte future.
Se la scelta locale ottimale (ad esempio, effettuare sempre il salto più lungo possibile quando è sicuro) non peggiora la soluzione finale, il problema segue un **pattern Greedy**.
In questi casi è spesso possibile ottenere una soluzione in:
- **Tempo:** `O(N)`
- **Spazio:** `O(1)`
senza ricorrere ad algoritmi più complessi come la programmazione dinamica.

---

## 🔹 Algo 02 — HackerRank: Counting Valleys -> [Full Report](../22936-counting-valleys-Hackerrank/note.md)

---

## 🛠️ Cosa ho usato

- ```python
  for passo in path:
  ```
  - Iterazione diretta sui caratteri della stringa (`'U'` / `'D'`) senza gestire manualmente gli indici.

- **Tracciamento di stato lineare**
  - Utilizzo di una singola variabile intera (`livello_mare`) come accumulatore dinamico, evitando strutture dati aggiuntive.

- **Intercettazione del trigger di chiusura**
  - Una valle è completata **solo** quando:
    - il passo corrente è `'U'`;
    - l'altitudine ritorna esattamente a `0`.

---

## ⚠️ Errore vs Soluzione (Analisi a coppie vs Tracciamento di stato)

### ❌ Perché l'analisi a coppie (`D → U`) o una Hash Map **non funzionano**

```python
if steps[i] == 'D' and steps[i + 1] == 'U':  # 🔴 BUG
```

#### Problemi

- **Ignora il contesto dell'altitudine**
  - Una sequenza `D → U` può verificarsi anche sopra il livello del mare, senza rappresentare la chiusura di una valle.

- **Rischio di errore**
  - Accedere a `steps[i + 1]` sull'ultimo elemento genera un `IndexError`.

- **Spreco di memoria**
  - Memorizzare tutta la cronologia dei passi con una lista o una `Hash Map` porta inutilmente la complessità spaziale a `O(N)`.

---

### ✅ Perché il Tracciamento di stato funziona

```python
if passo == 'U':
    livello_mare += 1
```
L'algoritmo osserva **solo lo stato corrente**.
Sono sufficienti due variabili:
- `livello_mare`
- `valle_count`
con una complessità spaziale di **`O(1)`**.
Non importa **come** si è arrivati a quel punto: conta esclusivamente l'altitudine attuale.

### Schema visivo

```text
Livello  0:  _           _   ← Valle chiusa quando il passo è 'U'
             \         /
Livello -1:   \       /
               \_____/
Livello -2:
```

## 💡 Regola d'oro per i problemi con evoluzione dello stato

Quando un problema descrive una quantità che:
- sale o scende;
- accumula valore;
- rappresenta uno stato corrente (altitudine, saldo, punteggio, temperatura, ecc.),

non creare subito liste o dizionari per memorizzare tutta la cronologia.
Chiediti invece:

> **"Mi serve davvero ricordare il passato oppure mi basta conoscere lo stato attuale?"**

Se è sufficiente conoscere il presente, utilizza un **singolo contatore numerico**.

Questo permette spesso di ridurre la complessità spaziale da:

- **`O(N)`** → **`O(1)`**

ottenendo una soluzione più semplice, efficiente e tipica dei problemi di simulazione o tracciamento di stato.

---

## 🔹 Algo 03 — HackerRank: Sales by Match (Sock Merchant) -> [Full Report](../25168-sales-by-match-Hackerrank/note.md)

---

## 🛠️ Cosa ho usato

- ```python
  pila = {}
  ```
  - **Hash Map (Dizionario)** per memorizzare la frequenza di ogni colore, con operazioni di inserimento e ricerca in tempo medio **`O(1)`**.

- ```python
  conteggio // 2 #per ottenere n coppie complete
  ```

- ```python
  pila.values()
  ```
  - Iterazione sui soli (**values**)conteggi accumulati, senza considerare le chiavi (**i colori**), per calcolare il numero totale di coppie.

---

## ⚠️ Errore vs Soluzione (Doppio ciclo vs Hash Map)

### ❌ Perché il doppio ciclo (`O(N²)`) o l'ordinamento (`O(N log N)`) non sono ottimali

```python
for i in range(n):
    for j in range(i + 1, n):
        # 🔴 BUG / INEFFICIENZA
```

#### Problemi

- **Time Limit Exceeded**
  - Cercare il "gemello" di ogni calzino scandendo il resto dell'array porta a una complessità temporale di **`O(N²)`**.

- **Bug di mutabilità**
  - Eliminare elementi dalla lista mentre la si attraversa altera gli indici e può produrre risultati errati.

- **Sorting costoso**
  - Ordinare l'array semplifica la logica di accoppiamento, ma mantiene comunque una complessità di **`O(N log N)`**, peggiore della soluzione ottimale.

---

### ✅ Perché la Hash Map funziona

```python
for calzino in ar:
    pila[calzino] = pila.get(calzino, 0) + 1
```

#### Vantaggi

- **Scambio memoria-tempo**
  - Utilizzando una Hash Map (`O(N)` spazio nel caso peggiore), l'algoritmo diventa lineare in tempo.

- **Logica in due fasi**
  1. Conteggio delle frequenze.
  2. Calcolo matematico delle coppie.

- L'array originale non viene modificato.

---

### Schema visivo

```text
[1, 2, 1, 2, 1]
        │
        ▼
{
    1 → 3,
    2 → 2
}
        │
        ▼
(3 // 2) + (2 // 2) = 2 coppie
```
---

## 💡 Regola d'oro per i problemi di conteggio e accoppiamento

Quando un problema parla di:

- frequenze;
- duplicati;
- occorrenze;
- raggruppamenti;
- accoppiamenti di elementi;

la prima struttura dati da considerare è quasi sempre una **Hash Map** (o, quando basta sapere se un elemento esiste, un **Set**).

Accettare una complessità spaziale di **`O(N)`** è spesso il miglior compromesso per ridurre la complessità temporale da:

- **`O(N²)`** → **`O(N)`**

ottenendo una soluzione semplice, scalabile e tipica delle interviste tecniche.