# Import the proper library
import salt.utils.event
# Create and fire event
sock_dir = '/var/run/salt/master'
payload = {'sample-msg': 'this is a test',
           'example': 'this is the same test'}
event = salt.utils.event.SaltEvent('master', sock_dir)
event.fire_event(payload, 'salt/mycustomtag')
