class Solution {
    public double findMedianSortedArrays(int[] nums1, int[] nums2) {
        
        int idx1 = 0, idx2 = 0;
        int maxLen = nums1.length + nums2.length; 
        int [] merged = new int[maxLen];


        for (int i = 0; i<maxLen; i++) {

            if (idx1 < nums1.length && idx2 < nums2.length) {
                
                if (nums1[idx1] <= nums2[idx2]) {
                    merged[i] = nums1[idx1++];
                } else {
                    merged[i] = nums2[idx2++];
                }

            } else if (idx1 < nums1.length) {
                
                merged[i] = nums1[idx1++];

            } else if (idx2 < nums2.length) {

                merged[i] = nums2[idx2++];
            }
        }

        maxLen--;

        if (merged.length % 2 != 0) {
            return merged[(maxLen + 1) / 2];
        }

        return ((double)(merged[maxLen / 2] + merged[(maxLen / 2) + 1])) / 2;

    }
    
}