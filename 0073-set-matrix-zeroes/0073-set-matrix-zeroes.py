class Solution:
    def setZeroes(self, matrix: List[List[int]]) -> None:
        R = len(matrix)
        C = len(matrix[0])
        # taking trace of the corrupted columns, rows.
        zero_rows={}  
        zero_cols={}
    # First loop: scanning the matrix to find the zero elements in the matrix
        for r in range(R):
            for c in range(C):
                if matrix[r][c] == 0:
            # if I find a zero value, I update the dictionaries of the "corrupted columns", corrupted rows 
                    zero_rows[r] = True
                    zero_cols[c] = True
    # Second loop: put the zeros in the corresponding row and column of the null element
        for r in range(R):
                for c in range(C):
                # Controlliamo se la riga o la colonna corrente sono nei registri
                    if r in zero_rows or c in zero_cols:
                        matrix[r][c] = 0
