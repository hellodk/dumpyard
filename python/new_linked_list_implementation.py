#! /usr/bin/python
class Node(object):
    def __init__(self,data, node= None):
        self.data = data
        self.link = node


class LinkedList(object):
    head = None
    tail = None
    iterator = None
    list_size = 0
    # Appends the specified element to the end of  this list

    def add(self, data):
        newNode = Node(data)
        LinkedList.list_size = LinkedList.list_size + 1
    if(LinkedList.head is None):
        LinkedList.head = newNode
        LinkedList.tail = newNode
    else:
        LinkedList.tail.link = newNode
        LinkedList.tail = newNode

#add(index,E element)
#addAll(Collection<? extends E> c)
#clone()

#Inserts the specified element at the begining of this list    
def addFirst(self,data):
    newNode = Node(data)
    size = LinkedList.size(self)
    if(size==0):
        LinkedList.add(self,data)
    else:
        newNode.link = LinkedList.head
        LinkedList.head = newNode

#Appends the specified element to the end of this list
def addLast(self,data):
    LinkedList.add(self,data)

#Removes all of the elements from this list
def clear(self):
    LinkedList.head = None
    LinkedList.tail = None

def printList(self):
    LinkedList.iterator = LinkedList.head
    if(LinkedList.iterator is not None):
        while(LinkedList.iterator is not None):
            print LinkedList.iterator.data
            LinkedList.iterator = LinkedList.iterator.link
    else:
        print "List is empty"

#Returns the number of elements in this list
def size(self):
    return LinkedList.list_size

#Returns True if this list contains the specified element
def contains(self,element):
    LinkedList.iterator = LinkedList.head
    while(LinkedList.iterator is not None):
        if(type(LinkedList.iterator.data)==type(element)):
            if(LinkedList.iterator.data==element):
                return True
        LinkedList.iterator = LinkedList.iterator.link
    return False

#Returns the element at the specified position in this list get(int index)


#Returns the first element in this list.
def getFirst(self):
    if(LinkedList.head is not None):
        return LinkedList.head.data
    else:
        return None

#Returns the last element in this list
def getLast(self):
    if(LinkedList.tail is not None):
        return LinkedList.tail.data
    else:
        return None