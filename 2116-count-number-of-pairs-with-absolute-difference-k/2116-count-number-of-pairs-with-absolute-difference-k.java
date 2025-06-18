class Solution {
    public int countKDifference(int[] nums, int k) {
		int npairs = 0;
		for (int i = 0; i < nums.length; i++) {
			for (int j = i+1; j < nums.length; j++) {
				if(absk(nums[i], nums[j], k)) {
					npairs+=1;
				}
			}
		}
    return npairs;
    }
	//metodo modulo
	public boolean absk(int a, int b, int c) {
		if(a-b == c || a-b == -c) {
			return true;
		}
		return false;
	}    
}