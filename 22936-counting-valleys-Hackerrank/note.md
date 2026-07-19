# 📘 REPORT DI STUDIO: Soluzione "Counting Valleys"

## 🎯 Obiettivo del Problema

Data una sequenza di passi verso l'alto (`'U'`) e verso il basso (`'D'`), partendo dal livello del mare (altitudine `0`), determinare il numero esatto di **valli** attraversate.

Una valle:

- **inizia** quando si scende sotto il livello del mare;
- **termina** quando si risale esattamente al livello del mare.

---

# 🛑 Strategia 1: L'approccio a coppie di passi (`D -> U`) – Incompleto

## 💡 L'idea iniziale

Cercare all'interno della stringa la combinazione di un passo verso il basso seguito immediatamente da uno verso l'alto.

```python
steps[i] == 'D' and steps[i+1] == 'U'
```

## ❌ Perché ha fallito (Logica)

Questo approccio non teneva conto dell'altitudine.

Una transizione:

```
D -> U
```

può verificarsi anche **sopra il livello del mare**, e quindi **non rappresenta una valle**.

Inoltre non riconosceva valli più profonde, ad esempio:

```
D -> D -> U -> U
```

## ❌ Perché ha fallito (Sintassi)

L'accesso a:

```python
steps[i+1]
```

rischiava di generare un:

```text
IndexError
```

quando `i` si trovava all'ultimo carattere della stringa.

---

# 📈 Strategia 2: Il tentativo con la Hash Map – Sovradimensionato

## 💡 L'idea

Utilizzare un dizionario per salvare lo stato del percorso.

```python
valli = {}
```

Ad ogni passo si sarebbe memorizzata l'altitudine raggiunta, per poi analizzare tutta la cronologia.

## ❌ Perché è stato scartato

L'intuizione di tracciare l'altitudine era corretta.

Il problema era lo strumento scelto.

Non serviva ricordare **tutti** i passi già fatti.

Serviva conoscere solamente:

- l'altitudine corrente.

Una Hash Map avrebbe occupato memoria inutilmente.

### Complessità

- Tempo: `O(N)`
- Spazio: `O(N)`

---

# 🏆 Strategia 3 (Vincente): Tracciamento lineare dell'altitudine

## 💡 La svolta logica

Basta una sola variabile intera:

```python
livello_mare = 0
```

che funziona come una barra della vita:

- `'U'` → +1
- `'D'` → -1

Non serve memorizzare tutto il percorso.

Serve conoscere soltanto lo stato attuale.

---

## 🎯 Il trucco matematico

Una valle termina **esattamente** quando:

1. il passo corrente è `'U'`;
2. l'altitudine torna a `0`.

Se entrambe le condizioni sono vere nello stesso istante, significa che un momento prima ci trovavamo a `-1`.

Quindi abbiamo appena chiuso una valle.

Non serve guardare:

- né il passato;
- né il futuro.

---

# 💻 Codice Definitivo

```python
def countingValleys(steps, path):
    livello_mare = 0
    valle_count = 0

    # Iteriamo direttamente sui caratteri della stringa
    for i in path:
        if i == 'U':
            livello_mare += 1

            # Se torno al livello del mare, ho chiuso una valle
            if livello_mare == 0:
                valle_count += 1

        elif i == 'D':
            livello_mare -= 1

    return valle_count
```

---

# 📊 Analisi delle Complessità (Big O)

## ⏱️ Time Complexity

\[
O(N)
\]

Il codice percorre la stringa una sola volta.

Ogni passo richiede un numero costante di operazioni.

Per questo motivo l'algoritmo supera facilmente anche i test di performance di HackerRank.

---

## 💾 Space Complexity

\[
O(1)
\]

Lo spazio è costante.

Il programma utilizza solamente due variabili:

- `livello_mare`
- `valle_count`

La memoria utilizzata rimane la stessa anche se il percorso contiene milioni di passi.

---

# 💡 Trick to Remember

## ✅ Iterare una stringa in Python

```python
for i in stringa:
```

estrae direttamente i caratteri:

```
'U'
'D'
```

e **non** gli indici.

È il modo più semplice, leggibile e sicuro per evitare errori come `IndexError`.

---

## ✅ Il concetto di "Stato"

Quando un problema descrive qualcosa che evolve nel tempo (altezza, punteggio, posizione, energia...), chiediti sempre:

> "Mi serve davvero ricordare tutto il passato?"

Molto spesso basta una sola variabile che rappresenta lo **stato corrente**.

Prima di usare strutture dati come:

- liste
- dizionari
- hash map

prova a risolvere il problema con un semplice contatore.

Questo porta spesso a soluzioni con:

- **Tempo:** `O(N)`
- **Spazio:** `O(1)`

che sono generalmente le più eleganti ed efficienti.