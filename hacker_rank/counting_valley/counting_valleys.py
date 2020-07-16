# Complete the countingValleys function below.


def countingValleys(n, s):
    value = 0
    counter = 0
    for elem in s:
        if (elem == 'U'):
            value = value + 1
        elif (elem == 'D'):
            if(value == 0):
                counter = counter + 1
            value = value - 1
    return counter


if __name__ == '__main__':
    n = 9
    s = 'UDDDUDUU'
    s1 = 'DUDDDUUDUU'
    result = countingValleys(n, s1)
    print (result)
