// Melike Besparmak
// 150220061 
#include "methods.h"
#include <chrono>
using namespace std;

int main() {
  
    //cout << " S\n";
    vector<Item> items = readItemsFromFile("data/items_s.csv");

    //auto start = chrono::high_resolution_clock::now();
    vector<Item> sorted = countingSort(items, "age", true);
    //auto end = chrono::high_resolution_clock::now();
    //auto duration = chrono::duration_cast<chrono::milliseconds>(end - start);
    //cout << "Counting sort execution time: " << duration.count() << " ms\n";

    writeItemsToFile("data/items_s_sorted.csv", sorted);

    //start = chrono::high_resolution_clock::now();
    calculateRarityScores(sorted, 50);
    //end = chrono::high_resolution_clock::now();
    //duration = chrono::duration_cast<chrono::milliseconds>(end - start);
    //cout << "Rarity calculation time: " << duration.count() << " ms\n";

    writeItemsToFile("data/items_s_rarity.csv", sorted);

    //start = chrono::high_resolution_clock::now();
    sorted = heapSortByRarity(sorted, true);
    //end = chrono::high_resolution_clock::now();
    //duration = chrono::duration_cast<chrono::milliseconds>(end - start);
    //cout << "Heap sort execution time: " << duration.count() << " ms\n";

    writeItemsToFile("data/items_s_rarity_sorted.csv", sorted);

    return 0;

}