// Melike Besparmak
// 150220061
#include "tweet.h"
#include <chrono>
using namespace std;

// function to read all files and return them as a vector
vector<vector<Tweet>> all_files() {
    vector<Tweet> per1 = readTweetsFromFile("/workspaces/Code/data/permutations/tweets.csv");
    vector<Tweet> per2 = readTweetsFromFile("/workspaces/Code/data/permutations/tweetsNS.csv");
    vector<Tweet> per3 = readTweetsFromFile("/workspaces/Code/data/permutations/tweetsSA.csv");
    vector<Tweet> per4 = readTweetsFromFile("/workspaces/Code/data/permutations/tweetsSD.csv");

    vector<Tweet> size1 = readTweetsFromFile("/workspaces/Code/data/sizes/tweets5K.csv");
    vector<Tweet> size2 = readTweetsFromFile("/workspaces/Code/data/sizes/tweets10K.csv");
    vector<Tweet> size3 = readTweetsFromFile("/workspaces/Code/data/sizes/tweets20K.csv");
    vector<Tweet> size4 = readTweetsFromFile("/workspaces/Code/data/sizes/tweets30K.csv");
    vector<Tweet> size5 = readTweetsFromFile("/workspaces/Code/data/sizes/tweets40K.csv");
    vector<Tweet> size6 = readTweetsFromFile("/workspaces/Code/data/sizes/tweets50K.csv");

    vector<vector<Tweet>> all = {per1, per2, per3, per4, size1, size2, size3, size4, size5, size6};

    return all;
}   

// function to sort all datasets
void sort_all() {
    vector<vector<Tweet>> to_sort = all_files();

    int i = 0;
    string path = "/workspaces/Code/data/sorted/file";
    for (auto& f : to_sort) {
        auto start = chrono::high_resolution_clock::now();
        
        // change according to the wanted sort algo
        //mergeSort(f, 0, f.size()-1, "retweetCount", 0);
        insertionSort(f, "retweetCount", 1);
        //bubbleSort(f, "retweetCount", 0);

        auto end = chrono::high_resolution_clock::now();
        auto duration = chrono::duration_cast<chrono::milliseconds>(end - start);
        cout << "Execution time: " << duration.count() << " ms\n";

        // create new files to check if its correct or not
        writeTweetsToFile(path + to_string(i) + ".csv", f);
        i++;
    }
}

// Perform Binary Search for tweetID 1773335
void binary_search() {
    vector<vector<Tweet>> all = all_files();

    for(auto& set : all) {
        // ascending
        mergeSort(set, 0, set.size()-1, "tweetID", 1);

        auto start = chrono::high_resolution_clock::now();
        int index = binarySearch(set, 1773335, "tweetID");
        auto end = chrono::high_resolution_clock::now();
        auto duration = chrono::duration_cast<chrono::nanoseconds>(end - start);
        cout << "Execution time: " << duration.count() << " ns\n";
        cout << index << "\n";
    } 
}

void threshold() {
    vector<vector<Tweet>> all = all_files();

    for(auto& set : all) {
        auto start = chrono::high_resolution_clock::now();
        int count = countAboveThreshold(set, "favoriteCount", 250);
        auto end = chrono::high_resolution_clock::now();
        auto duration = chrono::duration_cast<chrono::nanoseconds>(end - start);
        cout << "Execution time: " << duration.count() << " ns\n";
        cout << count << "\n";
    } 

}

int main() 
{
    //threshold();
    //binary_search();
    //sort_all();
}
