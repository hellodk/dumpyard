def reverse(x):
    '''
    Reverses a number
    '''
    y = 0 
    while x%10 > 0: 
        y = y * 10 + x % 10 
        x = x // 10 
    return y 

                                                                                                                                             
def is_pallindrome(x):
    '''
    Checks if a number is pallindrome
    ''' 
    if (x == reverse(x)): 
        print ("Pallindrome") 
    else: 
        print ("Not Pallindrome") 