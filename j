#!/usr/bin/env python
"""

 Calculate J or D from Sparky .list files
 written by Sung-Hun Bae 4/2/2012

 Usage : j Iso_1.list Iso_2.list
         j Iso_1.list Iso_2.list AnIso_1.list AnIso_2.list

"""


import sys,re,math,argparse

class AutoVivification(dict):
    """Implementation of perl's autovivification feature."""
    def __getitem__(self, item):
        try:
            return dict.__getitem__(self, item)
        except KeyError:
            value = self[item] = type(self)()
            return value

parser = argparse.ArgumentParser \
	(description='Calculate J or D from Sparky .list files')
parser.add_argument \
	('-v', action="store", dest="v", \
	help='long output', type=bool, default=False)
parser.add_argument \
	('-f', action="store", dest="f", \
	help='frequency for J or D calculation (1,2,3)', type=int, default=2)
parser.add_argument \
	('files', metavar='list', nargs='*', \
	help='Sparky .list files')

args = parser.parse_args()

nfiles = len(args.files)

if (not (nfiles == 2 or nfiles == 4)) :
	print ""
	print " Calculate J or D from Sparky .list files"
	print ""
	print " Usage : j Iso_1.list Iso_2.list"
	print "         j Iso_1.list Iso_2.list AnIso_1.list AnIso_2.list"
	print ""
	sys.exit(0)

PeakPos = AutoVivification ()
PeakId  = AutoVivification ()

Header   = re.compile(r"^Assignment")
ResParse = re.compile(r"(\d+\'*|[a-zA-Z]+)")
Iso      = re.compile(r'.*_iso_.*')
Pf1      = re.compile(r'.*_pf[1-9]_.*')
N15      = re.compile(r"^N")

DEFAULT_ERROR = 3.0
DEFAULT_TAG   = '*'

def fix_sign (L):
	maxV = -1
	maxI = 0
	for i in range (0, len(L)) :
		b = math.fabs(L[i])
		if b > maxV :
			maxV = b
			maxI = i
	if L[maxI] < 0.0: 
		for i in range (0, len(L)) :
			L[i] = -L[i]


def calc (pL, idstr, nuc1, nuc2): # peak list
	t = len(pL)
	if nfiles ==2 and t == 2: # J
		if DIM == 2:
			(w1a,w2a) = pL[0]
			(w1b,w2b) = pL[1]
			d = [w1b-w1a, w2b-w2a]
		if DIM == 3:
			(w1a,w2a,w3a) = pL[0]
			(w1b,w2b,w3b) = pL[1]
			d = [w1b-w1a, w2b-w2a, w3b-w3a]
	elif nfiles == 4 and t == 4: # D
		if DIM == 2:
			(w1a,w2a) = pL[0]
			(w1b,w2b) = pL[1]
			(W1a,W2a) = pL[2]
			(W1b,W2b) = pL[3]
			d = [w1b-w1a, w2b-w2a, W1b-W1a, W2b-W2a]
		if DIM == 3:
			(w1a,w2a,w3a) = pL[0]
			(w1b,w2b,w3b) = pL[1]
			(W1a,W2a,W3a) = pL[2]
			(W1b,W2b,W3b) = pL[3]
			d = [w1b-w1a, w2b-w2a, w3b-w3a, W1b-W1a, W2b-W2a, W3b-W3a]
	else : # error
		print ">>> ERROR: ", idstr+' '+nuc1+' '+nuc2
		sys.exit(0)

	fix_sign(d)

	if N15.match(nuc1):
		for i in range (0, len(d)):
			d[i] = -d[i]

	return d

# main
for listfile in args.files:
	try:
		f = open(listfile, 'r')
	except IOError:
		print ">>> ERROR: cannot open " + listfile
		sys.exit(0)
	# s= experiment series
	s = (((listfile.split('_')[-1:])[0]).split('.'))[0] # 00 01 ...
	# number of peaks
	nPeaks = 0
	for line in f.readlines():
		line = line.strip()

		if Header.match (line):
			col = line.split()
			#Assignment  w1  w2  w1 (Hz) w2 (Hz)             :  7 columns
			#Assignment  w1  w2  w3  w1 (Hz) w2 (Hz) w3 (Hz) : 10 columns
			if len(col) == 10: DIM = 3
			else : DIM = 2

		if not Header.match (line) and line:
			col = line.split()
			nPeaks += 1
			peakId = ResParse.findall(col[0])
			name = ''.join(peakId[2:])
			resSeq = int(peakId[1])
			PeakId[resSeq][name] = peakId
			if DIM == 2 : # 2D
				(w1,w2) = (float(col[3]), float(col[4]))
				if PeakPos[resSeq][name]:
					PeakPos[resSeq][name].append((w1,w2))
				else:
					PeakPos[resSeq][name] = [(w1,w2)]
			if DIM == 3 : # 3D
				(w1,w2,w3) = (float(col[4]), float(col[5]), float(col[6]))
				if PeakPos[resSeq][name]:
					PeakPos[resSeq][name].append((w1,w2,w3))
				else:
					PeakPos[resSeq][name] = [(w1,w2,w3)]
	if args.v: # verbose
		print "# %3d peaks %s" % (nPeaks, listfile)

for r in sorted(PeakPos):
	for n in sorted(PeakPos[r]):
		resName = PeakId[r][n][0] # e.g. A
		idstr   = PeakId[r][n][0]+PeakId[r][n][1] # e.g. A12
		nuc1    = PeakId[r][n][2]+PeakId[r][n][3] # e.g. C1'
		nuc2    = PeakId[r][n][4]+PeakId[r][n][5] # e.g. H1'
		err     = DEFAULT_ERROR
		tag     = DEFAULT_TAG
		delta   = calc (PeakPos[r][n], idstr, nuc1, nuc2)

		if nfiles == 2 : # J
			J = delta[args.f-1]

		if nfiles == 4 : # D
			J = delta[DIM + (args.f-1)] - delta[args.f-1]

		print "%4d %3s %-4s %-4s  %6.2f  %3.1f  %1s # %-5s " % \
				(r,resName,nuc1,nuc2,J,err,tag,idstr),
		print "%7.2f "*len(delta) % tuple(delta)
