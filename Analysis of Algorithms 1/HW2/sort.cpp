// Melike Besparmak
// 150220061 
#include "methods.h"
using namespace std;

std::vector<Item> countingSort(std::vector<Item>& items, const std::string& attribute, bool ascending)
{
    // assuming attribute can only be age

    int max_age = 0;
    for (const auto& i : items) {
        if (i.age > max_age) max_age = i.age;
    }

    vector<vector<Item>> v(max_age + 1);
    for (const auto& i : items) {
        v[i.age].push_back(i);
    }

    vector<Item> sorted;
    sorted.reserve(items.size()); // reserve the necessary space

    if (ascending) {
        for (const auto& b : v) {
            for (const auto& j : b) {
                sorted.push_back(j);
            }
        }
    } else {
        for (int i = v.size() - 1; i >= 0; --i) {
            for (const auto& j : v[i]) {
                sorted.push_back(j);
            }
        }
    }

    return sorted;
}

// Function to heapify a subtree rooted with node i in the array of items
void heapify(std::vector<Item>& items, int n, int i, bool descending)
{
    int max_index = i;
    int left_index = 2*i + 1;
    int right_index = 2*i + 2;

    if(!descending) {
        if(left_index < n && items[left_index].rarityScore > items[max_index].rarityScore) 
            max_index = left_index;
        if (right_index < n && items[right_index].rarityScore > items[max_index].rarityScore)
            max_index = right_index;
    } else {
        if(left_index < n && items[left_index].rarityScore < items[max_index].rarityScore)
            max_index = left_index;
        if (right_index < n && items[right_index].rarityScore < items[max_index].rarityScore) 
            max_index = right_index;
    }

    if(max_index != i) {
        Item temp = items[i];
        items[i] = items[max_index];
        items[max_index] = temp;

        heapify(items, n, max_index, descending);
    }
        

}

void build(std::vector<Item>& items, int n, bool descending) {
    for(int i=(n/2)-1; i>=0; i--)
        heapify(items, n, i, descending);
}

// Function to perform heap sort on rarityScore scores of items
std::vector<Item> heapSortByRarity(std::vector<Item>& items, bool descending)
{
    build(items, items.size(), descending);

    for(int i = items.size()-1; i>0; i--) {
        Item temp = items[i];
        items[i] = items[0];
        items[0] = temp;

        heapify(items, i, 0, descending);
    }

    return items;
}
