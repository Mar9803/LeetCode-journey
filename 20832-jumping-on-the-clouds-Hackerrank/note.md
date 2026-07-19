# 📝 REPORT DI STUDIO: Soluzione "Jumping on the Clouds"

## 🎯 Obiettivo del Problema

Un giocatore deve raggiungere l'ultima nuvola di un array partendo dalla prima (indice `0`).

Può effettuare salti di:

- **1 posizione**
- **2 posizioni**

Alcune nuvole contengono fulmini (`1`) e devono essere tassativamente evitate, mentre le altre sono sicure (`0`).

Il problema garantisce che esiste sempre almeno un percorso valido.

L'obiettivo è trovare **il minor numero di salti** necessario per arrivare all'ultima nuvola.

---

# 🛑 Tentativo 1: Approccio con ciclo `for` – Sbagliato

## 💡 L'idea iniziale

Scorrere l'array utilizzando:

```python
for i in c:
```

e controllare il valore corrente (`0` oppure `1`), cercando poi di prevedere i passi successivi con confronti del tipo:

```python
i == i + 1
i == i + 2
```

---

## ❌ Perché ha fallito (Sintassi e Logica)

In Python:

```python
for i in c:
```

non restituisce gli **indici**, ma i **valori** contenuti nella lista.

Quindi `i` valeva:

```text
0
1
0
0
1
...
```

e non:

```text
0
1
2
3
4
...
```

Di conseguenza operazioni come:

```python
i + 1
```

non significavano "spostarsi alla nuvola successiva", ma semplicemente sommare `1` al valore della nuvola.

---

### Un secondo problema

Il ciclo `for` è rigido.

Avanza automaticamente di una posizione ad ogni iterazione.

Ma in questo esercizio il giocatore può:

- saltare di 1;
- saltare di 2.

Quando si effettua un salto da 2, la nuvola intermedia viene completamente ignorata e non deve essere analizzata.

Con un `for` questo comportamento è difficile da gestire.

---

# 📈 Tentativo 2: Ciclo `while` con indice manuale – Migliorabile

## 💡 L'idea

Sostituire il `for` con:

```python
while i < n - 1:
```

In questo modo `i` rappresenta davvero la posizione del giocatore.

È possibile decidere manualmente se avanzare di:

```python
i += 1
```

oppure

```python
i += 2
```

---

## ⚠️ L'inghippo rimasto

Nel ramo `else` erano ancora presenti controlli ridondanti come:

```python
if c[i] == 0 or i + 1 > n:
```

---

## ✅ Perché sono stati eliminati

Il ciclo:

```python
while i < n - 1
```

garantisce già di non uscire dai limiti dell'array.

Inoltre il testo del problema assicura che **esiste sempre un percorso valido**.

Quindi la logica diventa semplicissima:

- se posso saltare di 2 → salto di 2;
- altrimenti → salto di 1.

Non servono ulteriori verifiche.

---

# 🏆 Soluzione Definitiva: Strategia Greedy con ciclo `while`

La soluzione utilizza un algoritmo **Greedy (Avido)**.

L'idea è molto semplice:

> Ad ogni turno provo sempre a fare il salto più lungo possibile.

Perché?

Ogni salto da 2 evita un salto da 1.

Meno salti eseguo, migliore sarà il risultato finale.

---

# 💻 Codice Finale

```python
def jumpingOnClouds(c):
    n = len(c)
    jumps = 0
    i = 0  # Indice della posizione attuale

    while i < n - 1:

        # Proviamo prima il salto da 2
        if i + 2 < n and c[i + 2] == 0:
            i += 2
            jumps += 1

        # Altrimenti facciamo il salto da 1
        else:
            i += 1
            jumps += 1

    return jumps
```

---

# 📊 Analisi delle Complessità (Big O)

## ⏱️ Time Complexity

\[
O(N)
\]

L'algoritmo attraversa l'array una sola volta.

Nel caso peggiore effettua soltanto salti da `1`, visitando tutti gli elementi.

Nel caso migliore effettua sempre salti da `2`, visitandone circa la metà.

In entrambi i casi la complessità rimane lineare.

---

## 💾 Space Complexity

\[
O(1)
\]

Lo spazio utilizzato è costante.

Il programma impiega soltanto tre variabili:

- `n`
- `jumps`
- `i`

Non vengono create liste, dizionari o altre strutture dati ausiliarie.

---

# 💡 Trick to Remember

## ✅ Scegliere il ciclo giusto

Se la tua posizione deve avanzare in modo variabile:

- a volte di `+1`;
- a volte di `+2`;

il ciclo:

```python
for
```

non è lo strumento ideale.

In questi casi è preferibile utilizzare:

```python
while
```

gestendo manualmente l'indice.

---

## ✅ Riconoscere un algoritmo Greedy

Quando un problema chiede di ottenere:

- il numero minimo;
- il numero massimo;
- il percorso migliore;

chiediti sempre:

> "Posso prendere la decisione migliore in questo momento senza compromettere il futuro?"

Se la risposta è sì, probabilmente un algoritmo **Greedy** è la soluzione giusta.

In questo esercizio la scelta locale ottimale è sempre:

> **Saltare di 2 quando possibile.**

Questa strategia porta automaticamente anche alla soluzione globale ottimale.

---

# 🎓 Concetto chiave da ricordare

Molti problemi di HackerRank si risolvono con una semplice domanda:

> **"Qual è la scelta migliore che posso fare adesso?"**

Se quella scelta non peggiora le possibilità future, spesso hai davanti un classico problema **Greedy**.

È una delle tecniche più importanti da riconoscere durante i colloqui tecnici.