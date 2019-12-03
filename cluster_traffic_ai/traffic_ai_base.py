#!/usr/local/bin/python3.7

import time
import threading

import modules.simulator as simulator

dataset = "lin_up_down"
simulator.updateTopology("nodes=2")
nodes = int(simulator.getTopology()['nodes'])

treshold_top = 1.8
treshold_bottom = 0.4

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
    print("%5s QPS: %-5d | N: %-2d | RT: %.5f" %
          ("", traffic["QPS"], nodes, traffic["RT"]))

    if traffic["RT"] >= treshold_top and nodes < 10:
        nodes = nodes + 1
        simulator.updateTopology("nodes=" + str(nodes))

    elif traffic["RT"] <= treshold_bottom and nodes > 2:
        nodes = nodes - 1
        simulator.updateTopology("nodes=" + str(nodes))

    time.sleep(1)
