#ifndef OBJECTS_HPP
#define OBJECTS_HPP

#include "doublelinklist.h"

using namespace std;

static string objectnames[] = {"Bed", "Book", "Viking Poster", "Skull Poster", "Cell Door", "Guard", "Exit Door", "Mirror", "Sink", "Toilet", "Toilet paper", "Door", "Floorguards", "Coin", "Clip", "Toilet permit", "Toilet info", "Guard (Near toilet)"};
static string roomnames[] = {"Cell", "Toilet", "Next Floor"};
int cell_objects[] = {0,1,2,3,4,5,6};
int toilet_objects[] = {7,8,9,10,11};
int out_objects[] = {6, 12};

struct Object
{
    string objectname;
    int iteration = 0;
    int LookAt(DoublyList<Object*>&);
    int TalkTo(DoublyList<Object*>&);
    int Misbehave(DoublyList<Object*>&);
    int PickUp(DoublyList<Object*>&);
};

struct Room
{
    string roomname;
    DoublyList<Object*> room_objects;
};


bool check_for_item(DoublyList<Object*>& inventory, string to_find)
{
    for(Node<Object*>* ptr = inventory.head; ptr != NULL; ptr= ptr->next)
    {
        if (ptr->data->objectname == to_find)
            return 1;
    }
    return 0;
}

int find_index(DoublyList<Object*>& inventory, string to_find)
{
    int counter = 0;
    for(Node<Object*>* ptr = inventory.head; ptr != NULL; ptr= ptr->next)
    {
        if (ptr->data->objectname == to_find)
            return counter;
        counter++;
    }
    return -1;
}


int Object::PickUp(DoublyList<Object*>& inventory)
{
    if(objectname == "Toilet paper")
    {
        cout << "This will be handy!" << endl;
        Object* newobject = new Object;
        newobject->objectname = "Toilet paper";
        inventory.addBack(newobject);
        return 7;
    }
    else
        cout << "I cannot pick up " << objectname << endl;

    return 0;
}


int Object::Misbehave(DoublyList<Object*>& inventory)
{
    if(objectname == "Guard")
    {
        bool found1 = check_for_item(inventory, "Toilet permit");
        bool found2 = check_for_item(inventory, "Toilet info");

        if(found1 && !found2)
        {
            cout << "Me: Ooof! AAAAAH! I have to go to toilet!" << endl;
            cout << "Guard: Damn! You read the book! Ok here you go…" << endl;

            return 8;
        }
        else if(!found1 && found2)
        {
            cout << "Me: Hey guard! The toilet is clogged" << endl;
            cout << "Guard: OK! I will check it." << endl;
            cout << "I can see the guard from there. His head is very close the to toilet seat..." << endl;
            return 9;
        }
        else if(!found1)
        {
            cout << "Me: You stupid guard!" << endl;
            cout << "Guard: What did you sayy!" << endl;
            cout << "GAME OVER: The guard killed you." << endl;
            return -1;
        }

    }
    else if(objectname == "Floorguards")
    {
        cout << "Me: Hii!" << endl;
        cout << "Guards: What the?" << endl;
        cout << "GAME OVER: The guards killed you." << endl;
        return -1;

    }

    else if(objectname == "Guard (Near toilet)")
    {
            cout << "I jumped over the guard and smashed his brain on the toilet seat! He is not a problem now..." << endl;
            return 10;
    }
    else if(objectname == "Toilet" && check_for_item(inventory, "Toilet paper"))
    {
        cout << "I threw the toilet paper to the toilet. FLUSSSH! Eww, the toilet is clogged!" << endl;
        inventory.remove(find_index(inventory,"Toilet paper"));
        Object* newobject = new Object;
        newobject->objectname = "Toilet info";
        inventory.addBack(newobject);
        return 11;
    }
    else
        cout << "I cannot misbehave to " << objectname << endl;

    return 0;
}

int Object::TalkTo(DoublyList<Object*>& inventory)
{
    if(objectname == "Guard")
    {
    iteration++;

        if (iteration == 1)
        {
        cout << "Me: What’s happening?" << endl;
        cout << "Guard: Shut up! I don’t need to talk to you! You  are sentenced to death and in a waiting list." << endl;
        cout << "Me: What is this place?" << endl;
        cout << "Guard: Damn, can’t you see that it’s a prison?" << endl;
        cout << "Me: How do I escape?" << endl;
        cout << "Guard: Noone has ever escaped and you won’t neither!" << endl;
        cout << "Me: This prison is no match for my prison escaping skills…" << endl;
        cout << "Guard: That’s what Houdini said…" << endl;
        }
        else
        {
        cout << "Guard: I don't want to talk to you!" << endl;
        }
    }
    else if(objectname == "Floorguards")
    {
        bool found = check_for_item(inventory, "Coin");
        if (!found)
        {
        cout << "Me: Hello??" << endl;
        cout << "Guards: What! What are you doing here?" << endl;
        cout << "GAME OVER: The guards killed you." << endl;
        return -1;
        }
        else
        {
        cout << "Me: Hi, I have a bribe for you =)" << endl;
        cout << "Guards: Thanks! You are free to leave!" << endl;
        cout << "WELL DONE!!!" << endl;
        return 12;        
        }
    }
    else if(objectname == "Guard (Near toilet)")
    {
        cout << "Me: Hello??" << endl;
        cout << "Guards: What! What are you doing here?" << endl;
        cout << "GAME OVER: The guard killed you." << endl;
        return -1;
    }
    else if(objectname == "Mirror")
    {
        cout << "Me: Hi, handsomeee :)" << endl;
    }

    return 0;
}


int Object::LookAt(DoublyList<Object*>& inventory)
{

    if(objectname == "Bed")
        cout << "The bed in the cell" << endl;
    else if(objectname == "Book")
    {
        this->iteration++;
        if (this->iteration == 1)
        {
            cout << "It’s a rulebook for prisoners, I didn’t read it yet." << endl;
            cout << "Ohh! It also has a clip as bookmarker! (Obtained: Clip)" << endl;
            Object* newobject = new Object;
            newobject->objectname = "Clip";
            inventory.addBack(newobject);
            return 1;
        }
        else if (this->iteration == 2)
        {
            cout << "Book: You maggot! Why you didn’t listen to your mother and end at the prison." << endl;
            return 2;
        }
        else if (this->iteration == 3)
        {
            cout << "Book: What you have done is unforgiveable!" << endl;
            return 3;
        }
        else if (this->iteration == 4)
        {
            cout << "Book: You are a dead man walking! You stand with one foot in the grave!" << endl;
            return 4;
        }
        else if (this->iteration == 5)
        {
            cout << "Book: However you also have some rights! You have the right to go to toilet! (Obtained: Toilet permit)" << endl;
            Object* newobject = new Object;
            newobject->objectname = "Toilet permit";
            inventory.addBack(newobject);
            return 5;
        }
        else
            cout << "This book was so useful for me." << endl;

    }
    else if (objectname == "Viking Poster")
        cout << "A poster of a Viking woman..." << endl;
    else if (objectname == "Skull Poster")
        cout << "A poster of a skull..." << endl;
    else if (objectname == "Cell Door")
        cout << "The door of the cell... A guard is watching me." << endl;
    else if (objectname == "Guard")
        cout << "He is not very friendly." << endl;
    else if (objectname == "Exit Door")
        cout << "Exit door to the floor." << endl;
    else if (objectname == "Mirror")
        cout << "Hi, handsomeee :)" << endl;
    else if (objectname == "Sink" && !check_for_item(inventory, "Coin"))
    {
        cout << "A very dirty sink. Heyyy, wait a second. There is a coin! (Obtained: Coin)" << endl;
        Object* newobject = new Object;
        newobject->objectname = "Coin";
        inventory.addBack(newobject);
        return 6;
    }
    else if (objectname == "Toilet")
        cout << "It stinks!" << endl;
    else if (objectname == "Toilet paper")
        cout << "At least the toilet paper is clean..." << endl;
    else if (objectname == "Floorguards")
        cout << "They are busy talkin'..." << endl;
    else if (objectname == "Coin")
        cout << "Shiny and valuable" << endl;
    else if (objectname == "Clip")
        cout << "It may be used to open cell door." << endl;
    else if (objectname == "Toilet permit")
        cout << "I have the right to go to toilet!" << endl;
    else
        cout << "I cannot look at " << objectname << endl;


    return 0;
}

struct GameState
{
    DoublyList<Object*> inventory;
    DoublyList<Room*> rooms;
    bool lose = 0, win = 0;
    int room_id = 0;

    void create_init_state();
    void print_situation();
    int advance(int, int);
};

int GameState::advance(int action, int object)
{
    int result = 0;

    if(action == 1)
    {
        if (object < rooms.get(room_id)->room_objects.elemcount)
        {
            if (room_id == 1 && rooms.get(room_id)->room_objects.get(object)->objectname == "Door")
            {
                room_id = 0;
                return 13;
            }
            else if(room_id == 0 && find_index(rooms.get(room_id)->room_objects, "Guard") == -1 && check_for_item(inventory, "Clip") && rooms.get(room_id)->room_objects.get(object)->objectname == "Cell Door" )
            {
                cout << "The guard is not here. I can open the cell door." << endl;
                room_id = 1;
                return 14;
            }
            else if(room_id == 0 && find_index(rooms.get(0)->room_objects, "Guard") == -1 && find_index(rooms.get(1)->room_objects, "Guard (Near toilet)") == -1  && rooms.get(room_id)->room_objects.get(object)->objectname == "Exit Door")
            {
                cout << "The guard is not here. I can open the main exit door." << endl;
                room_id = 2;
                return 15;
            }
            else if(room_id == 2 && rooms.get(room_id)->room_objects.get(object)->objectname == "Exit Door" )
            {
                cout << "I may return back..." << endl;
                room_id = 0;
                return 16;
            }
            else
                cout << "I cannot open " << rooms.get(room_id)->room_objects.get(object)->objectname << endl;                
        }
        return 0;          
    }
    else if(action == 2)
    {
        if (object < rooms.get(room_id)->room_objects.elemcount)
            result = rooms.get(room_id)->room_objects.get(object)->LookAt(inventory);
        else
            result = inventory.get(object - rooms.get(room_id)->room_objects.elemcount)->LookAt(inventory);
    }
    else if(action == 3)
    {
        if (object < rooms.get(room_id)->room_objects.elemcount)
        {
            result = rooms.get(room_id)->room_objects.get(object)->PickUp(inventory);

            if (result == 7)
                rooms.get(room_id)->room_objects.remove(object);
        }
    }        
    else if(action == 4)
    {
        if (object < rooms.get(room_id)->room_objects.elemcount)
            {
                result = rooms.get(room_id)->room_objects.get(object)->Misbehave(inventory);
                
                
                if (result == 8)
                    room_id = 1;
                else if(result == -1)
                    lose = 1;
                else if (result == 9)
                {
                    rooms.get(room_id)->room_objects.remove(find_index(rooms.get(room_id)->room_objects, "Guard"));
                    Object* newobject = new Object;
                    newobject->objectname = "Guard (Near toilet)";
                    rooms.get(1)->room_objects.addBack(newobject);
                }
                else if (result == 10)
                {
                    rooms.get(room_id)->room_objects.remove(find_index(rooms.get(room_id)->room_objects, "Guard (Near toilet)"));
                }
            }        

    }
    else if(action == 5)
    {
        if (object < rooms.get(room_id)->room_objects.elemcount)
            result = rooms.get(room_id)->room_objects.get(object)->TalkTo(inventory);

        if (result == -1)
            lose = 1;
        if (result == 12)
            win = 1;

    }
    return result;
}

void GameState::print_situation()
{
    cout << "********************************************" << endl;
    cout << "You are in " << rooms.get(room_id)->roomname << endl;
    cout << "The objects in the room are: " ;
    for(int i=0; i<rooms.get(room_id)->room_objects.elemcount; i++)
    {
        cout << i<< "- " <<rooms.get(room_id)->room_objects.get(i)->objectname << " ";
    }
    cout << endl;

    cout << "The objects in the inventory are: " ;

    for(int i=0; i< inventory.elemcount; i++)
    {
        cout << rooms.get(room_id)->room_objects.elemcount + i << "- " << inventory.get(i)->objectname << " ";
    }
    cout << endl;
    cout << "********************************************" << endl;

}

void GameState::create_init_state()
{
   for(auto sel_roomname: roomnames)
   {
        Room* newroom = new Room;
        newroom->roomname = sel_roomname;
        
        if(newroom->roomname == "Cell")
        {
            for(auto obj_id: cell_objects)
            {
                    Object* newobject = new Object;
                    newobject->objectname = objectnames[obj_id];
                    newroom->room_objects.addBack(newobject);
            }

        }
        else if(newroom->roomname == "Toilet")
        {
            for(auto obj_id: toilet_objects)
            {
                Object* newobject = new Object;
                newobject->objectname = objectnames[obj_id];
                newroom->room_objects.addBack(newobject);
            }

        }
        else
        {
            for(auto obj_id: out_objects)
            {
                Object* newobject = new Object;
                newobject->objectname = objectnames[obj_id];
                newroom->room_objects.addBack(newobject);
            }

        }

        rooms.addBack(newroom);

   }
}


#endif
