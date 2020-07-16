#!/usr/bin/python
from geventhttpclient import HTTPClient
from geventhttpclient.url import URL

url = URL('http://gevent.org/')

http = HTTPClient(url.host)

# issue a get request
response = http.get(url.request_uri)

# read status_code
print response.status_code

# read response body
body = response.read()

# close connections
http.close()