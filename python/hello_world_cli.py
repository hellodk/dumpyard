#!/usr/bin/env python
import optparse

def main():
  p = optparse.OptionParser()
  p.add_option('--person', '-p', default="world")
  options, arguments = p.parse_args()
  print "Type of p is ", type(p), ' ',dir(p)
  print 'Options are ', options
  print 'Arguments are ', arguments
  print 'Hello %s' % options.person
if __name__ == '__main__':
  main()