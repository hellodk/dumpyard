import urllib2
import threading

import os
import requests


class Test:
	def http_response(self,req,response):
		print "url is : %s" % (response.geturl(),)
		print "info: %s" % (response.info(),)
        for l in response:
            print l
        return response.content()


o = urllib2.build_opener(Test())
t = threading.Thread(target=o.open, args=('http://www.google.com/',))
t.start()
print "I'm asynchronous!"	