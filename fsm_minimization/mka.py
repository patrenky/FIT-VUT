#!/usr/bin/python3

import sys, os, re


def helpMsg():
    print("help")
    exit(0)


def err(text, code):
    print(text, file=sys.stderr)
    exit(code)

args = {
    'inputFile': None,
    'outputFile': None,
    'fnf': False,
    'minimize': False,
    'caseInsens': False,
    'mws': False,
    'rlo': False,
    'mst': None,
}

fsm = {
    'Q': [],
    'E': [],
    'R': [],
    's': [],
    'F': [],
}


# ### parse states, inputs ###
class ParseObject(object):
    def __init__(self, content, isInput):
        self.content = content
        self.input = isInput


# ### state object ###
class State(object):
    def __init__(self, content):
        self.name = content

    def __lt__(self, other):
        return self.name < other.name

    def __str__(self):
        return self.name


# ### input object ###
class Input(object):
    def __init__(self, content):
        self.name = content

    def __lt__(self, other):
        return self.name < other.name

    def __str__(self):
        return '\'' + str(self.name).replace('isapos', '\'\'') + '\''


# ### rule object ###
class Rule(object):
    def __init__(self, rStartState, rInput, rFinishState):
        self.startState = rStartState
        self.input = rInput
        self.finishState = rFinishState

    def __lt__(self, other):
        if self.startState == other.startState:
            if self.input == other.input:
                return self.finishState < other.finishState
            else:
                return self.input < other.input
        else:
            return self.startState < other.startState

    def __str__(self):
        return str(self.startState) + ' \'' + str(self.input) + '\' -> ' + str(self.finishState)


# ### minimal states ###
class MinState(object):
    def __init__(self, states):
        self.states = []
        for state in states:
            self.states.append(state)

    def __iter__(self):
        for state in self.states:
            yield state

    def __str__(self):
        string = ''
        for i, state in enumerate(self.states):
            string += str(state)
            if i < len(self.states) - 1:
                string += '_'
        return string


# ### FSM ###
class Fsm(object):
    def __init__(self):
        self.states = []
        self.inputs = []
        self.rules = []
        self.start = None
        self.finish = []
        self.rStartState = None
        self.rInput = None
        self.rFinishState = None
        self.once = True

        for obj in fsm['Q']:
            if obj.content not in self.states:
                self.states.append(State(obj.content))
        if not fsm['E']:
            err("Empty inputs", 61)
        for obj in fsm['E']:
            if obj.content not in self.inputs:
                self.inputs.append(Input(obj.content))
        for obj in enumerate(fsm['R']):
            if obj[0] % 3 == 0:
                self.rStartState = obj[1].content
                self.checkIfDef(self.states, self.rStartState)
            elif obj[0] % 3 == 1:
                self.rInput = obj[1].content
                if not self.rInput or len(self.rInput) != 1:
                    err("Eps input", 61)
                self.checkIfDef(self.inputs, self.rInput)
            elif obj[0] % 3 == 2:
                self.rFinishState = obj[1].content
                self.checkIfDef(self.states, self.rFinishState)
                # make rule
                rule = Rule(self.rStartState, self.rInput, self.rFinishState)
                if rule not in self.rules:
                    self.rules.append(rule)
                self.rStartState = None
                self.rInput = None
                self.rFinishState = None
        self.checkIfDef(self.states, fsm['s'][0].content)
        self.start = fsm['s'][0].content
        for obj in fsm['F']:
            if obj.content not in self.finish:
                self.checkIfDef(self.states, obj.content)
                self.finish.append(obj.content)

        # methods
        if self.once:
            self.reachStates()
            self.inputRule()
            self.fnf()
            self.once = False

        if args['mst']:
            self.analyzeStr()

        if args['minimize']:
            self.mka()
        else:
            self.printFsm()

    # check if states or inputs are defined
    def checkIfDef(self, where, what):
        isDef = False
        name = 'State ' if where == self.states else 'Input '
        for i in where:
            if i.name == what:
                isDef = True
        if not isDef:
            err(name + what + " is not defined", 61)

    # searching rules
    def isRules(self, state, inp, frStart, retRules):
        rules = []
        for rule in self.rules:
            if (rule.startState if frStart else rule.finishState) == state:
                if inp == rule.input or inp is None:
                    if retRules:
                        rules.append(rule)
                    else:
                        return rule
        if retRules:
            return rules
        else:
            return None

    # can reach all states
    def reachStates(self):
        for state in self.states:
            if self.start == str(state):
                continue
            if len(self.isRules(str(state), None, False, True)) == 0:
                err("State " + str(state) + " can not reach", 62)

        if args['mws']:
            states = self.fnf()
            if len(states) > 0:
                for state in states:
                    for rule in self.isRules(str(state), None, True, True):
                        self.rules.remove(rule)
                    for rule in self.isRules(str(state), None, False, True):
                        self.rules.remove(rule)
                    self.states.remove(state)

    # one rule for one input symbol
    def inputRule(self):
        qFalse = None
        for state in self.states:
            for inp in self.inputs:
                rulesNum = len(self.isRules(str(state), inp.name, True, True))
                if rulesNum != 1:
                    if rulesNum == 0:
                        if args['mws']:
                            if qFalse is None:
                                if args['caseInsens']:
                                    qFalse = State("qfalse")
                                else:
                                    qFalse = State("qFALSE")
                                self.states.append(qFalse)
                            self.rules.append(Rule(state, inp.name, qFalse))
                    else:
                        err("State " + str(state) + " have more " + str(inp), 62)

    # find-non-finishing states
    def fnf(self):
        nfStates = []
        fStates = []
        finishes = self.finish[:]

        while finishes:
            finState = finishes.pop()
            if finState not in fStates:
                fStates.append(finState)
            rules = self.isRules(finState, None, False, True)

            for rule in rules:
                if rule.startState not in fStates:
                    finishes.append(rule.startState)

        for state in self.states:
            if str(state) not in fStates:
                nfStates.append(state)

        if args['fnf']:
            if nfStates:
                args['outputFile'].write(str(nfStates[0]))
            else:
                args['outputFile'].write('0')
            exit(0)

        if args['mws']:
            return nfStates

        if len(nfStates) > 1:
            err("There are more non finishing states.", 62)

    # mka algorithm
    def mka(self):
        sets = [MinState(self.finish)]
        nfStates = []
        cleave = True
        for state in self.states:
            if state.name not in self.finish:
                nfStates.append(state)
        sets.append(MinState(nfStates))

        while cleave:
            cleave = False
            for sset in sets:
                setDict = dict()
                for inp in self.inputs:
                    for state in sset:
                        rules = self.isRules(str(state), inp.name, True, False)
                        if rules:
                            oSet = self.findState(sets, rules.finishState)
                            if oSet not in setDict:
                                setDict[oSet] = [state]
                            else:
                                setDict[oSet].append(state)

                    if len(setDict) == 1:
                        setDict.clear()
                    else:
                        for i, states in setDict.items():
                            sets.append(MinState(states))
                        sets.remove(sset)

                        cleave = True
                        break
                if cleave:
                    break

        # creating new fsm objects
        minQ = []
        for sset in sets:
            minQ.append(ParseObject(str(sset), False))

        minE = []
        for inp in self.inputs:
            minE.append(ParseObject(inp.name, True))

        minR = []
        tmpR = []
        for rule in self.rules:
            self.rStartState = self.findState(sets, rule.startState)
            self.rInput = rule.input
            self.rFinishState = self.findState(sets, rule.finishState)

            tmpRule = [self.rStartState, self.rInput, self.rFinishState]
            if tmpRule not in tmpR:
                tmpR.append(tmpRule)
                minR.append(ParseObject(str(self.rStartState), False))
                minR.append(ParseObject(self.rInput, True))
                minR.append(ParseObject(str(self.rFinishState), False))

            self.rStartState = None
            self.rInput = None
            self.rFinishState = None

        minS = [ParseObject(str(self.findState(sets, self.start)), False)]

        minF = []
        for sset in sets:
            for finState in self.finish:
                if finState in sset:
                    minF.append(ParseObject(str(sset), False))
                    break

        # change fsm globals
        fsm['Q'] = minQ
        fsm['E'] = minE
        fsm['R'] = minR
        fsm['s'] = minS
        fsm['F'] = minF
        args['minimize'] = False
        # call fsm class
        Fsm()

    def findState(self, sets, state):
        for sset in sets:
            if state in str(sset):
                return sset

    # analyze string
    def analyzeStr(self):
        if len(args['mst']) < 1:
            err("Nothing for analyze.", 1)

        isString = '1'
        actualState = self.start

        for char in args['mst']:
            isInp = False
            isRule = False
            for inp in self.inputs:
                if inp.name == char:
                    isInp = True
                    break
            if not isInp:
                err("String has char " + char + " undefined in fsm.", 1)
            for rule in self.rules:
                if rule.startState == actualState and rule.input == char:
                    isRule = True
                    actualState = rule.finishState
                    break
            if not isRule:
                isString = '0'

        if actualState not in self.finish:
            isString = '0'

        if args['outputFile'] == sys.stdout:
            args['outputFile'].write(isString)
        else:
            if open(args['outputFile'], 'w'):
                open(args['outputFile'], 'w').write(isString)
            else:
                err("Something wrong with output file", 2)
        exit(0)

    # print fsm
    def printFsm(self):
        string = '(\n{'

        # Q
        self.states.sort()
        for i, state in enumerate(self.states):
            string += str(state)
            if i < len(self.states) - 1:
                string += ', '

        string += '},\n{'

        # E
        self.inputs.sort()
        for i, inp in enumerate(self.inputs):
            string += str(inp)
            if i < len(self.inputs) - 1:
                string += ', '

        string += '},\n{\n'

        # R
        self.rules.sort()
        for i, rule in enumerate(self.rules):
            string += str(rule)
            if i < len(self.rules) - 1:
                string += ',\n'

        string += '\n},\n'

        # s
        if self.start:
            string += str(self.start)

        string += ',\n{'

        # F
        self.finish.sort()
        for i, fin in enumerate(self.finish):
            string += str(fin)
            if i < len(self.finish) - 1:
                string += ', '

        string += '}\n)\n'

        if args['outputFile'] == sys.stdout:
            args['outputFile'].write(string)
        else:
            if open(args['outputFile'], 'w'):
                open(args['outputFile'], 'w').write(string)
            else:
                err("Something wrong with output file", 2)
        exit(0)


# ### CHECK FSM ###
def checkFsm():
    # start state
    if len(fsm['s']) != 1 or fsm['s'][0].input:
        err("Bad start state", 60)

    # inputs
    for inp in fsm['E']:
        if not inp.content or len(inp.content) != 1:
            err("Bad input", 60)

    # rules
    if len(fsm['R']) % 3 != 0:
        err("Bad rules", 60)
    for obj in enumerate(fsm['R']):
        if obj[0] % 3 == 0:
            if obj[1].input:
                err("Bad rules", 60)
        elif obj[0] % 3 == 2:
            if obj[1].input:
                err("Bad rules", 60)
            elif obj[1].content[0:2] != "->":
                err("Bad rules", 60)
            obj[1].content = str.lstrip(obj[1].content[2:])

    # rlo fill states and inputs
    if args['rlo']:
        tmpE = []
        tmpQ = []
        for obj in fsm['R']:
            if obj.input:
                if obj.content not in tmpE:
                    tmpE.append(obj.content)
                    fsm['E'].append(obj)
            else:
                if obj.content not in tmpQ:
                    tmpQ.append(obj.content)
                    fsm['Q'].append(obj)
        for obj in fsm['F']:
            obj.content = str.lstrip(obj.content[2:])


    # state names
    for state in fsm:
        if state == 'E':
            break
        for obj in fsm[state]:
            if not obj.input:
                check = re.compile(r'^[a-zA-Z](_?[a-zA-Z0-9]+)*$', re.UNICODE).match(obj.content)
                if not check:
                    err("Bad state name", 60)

    # case insensitive
    if args['caseInsens']:
        for state in fsm:
            for obj in fsm[state]:
                obj.content = obj.content.lower()

    # call fsm class
    Fsm()


# ### CLEAN FSM ###
def cleanFsm():
    # clean garbage
    for state in fsm:
        for obj in fsm[state]:
            if not obj.input:
                obj.content = str.strip(obj.content)
                if not obj.content:
                    fsm[state].remove(obj)
    # clean inputs
    for obj in fsm['E']:
        if not obj.input:
            fsm['E'].remove(obj)

    # call checking
    checkFsm()


# ### RLO PARSER ###
def rloParser(data):
    isApos = False
    isInput = False
    isFirst = True
    content = ""

    for line in data:
        for char in line:
            if isInput:
                if char == '\'':
                    if isApos:
                        isApos = False
                        content += 'isapos'
                    else:
                        isApos = True
                else:
                    if isApos:
                        fsm['R'].append(ParseObject(content, isInput))
                        isInput = False
                        content = ""
                    else:
                        content += char
            if not isInput:
                if char == '\'':
                    if isFirst:
                        fsm['s'].append(ParseObject(content, isInput))
                        isFirst = False
                    fsm['R'].append(ParseObject(content, isInput))
                    isApos = False
                    isInput = True
                    content = ""
                elif char == '.':
                    fsm['F'].append(ParseObject(content, isInput))
                    fsm['R'].append(ParseObject(content, isInput))
                    content = ""
                elif char == ',':
                    fsm['R'].append(ParseObject(content, isInput))
                    content = ""
                else:
                    content += char
    # call cleaning
    cleanFsm()


# ### PARSING FSM ###
def parsing(data):
    isFsm = False
    isSet = False
    isApos = False
    isInput = False
    actualSet = 'Q'
    content = ""

    # remove comments
    data = re.sub("^#.{0,}\n", '', data)
    data = re.compile(r"(\s)#.{0,}").sub('\\1', data)
    data = re.compile(r"((\s|,)'')#.{0,}\n").sub('\\1\n', data)
    data = re.compile(r"((\s|,)'''')#.{0,}\n").sub('\\1\n', data)
    data = re.compile(r"('[^']')#.{0,}\n").sub('\\1\n', data)
    data = re.compile(r"([^'])#.{0,}\n").sub('\\1\n', data)

    if args['rlo']:
        rloParser(data)

    for line in data:
        for char in line:
            if isInput:
                if char == '\'':
                    if isApos:
                        isApos = False
                        content += 'isapos'
                    else:
                        isApos = True
                else:
                    if isApos:
                        fsm[actualSet].append(ParseObject(content, isInput))
                        isInput = False
                        content = ""
                    else:
                        content += char
            if not isInput:
                if not isSet and str.isspace(char):
                    continue
                if not isFsm:
                    if char == '(':
                        isFsm = True
                    else:
                         err("Not a FSM", 60)
                else:
                    if not isSet:
                        if char == '{':
                            isSet = True
                        elif char == ',':
                            if actualSet == 'Q':
                                actualSet = 'E'
                            elif actualSet == 'E':
                                actualSet = 'R'
                            elif actualSet == 'R':
                                actualSet = 's'
                                isSet = True
                            elif actualSet == 's':
                                actualSet = 'F'
                            elif actualSet == 'F':
                                err("Not a FSM", 60)
                        elif char == ')':
                            if actualSet == 'F':
                                isFsm = False
                            else:
                                err("Not full FSM", 60)
                        else:
                            err("Bad char: " + char, 60)
                    else:
                        if char == '\'':
                            fsm[actualSet].append(ParseObject(content, isInput))
                            isApos = False
                            isInput = True
                            content = ""
                        elif char == '}':
                            fsm[actualSet].append(ParseObject(content, isInput))
                            isSet = False
                            content = ""
                        elif char == ',':
                            fsm[actualSet].append(ParseObject(content, isInput))
                            content = ""
                            if actualSet == 's':
                                isSet = False
                                actualSet = 'F'
                        else:
                            content += char
    if actualSet != 'F':
        err("Not full FSM", 60)
    # call cleaning
    cleanFsm()


# ### ARGUMENTS ###
def loadArgs():
    arguments = sys.argv
    if len(arguments) == 1 and arguments[0] == "--help":
        helpMsg()

    for argument in arguments:
        if "--input=" in argument and not args['inputFile']:
            args['inputFile'] = argument[8:]
        elif "--output=" in argument and not args['outputFile']:
            args['outputFile'] = argument[9:]
        elif (argument == "-f" or argument == "--find-non-finishing") and not args['fnf']:
            args['fnf'] = True
        elif (argument == "-m" or argument == "--minimize") and not args['minimize']:
            args['minimize'] = True
        elif (argument == "-i" or argument == "--case-insensitive") and not args['caseInsens']:
            args['caseInsens'] = True
        elif argument == "--wsfa" and not args['mws']:
            args['mws'] = True
        elif argument == "-r" or argument == "--rules-only":
            args['rlo'] = True
        elif "--analyze-string=" in argument and not args['mst']:
            args['mst'] = argument[17:]
        elif argument == "--help":
            err("Try only argument --help", 1)
        else:
            err("Bad argument: " + argument, 1)

    # set defaults
    if not args['inputFile']:
        args['inputFile'] = sys.stdin
    if not args['outputFile']:
        args['outputFile'] = sys.stdout

    # check
    if args['fnf'] and args['minimize']:
        err("Do not combine -m and -f", 1)
    if args['mst'] and (args['fnf'] or args['minimize']):
        err("Do not combine analyze string and -m and -f", 1)

    if args['inputFile']:
        if open(args['inputFile'], 'r'):
            # call parse input data
            parsing(open(args['inputFile'], 'r').read())
        else:
            err("Something wrong with input file", 2)


# start here
sys.argv.pop(0)
loadArgs()
