// Melike Besparmak
// 150220061
#include <iostream>
#include <vector>
#include <fstream>
#include <map>

#include <queue>
#include <unordered_set>

using namespace std;

struct Node {
    string MID;
    vector<Node*> adj;
    vector<string> relation;
};

void hello_neighbor(string); // part1
void centrals(); // part2
void shortest_path(string, string); // part 3

map<string, Node*> graph_map = {};
map<string, string> names = {};

int main(int argc, char** argv)
{
    string part = argv[1];
    
    ifstream infile("freebase.tsv");

    string line;
    while (getline(infile, line))
    {
        string ent1 = line.substr(0, line.find_first_of("\t\r"));
        string remain = line.substr(line.find_first_of("\t\r")+1,line.length()-ent1.length());
        string relationship = remain.substr(0, remain.find_first_of("\t\r"));
        remain = remain.substr(remain.find_first_of("\t\r")+1, remain.length()-relationship.length());
        string ent2 = remain.substr(0, remain.find_first_of("\t\r"));

        Node* ent1_node, *ent2_node;

        if (graph_map.find(ent1) == graph_map.end()) {
            ent1_node = new Node;
            ent1_node->MID = ent1;
            graph_map[ent1] = ent1_node;
        } else {
            ent1_node = graph_map[ent1];
        }

        if (graph_map.find(ent2) == graph_map.end()) {
            ent2_node = new Node;
            ent2_node->MID = ent2;
            graph_map[ent2] = ent2_node;
        } else {
            ent2_node = graph_map[ent2];
        }

        ent1_node->adj.push_back(ent2_node);
        ent1_node->relation.push_back(relationship);

        ent2_node->adj.push_back(ent1_node);
        ent2_node->relation.push_back(relationship);
    }    


    ifstream infile2("mid2name.tsv");

    while (getline(infile2, line))
    {
        string MID = line.substr(0, line.find_first_of("\t\r"));
        string remain = line.substr(line.find_first_of("\t\r")+1,line.length()-MID.length());
        string name = remain.substr(0, remain.find_first_of("\t\r"));

        if(names.find(MID) == names.end()) 
            names[MID] = name;
    } 

    if(part == "part1") {
        string mid = argv[2];
        hello_neighbor(mid);
    } else if(part == "part2") {
        centrals();
    } else if(part == "part3") {
        string mid1 = argv[2];
        string mid2 = argv[3];
        shortest_path(mid1, mid2);
    }
}

void hello_neighbor(string mid) {
    Node* node = graph_map.find(mid)->second; 
    int neighbor_num = node->adj.size();
    cout << neighbor_num << " neighbors\n";
    for(auto i = node->adj.begin(); i != node->adj.end(); ++i) {
        string mid = (*i)->MID;  
        string name = names[mid];
        cout << mid << " " << name << "\n";
    }
}

void centrals() {
    // count the neighbors of nodes
    // meanwhile create a map int->string = counter
    // extract the top 10

    map<int, string> counter;
    for(auto i = graph_map.begin(); i != graph_map.end(); ++i) {
        int neighbor_num = (*i).second->adj.size();
        counter[-neighbor_num] = (*i).first;
    }

    int ten = 0;
    for(auto i = counter.begin(); i != counter.end(); ++i) {
        cout << -(*i).first << " " << (*i).second << " " << names[(*i).second] << "\n";
        ten++;
        if(ten==10) {
            break;
        }
    }
}

void shortest_path(string mid1, string mid2) {
    Node* node1 = graph_map[mid1];
    Node* node2 = graph_map[mid2];

    map<Node*, pair<Node*, string>> parents; // Store the parent node and the relation
    unordered_set<Node*> visited; // Keep track of visited nodes
    queue<Node*> q; // Queue for bfs

    q.push(node1);
    visited.insert(node1);
    bool path_found = false;

    // BFS
    while (!q.empty()) {
        Node* curr_node = q.front();
        q.pop();

        if (curr_node->MID == mid2) {
            path_found = true;
            break;
        }

        for (size_t i = 0; i < curr_node->adj.size(); ++i) {
            Node* neighbor = curr_node->adj[i];
            if (visited.find(neighbor) == visited.end()) {
                q.push(neighbor);
                visited.insert(neighbor);
                parents[neighbor] = {curr_node, curr_node->relation[i]};
            }
        }
    }

    // Extract path
    if (path_found) {
        // Reconstruct the path from mid2 to mid1 using the parents map
        vector<string> path;
        Node* curr_node = node2;
    
        while (curr_node != node1) {
            auto parent_info = parents[curr_node];
            Node* parent = parent_info.first;
            string relation = parent_info.second;
            path.push_back(relation + "\n" + curr_node->MID + " "  + names[curr_node->MID] );
            curr_node = parent;
        }

        // Print the path in the correct order (from mid1 to mid2)
        // Use a reverse iterator so -> end to start which is correct order
        cout << "The shortest distance from " << names[mid1] << " to " << names[mid2] << " is " << path.size();
        cout << "\nThe path:\n";
        cout << mid1 << " "  << names[mid1];
        for (auto it = path.rbegin(); it != path.rend(); ++it) {
            cout << "\n" << *it;
        }
        cout << endl;
    } else {
        cout << "No path found from " << mid1 << " to " << mid2 << endl;
    }
}