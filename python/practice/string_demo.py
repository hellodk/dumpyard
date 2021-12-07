s = 'Our first string demo'
➢ print s[0] # first character
➢ print s[3]
➢ print s[-1] # last character
➢ print s[-2] # second last character
➢ print s[-5:]
➢ print s[:-5]



s = 'Manipulating Strings'
➢ print s[1:6] # 'anipu'
➢ print s[9:13] # 'ing '
➢ print s[0:2] # 'Ma'
➢ print s[:3] # 'Man'
➢ print s[-4:] # 'ings'
➢ print s[-5:-2] # fifth last character to 2nd last character
➢ print s[-2:-5] # no output


Length of strings
➢
❖
❖
Changing case:
➢ s = ‘Demonstration, of, String Functions by manipulating strings
➢ s.upper()
➢ s.lower()
'
Removing whitespace at both ends:
➢
❖
print len('Manipulating Strings')
s.strip()
Cutting a string into columns:
➢ s.split(' ')
➢ s.split(' ,')

Searching for substrings:
➢ print s.find('ing')
➢ print s.find('ings')
Replacing substrings:
➢
❖
print s.replace('strings','text')
Checking conditions:
➢ s.startswith('Man')
➢ s.startswith('Demo')
➢ s.endswith('ings')
➢ s.endswith('')

