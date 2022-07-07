def factorial(n):
	'''
	Returns the factorial for the input
	'''
	if (n ==1 or n ==0):
		return 1
	else:
		return (n * factorial(n -1))

if __name__ == "__main__":
	print (factorial(5))
