// Melike Besparmak
// 150220061
#include "tweet.h"

int binarySearch(const std::vector<Tweet>& tweets, long long key, const std::string& sortBy)
{
    int left = 0;
    int right = tweets.size()-1;

    while (left <= right) {
        int mid = left + (right - left) / 2;   

        long long mid_val;
        if (sortBy == "tweetID") {
            mid_val = tweets[mid].tweetID;
        } else if (sortBy == "retweetCount") {
            mid_val = tweets[mid].retweetCount;
        } else {
            mid_val = tweets[mid].favoriteCount;
        } 

        if (mid_val == key) {
            return mid;
        } else if (mid_val > key) {
            right = mid - 1;
        } else {
            left = mid + 1;
        }
    }
    
    // not found
    return -1;
}

int countAboveThreshold(const std::vector<Tweet>& tweets, const std::string& metric, int threshold) 
{
    // linear search for unsorted
    int count=0;
    for(auto& t : tweets) {
        if(metric == "tweeID" && t.tweetID > threshold || metric == "favoriteCount" && t.favoriteCount > threshold || metric == "retweetCount" && t.retweetCount > threshold) 
            count++;
    }

    // binary search for sorted (find the smallest element largest from threshold)

    return count;
}
