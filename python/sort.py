def sorts(lis):
    '''
    sorts out a list in ascending order
    '''
    sorted_li = []
    for elem in xrange(0, (len(lis))):
        min = find_min(lis)
        sorted_li.append(min)
        lis.remove(min)
        print lis, elem
    return sorted_li


def find_min(lis):
    '''
    take a list and returns the minimum form the list
    '''
    if (len(lis) == 1):
        return li[0]
    min = lis[0]
    for elem in lis:
        if (elem < min):
            min = elem
    return min

sorted = []
li = [6, 1, 4, 2, 3, -1]
print sorts(li)
