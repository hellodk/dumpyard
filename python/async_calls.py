from requests_futures.sessions import FuturesSession

session = FuturesSession(max_workers=200)

d = {}
for i in range(100):
    d[i] = session.get('http://httpbin.org/get?foo=bar%s' % i)
#    v = d[i]
#    k = i
for k, v in d.items():
    resp = v.result()
    print('%s: %s' % (k, resp.status_code))

#future_one = session.get('http://httpbin.org/get')
#future_two = session.get('http://httpbin.org/get?foo=bar')
#
#response_one = future_one.result()
#print('response one status: {0}'.format(response_one.status_code))
#print(response_one.content)
#
#response_two = future_two.result()
##response_two = future_two.result()
#print('response two status: {0}'.format(response_two.status_code))
#print(response_two.content)
