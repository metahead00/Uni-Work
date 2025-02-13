// Melike Besparmak
// 150220061 
#include "methods.h"
using namespace std;

int getMax(std::vector<Item>& items, const std::string& attribute)
{
    int maxEl=0;
    for(auto& i : items) {
        if(attribute == "age")
            maxEl = max(maxEl, i.age);
        // add others if needed
    }
        

    return maxEl;
}

// min = age - ageWindow
// max = age + ageWindow
// rarityScore = (1 - probability) * (1 + item.age/ageMax)
void calculateRarityScores(std::vector<Item>& items, int ageWindow)
{
    int maxAge = getMax(items, "age");
    for(auto& i : items) {
        int countSimilar = 0; 
        int countTotal = 0;
        int lower = i.age - ageWindow;
        int upper = i.age + ageWindow;
        for(auto& j : items) {
            if(j.age >= lower && j.age <= upper) {
                countTotal++;
                if(j.origin==i.origin && j.type==i.type)
                    countSimilar++;
            }
        }

        if(countTotal == 0) {
            i.rarityScore = 0;
            continue;
        }

        double probability = double(countSimilar) / countTotal;
        double rarity = (1 - probability) * (1 + double(i.age) / maxAge);

        i.rarityScore = rarity;
        //cout << " rarity " << rarity << "\n";
    }
}
