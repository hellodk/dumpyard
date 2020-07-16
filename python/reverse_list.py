def reverse_list(li):
	print (li[::-1])

li = [1,2,3,4,5,6,7,8,9]
reverse_list(li)
for item in xrange(len(li),-1,-1):
	print (item,)

