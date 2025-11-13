#!/usr/bin/env python

# import sys
import signal
import clingo
from clingo import Number, Function

menu = "\n 0. EXIT\n"
target = -1
targets = []
positions = []

def signal_handler(signum, frame):
    print(" You pressed Ctrl+C!")
    handle.cancel()

def get_target():
    global target

    while target < 0:
        target = int(input("TARGET: "))
        if target > len(targets): target = -1

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

ctl = clingo.Control()

ctl.load("board.lp")
ctl.load("ricochet_robots.sol.lp")
ctl.add("#show pos(R,X,Y,0) : pos(R,X,Y,moves).")
ctl.ground([("base", [])])

for atom in ctl.symbolic_atoms.by_signature("initial_pos", 3):
    args = atom.symbol.arguments
    args.append(Number(0))
    positions.append(Function("pos", args))

line = 1
for atom in ctl.symbolic_atoms.by_signature("available_target", 4):
    args = atom.symbol.arguments
    menu += "{l:>2}".format(l = str(line)) + ". " + "{c:<7}".format(c = str(args[0])) + "robot to " + "{t:<7}".format(t = str(args[1])) + "at: column" + "{x:>3}".format(x = str(args[2])) + ", row" + "{y:>3}".format(y = str(args[3])) + "\n"
    args.pop(1)
    targets.append(Function("target", args))
    line = line+1

while target != 0:
    print(menu)
    get_target()

    if target != 0:
        current = target-1
        target = -1
        previous = positions
        answer = 1

        for atom in previous: ctl.assign_external(atom, True)
        ctl.assign_external(targets[current], True)

        with ctl.solve(on_model = on_model, async_ = True) as handle:
            signal.signal(signal.SIGINT, signal_handler)
            while not handle.wait(1): pass
            signal.signal(signal.SIGINT, signal.SIG_DFL)

        for atom in previous: ctl.assign_external(atom, False)
        ctl.assign_external(targets[current], False)
