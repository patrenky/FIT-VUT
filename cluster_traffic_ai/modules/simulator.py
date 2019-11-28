#!/usr/local/bin/python3.7

# import sys
import os
# import re
import subprocess
import json

dir_simulator = "./cluster_simulator"
dir_back = "../"


def execute(command):
    process = subprocess.run(
        command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE
    )
    return process.returncode, process.stdout.decode('utf-8'), process.stderr.decode('utf-8')


def getTopology():
    with open(dir_simulator + '/topology.json', 'r') as f:
        data = json.load(f)
    # print("Have topology: " + json.dumps(data))
    return data


def updateTopology(updates):
    os.chdir(dir_simulator)
    code, out, err = execute("perl update_topology.pl " + updates)
    if out:
        print(out)
    os.chdir(dir_back)


def getTraffic():
    os.chdir(dir_simulator)
    code, out, err = execute("perl get_traffic.pl")
    ret = None
    if code != 0:
        print("Failed to read traffic data")
    else:
        ret = json.loads(out)
        # print("Have traffic data: " + json.dumps(ret))
    os.chdir(dir_back)
    return ret


def startTraffic():
    code, out, err = execute("perl ./cluster_simulator/start_traffic.pl")
    if out:
        print(out)
