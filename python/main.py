import grequests
#from requests import async

urls = [
    'http://python-requests.org',
    'http://httpbin.org',
    'http://python-guide.org',
    'http://kennethreitz.com'
]

rs = [grequests.get(u) for u in urls]
grequests.map(rs)
print 'Request Imported'
