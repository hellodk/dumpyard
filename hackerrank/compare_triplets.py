#!/bin/python3

import os

# Complete the compareTriplets function below.


def compareTriplets(a, b):
    alice = 0
    bob = 0
    for i in range(0, len(a)):
        if (a[i] > b[i]):
            alice = alice + 1
        elif (b[i] > a[i]):
            bob = bob + 1
    return (alice, bob)


if __name__ == '__main__':
    fptr = open(os.environ['OUTPUT_PATH'], 'w')

    a = list(map(int, input().rstrip().split()))

    b = list(map(int, input().rstrip().split()))
    result = compareTriplets(a, b)

    fptr.write(' '.join(map(str, result)))
    fptr.write('\n')

    fptr.close()
