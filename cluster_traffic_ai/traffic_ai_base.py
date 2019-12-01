#!/usr/local/bin/python3.7

import time
import threading

import modules.simulator as simulator

dataset = "lin"
simulator.updateTopology("nodes=2")
nodes = int(simulator.getTopology()['nodes'])

try:
    simulation = threading.Thread(
        target=simulator.startTraffic, args=(dataset,))
    simulation.start()
    time.sleep(0.5)
except Exception as e:
    ("Error: unable to start thread: " + str(e))
    exit(1)

while True:
    if not simulation.is_alive():
        break

    traffic = simulator.getTraffic()
    print("%8s QPS: %-5d | N: %-2d | RT: %.5f" %
          ("", traffic["QPS"], nodes, traffic["RT"]))

    if traffic["RT"] > 1:
        nodes = nodes + 1
        simulator.updateTopology("nodes=" + str(nodes))

    time.sleep(1)
