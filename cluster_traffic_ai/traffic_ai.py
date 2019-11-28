#!/usr/local/bin/python3.7

# import sys
# import os
# import re
# import subprocess
# import json
import time
import threading
import modules.simulator as simulator

topology = simulator.getTopology()
print("Current nodes: " + topology['nodes'])

# simulator.updateTopology("")
# simulator.getTraffic()


try:
    threading.Thread(target=simulator.startTraffic, args=()).start()
    time.sleep(0.5)
except Exception as e:
    print("Error: unable to start thread: " + str(e))

last_qps = []

while True:
    traffic = simulator.getTraffic()
    print("QPS:" + str(traffic["QPS"]))
    if len(last_qps) > 0 and last_qps[0] != traffic["QPS"]:
        last_qps.insert(0, traffic["QPS"])
        last_qps.pop()
    else:
        last_qps.insert(len(last_qps), traffic["QPS"])

    if len(last_qps) > 3:
        break

    time.sleep(1)
