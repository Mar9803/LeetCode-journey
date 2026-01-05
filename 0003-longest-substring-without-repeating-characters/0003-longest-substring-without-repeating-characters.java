class Solution {

    record myData(String s, Integer len) {}

    public int lengthOfLongestSubstring(String s) {

        Map<Character, Integer> last = new HashMap<>();
        int max = 0;
        int start = 0;

        for (int i = 0; i < s.length(); i++) {
            
            char c = s.charAt(i);

            if (last.containsKey(c) && last.get(c) >= start) {
                start = last.get(c) + 1;
            }

            last.put(c, i);
            max = Math.max(max, i - start + 1);
        }

        return max;

    }
}