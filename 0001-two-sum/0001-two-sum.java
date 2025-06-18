class Solution {
    public int[] twoSum(int[] nums, int target) {
       HashMap<Integer, Integer> complements = new HashMap<>();
       //ciclo sull'array
       // verifico se il valore corrente nell'array essite già come chiave nella mappa: 
       for (int i = 0; i <= nums.length; i++) {
    	   // Verifico se l'elemento attuale dell'array (num[i])c'è nella mappa:
    	   // se c'è, significa che "i" and l'indice di num[i], preso nella mappa
    	   // sono quelli da sommare per ottenere target.
    	   Integer complementIndex = complements.get(nums[i]); 
    	   if (complementIndex != null) {
    		   return new int[] {i, complementIndex};
    	   }
    	   complements.put(target - nums[i],  i); //Popolo mappa ocn complementari di target 
    	   
       }
       return nums;

    }

}