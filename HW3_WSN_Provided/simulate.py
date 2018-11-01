#! /usr/bin/python
import sys
from TOSSIM import *

# Number of nodes in the simulated network is 27
number_of_nodes = 27

t = Tossim([])
m = t.mac()
r = t.radio()

# The type of debug messages that will be printed out. [add, comment and uncomment as you need]
#t.addChannel("BOOT", sys.stdout)
t.addChannel("LED", sys.stdout)
t.addChannel("PKG", sys.stdout)
t.addChannel("DROP", sys.stdout)
t.addChannel("FWD", sys.stdout)
t.addChannel("BASE", sys.stdout)
#t.addChannel("DBG", sys.stdout)
t.addChannel("ERR", sys.stdout)
#t.addChannel("FILE", sys.stdout)

for i in range(number_of_nodes):
	m = t.getNode(i)
	m.bootAtTime((31 + t.ticksPerSecond() / 10) * i + 1)

f = open("topology.txt", "r")
for line in f:
	s = line.split()
	if s:
		r.add(int(s[0]), int(s[1]), float(s[2]))

noise = open("noise_short.txt", "r")
for line in noise:
	s = line.strip()
	if s:
		val = int(s)
		for i in range(number_of_nodes):
			t.getNode(i).addNoiseTraceReading(val)

for i in range(number_of_nodes):
	t.getNode(i).createNoiseModel()

# Simulation time is set to 99999
for i in xrange(99999):
	t.runNextEvent()

