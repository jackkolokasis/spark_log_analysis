#!/usr/bin/env python3

###################################################
#
# file: figure4.py
#
# @Author:   Iacovos G. Kolokasis
# @Version:  07-03-2021
# @email:    kolokasis@ics.forth.gr
#
# Plot rdd sizes
#
###################################################

import matplotlib.pyplot as plt
import time
import sys
import csv
import optparse
import numpy as np
import config

usage = "usage: %prog [options]"
parser = optparse.OptionParser(usage=usage)
parser.add_option("-i", "--inFile", metavar="PATH", dest="inFile",
                  help="Input File")
parser.add_option("-o", "--outFile", metavar="PATH", dest="outFile",
                  default="output.svg", help="Output PNG File")
parser.add_option("-l", "--legend", dest="legend",
                  help="Legend")
(options, args) = parser.parse_args()

inputFile = open(options.inFile, 'r')

# Plot figure with fix size
fig, ax = plt.subplots(figsize=config.halffigsize)

count = 0;

for row in inputFile.readlines():
    if count == 0:
        start_time = int(row.split(" ")[1])
        count = 1;

    time = int(row.split(" ")[1])

    if "as values in memory" in row:
        rdd = row.split(" ")[5]
        id = int(rdd.split("_")[2])

        x = [time - start_time]
        y = [id]

        plt.plot(x, y, linewidth=config.edgewidth,
                 marker=config.marker[1], color=config.monochrom[0])

    if "Found block" in row:
        rdd = row.split(" ")[6]
        id = int(rdd.split("_")[2])

        x = [time - start_time]
        y = [id]

        plt.plot(x, y, linewidth=config.edgewidth,
                 marker=config.marker[1], color=config.monochrom[0])

plt.ylabel("RDD Partition Id", fontsize=config.fontsize)
plt.xlabel("Time (s)", fontsize=config.fontsize)



plt.savefig('%s' % options.outFile, bbox_inches='tight', dpi=900)
