
import python_algorithms
class Node:
    def __init__(self):
        self.item = None
        self.link = None


class Stack:
    def __init__(self):
        self.top = 0
        self.head = Node()

    def isEmpty(self):
        return top == 0

    def push(self, item):
        oldHead = self.head
        self.head = Node()
        self.head.item = item
        self.head.link = oldHead
        self.top += 1


    def pop(self):
        item = self.head.item
        self.head = self.head.link
        self.top -= 1
        return item

class List:
    def __init__(self):
        self.top = 0
        self.head = Node()

    def get(self, *args):
        if not args:
            return self.head.item
        elif type(args[0]) is int:
            pos = args[0]
            current = self.head
            count = 0
            while count < pos - 1 and current.link != None:
                current = current.link
                count += 1
           return current.item
       else:  
            raise TypeError

    def pop(self, *args):
        if not args:
            item = self.head.item
            head = self.head.link
            return item

    def append(self, item):
        oldhead = self.head
        self.head = Node()
        self.head.item = item
        self.head.link = oldhead
        self.top += 1

    def insert(self, item, pos):
        current = self.head
        count = 0
        while count < pos - 1 and current.link != None:
            current = current.link
            count += 1
        node = Node()
        node.item = item

        node.link = current.link
        current.link = node
        self.top += 1
