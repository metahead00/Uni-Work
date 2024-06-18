//Melike Besparmak
//150220061
#include<iostream>
#include<string>
#include<cstdlib>
#include<time.h>
#include "doublelinklist.h"

using namespace std;

struct attack{   // class for pokemon attacks
	private:
		string name;
		int pp;
		int accuracy;
		int damage;
		int first;
	public:
		attack(const string&, int, int, int, int);
		int get_first();
		int get_accuracy();
		int get_damage();
		int get_pp();
		string get_name();
};

attack::attack(const string& name_in, int p, int a, int d, int f){
	name = name_in;
	pp = p;
	accuracy = a;
	damage = d;
	first = f;
}

string attack::get_name(){
	return name;
}

int attack::get_pp(){
	return pp;
}

int attack::get_damage(){
	return damage;
}

int attack::get_first(){
	return first;
}

int attack::get_accuracy(){
	return accuracy;
}

struct pokemon{  // class for pokemons
	int pp;
	int hp;
	string name;
	DoublyList<attack*> attacks;
	pokemon(const string &name_in, int, int); 
	string get_name();
	void set(char, int to_reduce);
};

pokemon::pokemon(const string &name_in, int p, int h){
	name = name_in;
	pp = p;
	hp = h;
}

void pokemon::set(char which, int to_reduce){
	if(which == 'p'){
		pp += to_reduce;
	}else{
		hp -= to_reduce;
	}
}

struct node{  // class for the nodes of the graph
	string ifef;  // attack is efficient or nonefficent
	string curattack;  // attack name
	int num;  // node num
	pokemon* pikachu;  // current pikachu
	pokemon* blastoise;  // currrent blastoise
	char status;  // whose turn?
	int level;  // level of the node
	bool isleaf;  // node is a leaf or not
	double prob;  // prob of the node happening
	 
	DoublyList<node*> child;  // children nodes of the node
	
	node* parent; // parent node to keep track for part 2

	//Member functions goes there...
	void add_back(node* c) {
		child.addBack(c);
	}
	node(string ef, string curratt, int num_node, pokemon* p, pokemon* b, char st, int lev, double pr);
};

node::node(string ef, string curratt, int num_node, pokemon* p, pokemon* b, char st, int lev, double pr) {
	ifef = ef;
	curattack = curratt;
	num = num_node;
	pikachu = p;
	blastoise = b;
	status = st;
	level = lev;
	prob = pr;
}

struct graph{
	private:
		node* root;
	public:
		graph(pokemon*, pokemon*);
		~graph();
		void create_graph(node*, int max, pokemon* pikachu, pokemon* blastoise);
		void print_graph(node*, int max);
		
		void part1(node* root, int max);
		void part2(node*, int max, string);

		node* getRoot() {
			return root;
		}
};

graph::graph(pokemon* p, pokemon* b) {
	node* root = new node("effective", "", 0, p, b, 'p', 0, 1);
	root->isleaf=0;
	this->root = root;
};

graph::~graph() {
	if (root == nullptr) {
        return;
    }

    DoublyList<node*> q;
    q.addBack(root);
	int level=0;
	node* curr = root;
	node* temp = curr;
	while(q.elemcount!=0) {
		curr = q.head->data;
		level = curr->level;
		q.removeFront();
		for(Node<node*>* child = curr->child.head; child!=NULL; child = child->next) {
			q.addBack(child->data);
		}
		delete curr->blastoise;
		delete curr->pikachu;
		temp = curr;
		delete curr;
		curr = temp;
	}
	

}

void graph::create_graph(node* root, int max_level, pokemon* pikachu, pokemon* blastoise) {
	if (root == nullptr) {
		return;
	}

	// list of graph nodes
	DoublyList<node*> q;
	q.addFront(root);
	node* curr = root;

	int level=0;
	int node_num=1;
	while (q.elemcount != 0 && level <= max_level) {
		curr = q.head->data;
		q.removeFront();
		if(curr->isleaf) {
			continue;
		}
		level = curr->level;
		if(level==max_level) {
			break;
		}
		pokemon* currpik = curr->pikachu;
		pokemon* currblas = curr->blastoise;

		// push possible attacks to doubly list
		//DoublyList<attack*> possible_attacks;
		int prob_bias = 0;
		
		//Pikachu
		if(curr->status == 'p') {
			for (Node<attack*>* attack = pikachu->attacks.head; attack!=NULL; attack = attack->next) {

				if(attack->data->get_first() > level || currpik->pp < -attack->data->get_pp()) {
					continue;
				}
				prob_bias++;
				//possible_attacks.addBack(attack->data);
			}
		} 
		// Blastoise 
		else {
			for (Node<attack*>* attack = blastoise->attacks.head; attack!=NULL; attack = attack->next) {
				if(attack->data->get_first() > level || currblas->pp < -attack->data->get_pp()) {
					continue;
				}
				prob_bias++;
				//possible_attacks.addBack(attack->data);
			}
		}
		
		// Pikachu
		if(curr->status == 'p') {
			for (Node<attack*>* attack = pikachu->attacks.head; attack!=NULL; attack = attack->next) {
				double prob = 0;
				if(attack->data->get_first() > level || currpik->pp < -attack->data->get_pp()) {
					continue;
				}
				if(attack->data->get_accuracy() != 100) {

					// effective with a probability
					prob = curr->prob * attack->data->get_accuracy()/(100*prob_bias); 
					pokemon* pik2 = new pokemon("pikachu", currpik->pp + attack->data->get_pp(), currpik->hp);
					pokemon* blas2 = new pokemon("blastoise", currblas->pp, currblas->hp - attack->data->get_damage()); 
					node* newnode2 = new node("effective", attack->data->get_name(), node_num, pik2, blas2, 'b', level+1, prob);
					q.addBack(newnode2);
					curr->child.addBack(newnode2);
					newnode2->parent = curr;
					node_num++;

					if(level == max_level || currpik->hp<=0 || currblas->hp<=0) {
						curr->child.tail->data->isleaf = 1;
					} else {
						curr->child.tail->data->isleaf = 0;
					}

					// not effective
					prob = curr->prob * (100-attack->data->get_accuracy())/(100*prob_bias);
					pokemon* pik1 = new pokemon("pikachu", currpik->pp + attack->data->get_pp(), currpik->hp);
					pokemon* blas1 = new pokemon("blastoise", currblas->pp, currblas->hp);					
					node* newnode = new node("not effective", attack->data->get_name(), node_num, pik1, blas1, 'b', level+1, prob);
					node_num++;
					q.addBack(newnode);
					curr->child.addBack(newnode);
					newnode->parent = curr;

				} else {

					// 100% effective
					pokemon* pik2 = new pokemon("pikachu", currpik->pp + attack->data->get_pp(), currpik->hp);
					pokemon* blas2 = new pokemon("blastoise", currblas->pp, currblas->hp - attack->data->get_damage()); 
					prob = curr->prob/prob_bias; // * 1/available attacks
					node* newnode3 = new node("effective", attack->data->get_name(), node_num, pik2, blas2, 'b', level+1, prob);
					q.addBack(newnode3);
					curr->child.addBack(newnode3);
					node_num++;
					newnode3->parent = curr;
				}

				if(level == max_level || currpik->hp<=0 || currblas->hp<=0) {
					curr->child.tail->data->isleaf = 1;
				} else {
					curr->child.tail->data->isleaf = 0;
				}
				
			}
		} 
		// Blastoise
		else {
			// Same as previous if, change pikacu and blastoise pp/hp, change status
			for (Node<attack*>* attack = blastoise->attacks.head; attack!=NULL; attack = attack->next) {
				if(attack->data->get_first() > level || currblas->pp < -attack->data->get_pp()) {
					continue;
				}
				double prob = 0;
				// not effective can be added as in pikachu but since every attack of blastoise is effective
				// it is not necessary
				// 100% effective
				pokemon* pik2 = new pokemon("pikachu", currpik->pp, currpik->hp - attack->data->get_damage());
				pokemon* blas2 = new pokemon("blastoise", currblas->pp + attack->data->get_pp(), currblas->hp); 
				prob = curr->prob/prob_bias; // * 1/available attacks
				node* newnode3 = new node("effective", attack->data->get_name(), node_num, pik2, blas2, 'p', level+1, prob);
				q.addBack(newnode3);
				curr->child.addBack(newnode3);
				node_num++;
				newnode3->parent = curr;					

				if(level == max_level || currpik->hp<=0 || currblas->hp<=0) {
					curr->child.tail->data->isleaf = 1;
				} else {
					curr->child.tail->data->isleaf = 0;
				}			
			}		
		}
		
	}
}

void graph::part1(node* root, int m_level) {
    if (root == nullptr) {
        return;
    }

    if (m_level == 0) {
        cout << "P_HP:" << root->pikachu->hp << " P_PP:" << root->pikachu->pp << " B_HP:" << root->blastoise->hp << " B_PP:" << root->blastoise->pp << " PROB:" << root->prob << "\n";
        return;
    }

    DoublyList<node*> q;
    root->level = 0;
    q.addBack(root);
	int level=0;
	node* curr;
	while(q.elemcount!=0) {
		curr = q.head->data;
		if(curr->level == m_level)
            cout << "P_HP:" << curr->pikachu->hp << " P_PP:" << curr->pikachu->pp << " B_HP:" << curr->blastoise->hp << " B_PP:" << curr->blastoise->pp << " PROB:" << curr->prob << "\n";
		
		int size = curr->child.elemcount;
		level = curr->level;
		q.removeFront();
		for(Node<node*>* child = curr->child.head; child!=NULL; child = child->next) {
			q.addBack(child->data);
		}
	}
}

void graph::part2(node* root, int max, string poke) {
	if (root == nullptr) {
		return;
	}

	DoublyList<node*> q; // queue for traversing
    q.addBack(root);
	int level=0;
	node* curr;
	int count=0;
	while(q.elemcount!=0 && level <= max) {
		curr = q.head->data;

		// find the first and shortest victory for pikachu
		if (poke == "pikachu" && curr->blastoise->hp <= 0) {
            break;
        }

		// find the first and shortest victory for blastoise
        if (poke == "blastoise" && curr->pikachu->hp <= 0) {
            break;
        }

		int size = curr->child.elemcount;
		level = curr->level;
		q.removeFront();
		for(Node<node*>* child = curr->child.head; child!=NULL; child = child->next) {
			q.addBack(child->data);
		}
		
	}

	DoublyList<node*> s; // stack for printing the path
	// adding to stack
	while(curr->parent) {
		s.addBack(curr);
		curr = curr->parent;
	}

	// printing the path
	level=0;
	while(s.elemcount != 0) {
		curr = s.tail->data;
		s.removeBack();

		if(curr->status == 'p') {
			cout << "Blastoise used " << curr->curattack << ": " << curr->ifef << "\n";
		} else {
			cout << "Pikachu used " << curr->curattack << ": " << curr->ifef << "\n";
		}
		level++;
	}
	cout << "Level count: " << level << "\n";
	cout << "Probability: " << curr->prob << "\n";

}

int main(int argc, char** argv){
	string part = argv[1];
	int max;
	string which;
	if(part == "part1"){
		char* level = argv[2];
		max = atoi(level);
	}else if(part == "part2"){
		which = argv[2];
		max = 10;
	}
	else
		return -1;  
		
	pokemon* pikachu = new pokemon("pikachu", 100, 200);
	pokemon* blastoise = new pokemon("blastoise", 100, 200);
	
	attack* thundershock = new attack("thundershock", -10, 100, 40, 0);
	attack* skullbash = new attack("skullbash", -15, 70, 50, 0);
	attack* slam = new attack("slam", -20, 80, 60, 0);
	attack* pskip = new attack("skip", 100, 100, 0, 3);
	pikachu->attacks.addBack(thundershock);
	pikachu->attacks.addBack(skullbash);
	pikachu->attacks.addBack(slam);
	pikachu->attacks.addBack(pskip);

	attack* tackle = new attack("tackle", -10, 100, 30, 0);
	attack* watergun = new attack("watergun", -20, 100, 40, 0);
	attack* bite = new attack("bite", -25, 100, 60, 0);
	attack* bskip = new attack("skip", 100, 100, 0, 3);
	blastoise->attacks.addBack(tackle);
	blastoise->attacks.addBack(watergun);
	blastoise->attacks.addBack(bite);
	blastoise->attacks.addBack(bskip);

	//int max = 7;
	//string part = "part2";
	//string which = "pikachu";
	graph* g = new graph(pikachu, blastoise);
	g->create_graph(g->getRoot(), max, pikachu, blastoise);

	if(part == "part1") {
		g->part1(g->getRoot(), max);
	} else {
		g->part2(g->getRoot(), max, which);
	}

	delete g;
}