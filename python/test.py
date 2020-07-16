import sys # basic import statement

di = {} # creating a basic dictionary to store the key value pair for the alphabets, this is a global dictionary
values = []
'''since,
	A = 1, B=A*2+2 and so on, there is a basic formula, where we take mul as 0 and keep on reassigning it's values on the go as you will
	see in the code below
	A = mul*2 + Natural Number
	B = mul*2 + Natural number + 1 ans so on....
'''

def makeDict(): # this is how we create a function in python
	mul = 0
	increment = 1
	for i in xrange(65,91): # iterating over a range of ascii values, check yourself how xrange works :) :)	
		di[chr(i)] = mul*2+increment #chr() function converts integre to it's corresponding ascii
		values.append(di[chr(i)])
		mul = di[chr(i)] # re-assigning mul for the next value
		increment = increment + 1 # this refers to the natural number

# this function calculates the sum of the alphabets you pass on
def calculateSum(string):
	number_list = [] # a blacnk list is created
	str = string.upper() # you guess what is being done here
	list_str = list(str) 
	getNumberList(list_str, number_list) # this is how we call a function
	print 'The sum is ', sum(number_list) # printing the sum

#this function accepts the string list and converts it to it corresponding number list
def getNumberList(list_str, number_list):
	for i in list_str:
		number_list.append(di[i])


def getCorrespondingLetters(number):
	su = [0]
	val = sorted(values)
	while(sum(su)!=number):
		print 'Inside while'
		if(sum(su)<number):
			for i in val:
				su.append(i)
		elif (sum(su)>number):
			print 'Sum exceeds the number by ', sum(su)-number
			break
	print 'Values in su is ', su , '\n'

	#sum = sum + val(-1:)
	# check_if_valid(number,su)
	# su.sort()
	# while(su[-1]>number):
	# 	su.pop()
	# print 'New value of su is ' , sorted(su)

'''
def check_if_valid(number, su):
	for numbers in di.itervalues():
		su.append(numbers)
	sums = sum(su)
	if number<=numbers:
		print 'go ahead'
	else:
		print 'Number is beyind the scope'
		sys.exit(0)
'''

if __name__=='__main__':
	makeDict()
	calculateSum('abcd')
	print 'dictionary is : \n', di
	print '\n'
	print 'vlaues ', values, '\n'
	getCorrespondingLetters(42)