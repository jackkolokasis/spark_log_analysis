#!/usr/bin/env python3

###################################################
#
# file: plot_all.py
#
# @Author:   Iacovos G. Kolokasis
# @Version:  07-03-2021
# @email:    kolokasis@ics.forth.gr
#
# Plot all rdd in one graph
#
###################################################

import matplotlib.pyplot as plt
import sys
import csv
import optparse
import numpy as np
import config

usage = "usage: %prog [options]"
parser = optparse.OptionParser(usage=usage)
parser.add_option("-i", "--inFile", metavar="PATH", dest="inFile",
                  action="append",
                  help="Input File")

parser.add_option("-o", "--outFile", metavar="PATH", dest="outFile",
                  default="output.svg", help="Output PNG File")

parser.add_option("-l", "--legend", dest="legend",
                  action="append",
                  help="Legend")

parser.add_option("-s", "--startTime", dest="startTime",
                  help="Start time of the experiment")
(options, args) = parser.parse_args()

# Plot figure with fix size
fig, ax = plt.subplots(figsize=config.quartfigsize)

i = 0
for f in options.inFile:
    inputFile = open(f, 'r')

    j = 0
    for row in inputFile.readlines():

        time = int(row.split(" ")[1])

        if "as values in memory" in row:
            rdd = row.split(" ")[5]
            id = int(rdd.split("_")[2])

            x = [time - int(options.startTime)]
            y = [id]

            plt.plot(x, y, linewidth=config.edgewidth,
                     marker=config.marker[i], 
                     color=config.blue_mono[4],
                     markeredgecolor=config.blue_mono[i],
                     label=options.legend[i].strip(".out") if j == 0 else None)

        if "Found block" in row:
            rdd = row.split(" ")[6]
            id = int(rdd.split("_")[2])

            x = [time - int(options.startTime)]
            y = [id]

            plt.plot(x, y, linewidth=config.edgewidth,
                     marker=config.marker[i],
                     color=config.blue_mono[4],
                     markeredgecolor=config.blue_mono[i])
        j = j + 1

    inputFile.close()
    i = i + 1

plt.ylabel("RDD Partition ID", fontsize=config.fontsize)
plt.xlabel("Time (s)", fontsize=config.fontsize)

# Legend
legend = ax.legend(loc='upper left', bbox_to_anchor=(0.1, 1.15),
                   fontsize=config.fontsize, ncol=2, handletextpad=0.1,
                   columnspacing=0.5, framealpha=0)

legend.get_frame().set_linewidth(config.edgewidth)
legend.get_frame().set_edgecolor(config.edgecolor)

plt.savefig('%s' % options.outFile, bbox_inches='tight', dpi=900)
