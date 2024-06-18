#ifndef DOUBLY_LL_HPP
#define DOUBLY_LL_HPP

#include <cstddef>
template<typename T>
struct DoublyList;

template<typename T>
struct Node {
        T data;
        Node *next = NULL;
        Node *previous = NULL;
};

template<typename T>
struct DoublyList
{
        Node<T>* head = NULL;
        Node<T>* tail = NULL;
        int elemcount = 0;
        void addFront(T);
        void addBack(T);
        void add(T, int);
        void removeFront();
        void removeBack();
        void remove(int);
        T get(int);
};

template<class T>
void DoublyList<T>::addBack(T new_element) {

    Node<T>* newnode = new Node<T>;
    newnode->data = new_element;
    newnode->previous = this->tail;

    if (this->tail != NULL)
        this->tail->next = newnode;

    this->tail = newnode;
    elemcount++;

    if(elemcount == 1)
        this->head = newnode;
}

template<class T>
T DoublyList<T>::get(int position)
{

    Node<T>* iterator = this->head;
    
    for(int index = 0; index < position ; index++)
        {
            iterator = iterator->next;
        }
    return iterator->data;
}

template<class T>
void DoublyList<T>::removeBack() {

    if (this->tail != NULL)
    {
        Node<T>* old = this->tail;

        if (this->tail->previous != NULL)
            this->tail->previous->next = NULL;
        
        this->tail = this->tail->previous;
        delete old;
        elemcount--;
    }
}

template<class T>
void DoublyList<T>::removeFront() {

    if (this->head != NULL)
    {
        Node<T>* old = this->head;

        if (this->head->next != NULL)
            this->head->next->previous = NULL;
        
        this->head = this->head->next;
        delete old;
        elemcount--;
    }
}


template<class T>
void DoublyList<T>::addFront(T new_element) {

    Node<T>* newnode = new Node<T>;
    newnode->data = new_element;
    newnode->next = this->head;

    if (this->head != NULL)
        this->head->previous = newnode;

    this->head = newnode;
    elemcount++;

    if(elemcount == 1)
        this->tail = newnode;
}



template<class T>
void DoublyList<T>::add(T new_element, int position)
{
    if (position == 0)
    {
        addFront(new_element);
        return;
    }
    else if (position > elemcount)
        return;

    Node<T>* newnode = new Node<T>;
    newnode->data = new_element;
    Node<T>* prev_node = NULL;
    Node<T>* position_pointer = this->head;

    for(int index = 0; index < position ; index++)
    {
        prev_node = position_pointer;
        position_pointer = position_pointer->next;
    }

    prev_node->next = newnode;
    newnode->next = position_pointer;
    newnode->previous = prev_node;
    position_pointer->previous = newnode;

    elemcount++;
}

template<class T>
void DoublyList<T>::remove(int position)
{
    if (position == 0)
    {
        removeFront();
        return;
    }
    else if (position == elemcount-1)
    {
        removeBack();
        return;
    }
    else if(position >= elemcount)
        return;

    Node<T>* prev_node = NULL;
    Node<T>* position_pointer = this->head;

    for(int index = 0; index < position ; index++)
    {
        prev_node = position_pointer;
        position_pointer = position_pointer->next;
    }
    Node<T>* old = position_pointer;
    prev_node->next = position_pointer->next;

    if (position_pointer->next != NULL)
        position_pointer->next->previous = prev_node;
    delete old;
    elemcount--;
}

#endif