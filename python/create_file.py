import time

t0 = time.time()
chunk = "a" * 10**7
open("bla.txt", "wb").write(chunk)
d = time.time() - t0
print "duration: %.2f s." % d
