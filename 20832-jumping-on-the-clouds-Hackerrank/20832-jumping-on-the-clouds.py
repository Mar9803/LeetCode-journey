#!/bin/python3

import math
import os
import random
import re
import sys

#
# Complete the 'jumpingOnClouds' function below.
#
# The function is expected to return an INTEGER.
# The function accepts INTEGER_ARRAY c as parameter.
#

def jumpingOnClouds(c):
    n = len(c)
    jumps = 0
    i = 0  # 'i' e' l'INDICE (0, 1, 2...). Partiamo dalla prima nuvola.
    
    while i < n - 1:  # Continua finche' non sei arrivato all'ultima nuvola
        # Controlliamo PRIMA se possiamo fare il salto lungo da 2 passi.
        if i + 2 < n and c[i + 2] == 0:
            # Se la nuvola a distanza 2 esiste ed e' sicura (0)...
            i += 2        # Ti sposti avanti di due nuvole.
            jumps += 1    # Incrementi il contatore dei salti.
        else:
            # Se non puoi saltare di 2, fai un salto singolo da 1.
            i += 1
            jumps += 1
            
    return jumps

if __name__ == '__main__':
    fptr = open(os.environ['OUTPUT_PATH'], 'w')

    n = int(input().strip())

    c = list(map(int, input().rstrip().split()))

    result = jumpingOnClouds(c)

    fptr.write(str(result) + '\n')

    fptr.close()


# Synced seamlessly with LeetHub Pro
# Pro features: https://bit.ly/leethubpro | Free version: https://bit.ly/leethubv4
# Get it here: https://chromewebstore.google.com/detail/bcilpkkbokcopmabingnndookdogmbna