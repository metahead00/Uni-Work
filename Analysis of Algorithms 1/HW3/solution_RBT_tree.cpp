// Melike Besparmak
// 150220061

#include <iostream> 
#include <stdlib.h>
#include <iomanip>
#include <string.h>
#include <string>
#include <fstream>
#include <vector>
#include <algorithm>
#include <stack>
#include <iomanip>
#include <chrono>
#include <random>

using namespace std;
using namespace std::chrono;

/////////////////// Player ///////////////////
class publisher
{
public:
	string name;
	float na_sales=0;
	float eu_sales=0;
	float others_sales=0;
};

/////////////////// Node ///////////////////
class Node{
	public:
		publisher key;
		int color; // "Red"=1 or "Black"=0
		Node *parent, *left, *right;
	
		Node(publisher);
		~Node();
		int get_color();
        void set_color(int);
};

/////////////////// RB-Tree ///////////////////
class RB_tree{
	private:
		Node* root;
	public:	
        publisher* best_seller[3];	
		stack<string> tree_deep_stack;

        Node* get_root();

		Node* RB_insert(Node* root, Node* ptr);
        void insertValue(vector<string>);
		void RB_left_rotate(Node*);
		void RB_right_rotate(Node*);
		void RB_insert_fixup(Node*);
        void preorder();
        void find_best_seller(); 

        RB_tree();
		~RB_tree();
};

void print_best_sellers(int year, publisher* temp_publisher[3]){
    cout.precision(5);
    cout<< "End of the "+to_string(year)+" Year"<<endl;
    cout<< "Best seller in North America: "+temp_publisher[0]->name+" - "<<temp_publisher[0]->na_sales<<" million"<<endl;
    cout<< "Best seller in Europe: "+temp_publisher[1]->name+" - "<<temp_publisher[1]->eu_sales<<" million"<<endl;
    cout<< "Best seller rest of the World: "+temp_publisher[2]->name+" - "<<temp_publisher[2]->others_sales<<" million"<<endl;
}

vector<string> all_publishers; 
vector<vector<string>> all_lines;

RB_tree generate_RBT_tree_from_csv(string file_name){
	RB_tree temp_RBtree;
    
	fstream file;
	file.open(file_name, ios::in);			
	vector<string> line(7); 		// 7 attributes 
	int previous_decade = 198;		// start with 1980
	string buffer, attr;      		// buffer strings for getline function
	getline(file, buffer);          // discard first line
	while(getline(file, buffer)) {
		stringstream str(buffer);

		for(int i=0; i<7; i++) {
			getline(str, attr, ',');
			line[i] = attr;
		}

        all_publishers.push_back(line[3]);

		// line[2] = year of release
		int year = stoi(line[2]);
		int current_decade = year / 10;
		if (current_decade != previous_decade) {	// print once at the end of a decade
			temp_RBtree.find_best_seller();
			print_best_sellers(year, temp_RBtree.best_seller);
			previous_decade = current_decade;
		}

        all_lines.push_back(line);
		temp_RBtree.insertValue(line);
	}


	file.close();
    return temp_RBtree;
}

void search(Node* root, string name) {
	Node* curr = root;
    while (curr != nullptr) {
        if (curr->key.name == name) {
			// key found			
			return;
        }

        if (name < curr->key.name)
            curr = curr->left;
        else
            curr = curr->right;
    }
    return;
}

void random_search(int count, Node* root) {
	int size = all_publishers.size();

	for(int i=0; i<count; i++) {
		int index = rand() % size;
		search(root, all_publishers[index]);
	}
}

void sort_file(RB_tree* tree) {
	sort(all_lines.begin(), all_lines.end());
	for(auto l : all_lines) {
		tree->insertValue(l);
	}
}

////////////////////////////////////////////
//----------------- MAIN -----------------//
////////////////////////////////////////////
int main(int argc, char* argv[]) {
    string fname = "VideoGames.csv";
    if (argc > 1) {
        fname = argv[1];
    }

    // TASK A and C - Create BST from CSV
    auto start = high_resolution_clock::now();
    RB_tree RBtree = generate_RBT_tree_from_csv(fname);
    auto end = high_resolution_clock::now();
    auto duration = duration_cast<microseconds>(end - start);
    cout << "Execution time to create RBT from CSV: " << duration.count() << " microseconds\n";

    // TASK B - Search 50 Random Publishers
    srand(time(0));
    start = high_resolution_clock::now();
    random_search(50, RBtree.get_root());
    end = high_resolution_clock::now();
    auto duration1 = duration_cast<nanoseconds>(end - start);
    cout << "Average execution time to search 50 random publishers: " 
         << float(duration1.count()) / 50.0 << " ns\n";

    // TASK D - Check Balance of Tree
    RBtree.preorder();

    // TASK E - Custom Recommendation 

    // TASK F - Sort File
    RB_tree new_tree;
    start = high_resolution_clock::now();
    sort_file(&new_tree);
    end = high_resolution_clock::now();
    auto duration2 = duration_cast<microseconds>(end - start);
    cout << "Execution time to create new tree with ordered data: " 
         << duration2.count() << " microseconds\n";

    start = high_resolution_clock::now();
    random_search(50, new_tree.get_root());
    end = high_resolution_clock::now();
    auto duration3 = duration_cast<nanoseconds>(end - start);
    cout << "Average execution time to search 50 random publishers with ordered data: " 
         << float(duration3.count()) / 50.0 << " ns\n";

    return EXIT_SUCCESS;
}


/////////////////// Node ///////////////////

Node::Node(publisher key){
	this->key = key;
    this->color = 1; // "RED";
	this->parent = NULL;
	this->left = NULL;
	this->right = NULL;
}

/////////////////// RB-Tree ///////////////////
Node* RB_tree::get_root(){
    return this->root;
}

Node* RB_tree::RB_insert(Node* root, Node* ptr){
	// first node
	if (root == NULL) {
		this->root = ptr;
		return this->root;
	}

    Node* curr = root;
    Node* parent = nullptr;  

    while (curr != nullptr) {
        parent = curr; 

        if (curr->key.name == ptr->key.name) {
            // handle sales if the publisher already exists
            curr->key.eu_sales += ptr->key.eu_sales;
            curr->key.na_sales += ptr->key.na_sales;
            curr->key.others_sales += ptr->key.others_sales;
            return root;
        }

        if (ptr->key.name < curr->key.name)
            curr = curr->left;
        else
            curr = curr->right;
    }

    ptr->parent = parent;
    if (ptr->key.name < parent->key.name)
        parent->left = ptr;
    else
        parent->right = ptr;

    // insert as red
    ptr->color = 1;
    return root;
}

void RB_tree::insertValue(vector<string> n) {
    // 0-name, 1-platform, 2-release, 3-publisher, 4-na, 5-eu, 6-other
	publisher pub;
	pub.name = n[3];
	pub.na_sales = stof(n[4]);
	pub.eu_sales = stof(n[5]);
	pub.others_sales = stof(n[6]);
    Node* new_node = new Node(pub);

    RB_insert(root, new_node);
	RB_insert_fixup(new_node); 
}

void RB_tree::RB_left_rotate(Node* ptr) {
    Node* child = ptr->right;
    ptr->right = child->left;

    if (child->left != nullptr) {
        child->left->parent = ptr;
    }

    child->parent = ptr->parent;

    if (ptr->parent == nullptr) {
        root = child;
    } else if (ptr == ptr->parent->left) {
        ptr->parent->left = child;
    } else {
        ptr->parent->right = child;
    }

    child->left = ptr;
    ptr->parent = child;
}

void RB_tree::RB_right_rotate(Node* ptr) {
    Node* child = ptr->left;
    ptr->left = child->right;

    if (child->right != nullptr) {
        child->right->parent = ptr;
    }

    child->parent = ptr->parent;

    if (ptr->parent == nullptr) {
        root = child;
    } else if (ptr == ptr->parent->right) {
        ptr->parent->right = child;
    } else {
        ptr->parent->left = child;
    }

    child->right = ptr;
    ptr->parent = child;
}

void RB_tree::RB_insert_fixup(Node *node) {
    // no problem if the parent is black
    while (node->parent != nullptr && node->parent->color == 1) {
        Node* uncle;
        Node* grand = node->parent->parent;

        if (node->parent == grand->left) {
            uncle = grand->right;
            if (uncle && uncle->color == 1) {
                node->parent->color = 0;
                uncle->color = 0;
                grand->color = 1;
                node = grand;
            } else {
                if (node == node->parent->right) {
                    node = node->parent;
                    RB_left_rotate(node);
                }
                node->parent->color = 0;
                grand->color = 1;
                RB_right_rotate(grand);
            }
        } else { // mirror case
            uncle = grand->left;
            if (uncle && uncle->color == 1) {
                node->parent->color = 0;
                uncle->color = 0;
                grand->color = 1;
                node = grand;
            } else {
                if (node == node->parent->left) {
                    node = node->parent;
                    RB_right_rotate(node);
                }
                node->parent->color = 0;
                grand->color = 1;
                RB_left_rotate(grand);
            }
        }
    }

    root->color = 0;
}


void RB_tree::preorder() {
    stack<Node*> evliya;
	int push_num = 0;
	evliya.push(root);

	while(!evliya.empty()) {
		Node* curr = evliya.top();
		evliya.pop();

		for(int i=0; i<push_num; i++)
			cout << "-";

		if(curr->color == 0)
			cout << "(BLACK) ";
		else 
			cout << "(RED) ";
		cout << curr->key.name << "\n";

		if(curr->right)
			evliya.push(curr->right);

		if(curr->left)
			evliya.push(curr->left);

		if(curr->right == nullptr && curr->left == nullptr)
			push_num--;
		else
			push_num++;

	}   
}

void RB_tree::find_best_seller() {
    if (!root) return; // Handle an empty tree

    stack<Node*> seyyah;
    Node* curr = root;
    seyyah.push(curr);

    publisher* na = nullptr;
    publisher* eu = nullptr;
    publisher* other = nullptr;

    while (!seyyah.empty()) {
        curr = seyyah.top();
        seyyah.pop();

        if (!na || curr->key.na_sales > na->na_sales)
            na = &(curr->key);
        if (!eu || curr->key.eu_sales > eu->eu_sales)
            eu = &(curr->key);
        if (!other || curr->key.others_sales > other->others_sales)
            other = &(curr->key);

        if (curr->right)
            seyyah.push(curr->right);
        if (curr->left)
            seyyah.push(curr->left);
    }

    best_seller[0] = na;
    best_seller[1] = eu;
    best_seller[2] = other;
}

RB_tree::RB_tree(){
	this->root = NULL;
    this->best_seller[0] = NULL;
    this->best_seller[1] = NULL;
    this->best_seller[2] = NULL;
}

RB_tree::~RB_tree(){
}
