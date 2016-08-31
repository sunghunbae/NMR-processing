#!/usr/bin/env python
#
# Parameter Query (PQ)
#
# retrieve Agilent(formerly Varian) parameter file procpar
# written by Sung-Hun Bae 08/22/2011
#

import sys,re

# usage
if (len(sys.argv) < 2):
  print ""
  print "\tParameter Query (from Varian procpar file)"
  print ""
  print "\tUsage: pq [directory] [parameters]"
  print "\t (ex)  pq 2011_08_22_test.fid nt sw sw1 np ni"
  print ""
  sys.exit(1)

# read procpar
try:
  f = open(sys.argv[1]+'/procpar','r')
except IOError:
  print ">>> ERROR: cannot open " + sys.argv[1] + '/procpar'
  sys.exit(1)

# initialize storage
Parameter = {}

# parse procpar
# Line1 : parameter name and attributes
# Line2 : value(s)
# Line3 : available option(s)
Line1 = re.compile(r"^[a-zA-Z]")
Line2 = False
Line3 = False
param = 'None'
value = 'None'
for line in f.readlines():
	line = line.rstrip()
	line = line.lstrip()
	if Line1.match(line):
		param = (line.split())[0]
		Line2 = True
	elif Line2:
		value = line.split()
		del value[0]
		Parameter[param] = value
		# print param, value
		Line2 = False
		Line3 = True
	elif Line3:
		Line3 = False

#######################################
## find query parameter(s)
##

for q in sys.argv[2:]:
	if q in Parameter:
		print "%-12s %s" % (q, Parameter[q])
	else:
		print "%-12s --- not found ---"  % (q)
