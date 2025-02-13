// Melike Besparmak
// 150220061
#include "tweet.h"
using namespace std;

void swap(std::vector<Tweet>& tweets, int i, int j) {
    Tweet temp = tweets[i];
    tweets[i] = tweets[j];
    tweets[j] = temp;
}

void bubbleSort(std::vector<Tweet>& tweets, const std::string& sortBy, bool ascending) 
{

    auto compare = [&sortBy, ascending](const Tweet& a, const Tweet& b) {
        if (sortBy == "tweetID") 
            return ascending ? a.tweetID > b.tweetID : a.tweetID < b.tweetID;
        if (sortBy == "retweetCount") 
            return ascending ? a.retweetCount > b.retweetCount : a.retweetCount < b.retweetCount;
        if (sortBy == "favoriteCount") 
            return ascending ? a.favoriteCount > b.favoriteCount : a.favoriteCount < b.favoriteCount;
        return false;
    };

    for (int j = 0; j < tweets.size(); j++) {
        for (size_t i = 0; i < tweets.size() - 1; i++) {
            if (compare(tweets[i], tweets[i + 1])) {
                swap(tweets, i, i+1);
            }
        }
    }
    
}

void insertionSort(std::vector<Tweet>& tweets, const std::string& sortBy, bool ascending) 
{
    // if the elements are equal the comparison function will return false and the elements wont be swapped
    // this keeps the array stable
    auto compare = [&sortBy, ascending](const Tweet& a, const Tweet& b) {
        if (sortBy == "tweetID") 
            return ascending ? a.tweetID > b.tweetID : a.tweetID < b.tweetID;
        if (sortBy == "retweetCount") 
            return ascending ? a.retweetCount > b.retweetCount : a.retweetCount < b.retweetCount;
        if (sortBy == "favoriteCount") 
            return ascending ? a.favoriteCount > b.favoriteCount : a.favoriteCount < b.favoriteCount;
        return false;
    };

    for (int i = 1; i < tweets.size(); i++) {
        Tweet temp = tweets[i];
        int j = i - 1;
        
        while (j >= 0 && compare(tweets[j], temp)) {
            tweets[j + 1] = tweets[j];
            j--; 
        }
        tweets[j + 1] = temp;
    }
}

void merge(std::vector<Tweet>& tweets, int left, int mid, int right, const std::string& sortBy, bool ascending) 
{
    // to keep the sorting process stable, comaparison must return true if the values are equal
    // by this way, the element from the left array will be included first
    auto compare = [&sortBy, ascending](const Tweet& a, const Tweet& b) {
        if (sortBy == "tweetID") 
            return ascending ? a.tweetID <= b.tweetID : a.tweetID >= b.tweetID;
        if (sortBy == "retweetCount") 
            return ascending ? a.retweetCount <= b.retweetCount : a.retweetCount >= b.retweetCount;
        if (sortBy == "favoriteCount") 
            return ascending ? a.favoriteCount <= b.favoriteCount : a.favoriteCount >= b.favoriteCount;
        return false;
    };

    // split the array in half, the indices make sure every there arent any elements left over
    std::vector<Tweet> left_array(tweets.begin() + left, tweets.begin() + mid + 1); 
    std::vector<Tweet> right_array(tweets.begin() + mid + 1, tweets.begin() + right + 1); 

    int i = left, l = 0, r = 0;
    while (l < left_array.size() && r < right_array.size()) {
        if (compare(left_array[l], right_array[r])) {
            tweets[i] = left_array[l];
            l++;
        } else {
            tweets[i] = right_array[r];
            r++;
        }
        i++;
    }

    
    // if there are any elements left in the arrays
    while (l < left_array.size()) {
        tweets[i] = left_array[l];
        i++; l++;
    }

    while (r < right_array.size()) {
        tweets[i] = right_array[r];
        i++; r++;
    }
}

void mergeSort(std::vector<Tweet>& tweets, int left, int right, const std::string& sortBy, bool ascending) 
{
    if (left >= right) return;
    
    int mid = left + (right - left) / 2;
    
    mergeSort(tweets, left, mid, sortBy, ascending);
    mergeSort(tweets, mid + 1, right, sortBy, ascending);
    merge(tweets, left, mid, right, sortBy, ascending);
}


