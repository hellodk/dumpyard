import time
start = time.time()
tic = lambda: 'at %1.1f seconds' % (time.time() - start)
print tic()


