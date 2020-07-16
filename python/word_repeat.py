def  firstRepeatedWord( s):
	li = s.split()
	di = {}
	for word in li:
		if word not in di:
			di[word] = 1
		else:
			di[word] = di[word]+1
		if di[word] >1:
			return word

def autocomplete(s,a):
	li = s.split()
	lis = set(li)
	new_list = []
	#print lis
	str = a.split()
	#a_len = len(a)
	for words in lis:
		substr = words[:len(a)]
		#print substr,' ',a
		if(substr==a):
			new_list.append(words)
			print new_list


	

s = 'deepak is my name my deepak dkhg'
a = 'd'
#s = "testing"
#print firstRepeatedWord(s)
print autocomplete(s,a)