from requests import Session

session = Session()
# first requests starts and blocks until finished
response_one = session.get('http://httpbin.org/get')
# second request starts once first is finished
response_two = session.get('http://httpbin.org/get?foo=bar')
# both requests are complete
print('response one status: {0}'.format(response_one.status_code))
print(response_one.content)
print('response two status: {0}'.format(response_two.status_code))
print(response_two.content)