li = ["192.168.33.1", "192.168.33.2", "192.168.33.3",
      "192.168.33.4", "192.16.23.4", "12.43.34.54", ]

di = {}

for elem in li:
    di[elem] = int((elem.replace('.', '')))

p = di.values()

p = sorted(p)

print (p)

q = di.keys()

sorted_list = []

for elem in p:
    for i in q:
        if elem == int(i.replace('.', '')):
            sorted_list.append(i)

print (sorted_list)
