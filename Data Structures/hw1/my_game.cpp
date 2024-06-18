// Melike Beşparmak
// 150220061

#include <stdlib.h>
#include <iostream>
#include <fstream>
#include <string>
#include <cstring>
#include <iterator>
#include "doublelinklist.h"
#include "objects.h"

using namespace std;

int main()
{
    GameState first_state;
    first_state.create_init_state();

    DoublyList<GameState>* states = new DoublyList<GameState>;
    states->addFront(first_state);

    GameState curr_state = first_state;   // To preserve current state
    GameState buffer_state = first_state; // To keep track possible moves in the current situation

    int effect_id = 0;
    while(!curr_state.win) {
        for(int i=1; i<6; i++) {
            for(int j=0; j<curr_state.rooms.get(curr_state.room_id)->room_objects.elemcount + curr_state.inventory.elemcount; j++) {
                // The objects in inventory should not be forgotten

                effect_id = buffer_state.advance(i, j);

                // States with the id 0 are not necessary therefore they should not be added to stack 
                // If the id is -1, there is no chance to continue as a ghost. 
                // Therefore, the state is changed with the current state in order to check further possible moves

                if(effect_id>0) {
                    states->addBack(buffer_state);
                    buffer_state = curr_state; 

                } else if(effect_id==-1) {
                    buffer_state = curr_state; 
                }                                    
            }
        }

        if(states->elemcount == 0) { // Since iterations are necessary, we shall not change the state if there are no states in the stack
            continue;
        }

        curr_state = states->tail->data; // When there are no moves left in the current state, we pop the last element and continue with that
        states->removeBack();
        buffer_state = curr_state;
    }

    return 0;
}
