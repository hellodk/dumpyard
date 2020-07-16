import requests
import json

r = requests.post('https://stream.twitter.com/1/statuses/filter.json',
    data={'track': 'requests'}, auth=('username', 'password'))

for line in r.iter_lines():
        if line: # filter out keep-alive new lines
                print line
                #print json.loads(line)