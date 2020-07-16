def isArray_Balanced(arr):
	for i in xrange(0,len(arr)):
		left_total = sum(arr[:i])
		right_total = sum(arr[i:])
		print 'left_total ',left_total
		print 'right_total ' ,right_total
		if (left_total == right_total):
			return 1



array = [1,2,3,6]
print isArray_Balanced(array)




