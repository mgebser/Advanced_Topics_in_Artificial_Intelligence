#!/usr/bin/env python

# COMMANDS TO RUN:
# python control.py

import signal
import clingo
from clingo import Number, Function

# initialization of menu string, target and initial positions
menu = "\n 0. EXIT\n"
target = -1
current = -1
targets = []
previous = []
positions = [Function("pos", [Function("red", []), Number(1), Number(1), Number(0)]), Function("pos", [Function("blue", []), Number(1), Number(16), Number(0)]), Function("pos", [Function("green", []), Number(16), Number(1), Number(0)]), Function("pos", [Function("yellow", []), Number(16), Number(16), Number(0)])]

# helper function to make search/optimization interruptible
def signal_handler(signum, frame):
    print(" You pressed Ctrl+C!")
    handle.cancel()

# helper function to get target position from user
def get_target():
    global target

    while target < 0:
        target = int(input("TARGET: "))
        if target > len(targets): target = -1

# print model(s) and collect initial positions for the next target (if any)
def on_model(m):
    global positions
    global answer

    print("Answer: " + str(answer))
    positions = []
    answer = answer+1
    for atom in m.symbols(shown=True):
        if atom.name == "pos": positions.append(atom)
        else: print(atom, end=" ")
    print("\nOptimization: " + str(m.cost[0]))

# create a clingo instance to build the menu string
ctl = clingo.Control()

ctl.load("board.lp")
ctl.load("ricochet_robots.lp")
ctl.add("#show pos(R,X,Y,0) : pos(R,X,Y,moves).")
ctl.ground([("base", [])])

line = 1
for atom in ctl.symbolic_atoms.by_signature("available_target", 4):
    args = atom.symbol.arguments
    menu += "{l:>2}".format(l = str(line)) + ". " + "{c:<7}".format(c = str(args[0])) + "robot to " + "{t:<7}".format(t = str(args[1])) + "at: column" + "{x:>3}".format(x = str(args[2])) + ", row" + "{y:>3}".format(y = str(args[3])) + "\n"
    args.pop(1)
    targets.append(Function("target", args))
    line = line+1

while target != 0:
    # get the next target position from user
    print(menu)
    get_target()

    if target != 0:
        if current > -1: ctl.assign_external(targets[current], False)

        # prepare for the next target
        current = target-1
        target = -1
        answer = 1

        for p in previous: ctl.assign_external(p, False)

        # create a new clingo instance for the current target
#        ctl = clingo.Control()

        # load the logic program files
#        ctl.load("board.lp")
#        ctl.load("ricochet_robots.lp")

        # inject initial positions and current target
        # ctl.add("#show pos(R,X,Y,0) : pos(R,X,Y,moves)." + ".".join([str(p) for p in positions]) + "." + str(targets[current]) + ".")
        # print("#show pos(R,X,Y,0) : pos(R,X,Y,moves)." + ".".join([str(p) for p in positions]) + "." + str(targets[current]) + ".")
        print([str(p) for p in positions])
        for p in positions:
            ctl.assign_external(p, True)

        print(str(targets[current]))
        ctl.assign_external(targets[current], True)

        previous = positions

        # ground instance and encoding for the current target
#        ctl.ground([("base", [])])

        # compute an optimal model/shortest plan unless interrupted by user
        with ctl.solve(on_model = on_model, async_ = True) as handle:
            signal.signal(signal.SIGINT, signal_handler)
            while not handle.wait(1): pass
            signal.signal(signal.SIGINT, signal.SIG_DFL)
