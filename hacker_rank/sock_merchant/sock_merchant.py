#!/bin/python3


def sockMerchant(n, ar):
    di = {i: ar.count(i) for i in ar}
    count = 0
    for elem in di.values():
        count = count + int(elem // 2)
    return count


if __name__ == '__main__':
    # fptr = open(os.environ['OUTPUT_PATH'], 'w')

    # n = int(input())
    n = 9
    # ar = list(map(int, input().rstrip().split()))
    ar = [9, 10, 20, 20, 10, 10, 30, 50, 10, 20]

    result = sockMerchant(n, ar)
    print (result)
