import salt.client
caller = salt.client.Caller()
caller.function('event.send',
                'salt/mycustomtag',
                {'foo': 'bar'})
