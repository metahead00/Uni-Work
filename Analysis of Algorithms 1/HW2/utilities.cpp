// Melike Besparmak
// 150220061 
#include "item.h"
using namespace std;

std::vector<Item> readItemsFromFile(const std::string& filename) 
{
    // age type origin rarity
    // int int int double
    vector<Item> items;
    fstream file;
    file.open(filename, ios::in);

    string buffer, value;
    getline(file, buffer);

    while(getline(file, buffer)) {
        stringstream str(buffer);

        getline(str, value, ',');
        int age = stoi(value);

        getline(str, value, ',');
        int type = stoi(value);

        getline(str, value, ',');
        int origin = stoi(value);

        getline(str, value, ',');
        double rarity = stoi(value);

        Item new_item;
        new_item.age = age;
        new_item.type = type;
        new_item.origin = origin;
        new_item.rarityScore = rarity;

        items.push_back(new_item);
    }

    file.close();
    return items;
}

void writeItemsToFile(const std::string& filename, const std::vector<Item>& items) 
{
    fstream file;
    file.open(filename, ios::out);
    file << "age,type,origin,rarity\n";

    for(auto& i : items) {
        file << i.age << "," << i.type << "," << i.origin << "," << i.rarityScore << "\n"; 
    }

    file.close();
}
