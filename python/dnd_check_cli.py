#!/usr/bin/env python
import optparse

di = {}

def get_arguments(options=None, flag_options=None, description=None, usage=None,
                  version=None):
    p = optparse.OptionParser()
    p.add_option('--number', '-n', default="8791134412")
    p.add_option('--url', '-u', default="http://ncprstatus.in/api/v1/status?numbers=")
    options, arguments = p.parse_args()
    #print "Type of p is ", type(p), ' ',dir(p)
    print 'Options are ', options
    print 'Arguments are ', type(options)
    validate_arguments(p)

def validate_arguments(p):
    pass

if __name__ == '__main__':
  get_arguments()