class Solution:
    def twoSum(self, nums: list[int], target: int) -> list[int]:
        # our index of the db, Struttura: { valore_del_numero: suo_indice }
        db_index = {}
        
        # Facciamo una singola scansione della tabella (Single Table Scan)
        for i, num in enumerate(nums):
            # Calcoliamo la riga "complementare" che farebbe scattare la JOIN
            complemento = target - num
            
            # Facciamo una query istantanea O(1) nel nostro indice
            if complemento in db_index:
                # Trovato! Facciamo la "JOIN" restituendo l'indice del vecchio 
                # numero (preso dall'indice) e l'indice di quello corrente (i)
                return [db_index[complemento], i]
            
            # Se non c'è, registriamo il numero corrente nell'indice
            # così i numeri successivi potranno "fare la query" su di lui
            db_index[num] = i
            
        return [] 