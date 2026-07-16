Diario di Bordo: Risoluzione LeetCode 181

Problema: Employees Earning More Than Their Managers

Pattern Applicato: Self-Join (Prodotto Cartesiano & Restrizione Relazionale)

1. Analisi Iniziale e Scomposizione del Problema

Il problema richiede di identificare i dipendenti che percepiscono un salario superiore a quello del rispettivo manager.

La tabella di input Employee contiene quattro record di test. Ciascun record racchiude contemporaneamente due informazioni semantiche distinte:

L'entità Dipendente (identificata da id e caratterizzata da un proprio salary).

La relazione con l'entità Manager (espressa tramite la chiave esterna managerId).

Per poter confrontare il salario del dipendente con quello del suo manager, è necessario estrarre e accostare queste informazioni, che risiedono originariamente su righe diverse della stessa tabella.

2. Modello Mentale del Self-Join

Per visualizzare l'operazione, ho ipotizzato il comportamento del motore SQL istanziando due copie logiche della stessa tabella: alias A (Dipendenti) e alias B (Manager).

Senza vincoli, l'accostamento FROM Employee A, Employee B genera un prodotto cartesiano ($N \times M$). Nel caso di studio con 4 righe, il sistema valuta ogni riga di A contro tutte e 4 le righe di B sequenzialmente:

Riga 1 di $A$ confrontata con righe 1, 2, 3, 4 di $B$.

Riga 2 di $A$ confrontata con righe 1, 2, 3, 4 di $B$, e così via.

3. Definizione della Relazione Chiave (Join Condition)

Per restringere questo set di dati immenso alle sole coppie dotate di senso logico (ovvero accoppiare ciascun dipendente esclusivamente al suo effettivo manager), è stata applicata la condizione di uguaglianza:

$$\text{A.managerId} = \text{B.id}$$

Significato logico: Il record della tabella $B$ deve rappresentare il manager diretto dell'utente nel record della tabella $A$.

Effetto collaterale positivo: Questa clausola esclude implicitamente tutti i dipendenti che non hanno un manager associato (managerId IS NULL), poiché il confronto con NULL fallisce, riducendo immediatamente lo spazio di ricerca.

4. Applicazione della Business Logic

Una volta isolate le sole coppie "Dipendente-Manager", è stato introdotto il filtro finale per risolvere il quesito di business: identificare dove il salario del dipendente supera quello del superiore.

$$\text{A.salary} > \text{B.salary}$$

5. Implementazione SQL Finale

SELECT 
    A.name AS Employee
FROM 
    Employee A
INNER JOIN 
    Employee B ON A.managerId = B.id
WHERE 
    A.salary > B.salary;


Nota di Ottimizzazione (Refactoring Tecnico)

Nel codice finale, la sintassi del join implicito nel WHERE (stile SQL-89) è stata convertita in un INNER JOIN esplicito con clausola ON (stile SQL-92).
Questo approccio:

Migliora la leggibilità, separando chiaramente la logica di accoppiamento delle tabelle (ON) dalla logica di filtro dei dati (WHERE).

Previene errori accidentali di prodotti cartesiani non voluti durante la manutenzione del codice.